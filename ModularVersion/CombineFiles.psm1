# CombineFiles.psm1

# Importa i sottomoduli
Import-Module -Name (Join-Path $PSScriptRoot 'Logging\Logging.psm1') -Force
Import-Module -Name (Join-Path $PSScriptRoot 'FileSelection\FileSelection.psm1') -Force
Import-Module -Name (Join-Path $PSScriptRoot 'InteractiveSelection\InteractiveSelection.psm1') -Force
Import-Module -Name (Join-Path $PSScriptRoot 'Utilities\Utilities.psm1') -Force

# Definisce le funzioni esportate

function Start-CombineFiles {
    <#
    .SYNOPSIS
    Combina il contenuto di pi� file o stampa i nomi dei file in base alle opzioni, con supporto per preset predefiniti e modalit� interattive.

    .DESCRIPTION
    Questa funzione permette di combinare file o stampare i loro nomi, basandosi su una lista specifica, estensioni o espressioni regolari.
    Supporta l'uso di preset predefiniti per configurazioni comuni, come il preset 'CSharp', e permette di estendere o sovrascrivere tali preset con parametri aggiuntivi.
    Include miglioramenti nella gestione delle esclusioni, una modalit� interattiva per gestire manualmente l'elenco dei file e un'interfaccia utente migliorata per una migliore esperienza d'uso.
    
    # Include qui la documentazione dettagliata come nel tuo script originale
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false, HelpMessage = "Nome del preset da utilizzare.")]
        [ValidateNotNullOrEmpty()]
        [string]$Preset,
    
        [Parameter(Mandatory = $false, HelpMessage = "Elenca i preset disponibili.")]
        [switch]$ListPresets,
    
        [Parameter(Mandatory = $false, HelpMessage = "La modalit� di selezione dei file: 'list', 'extensions', 'regex', 'InteractiveSelection'.")]
        [ValidateSet("list", "extensions", "regex", "InteractiveSelection")]
        [string]$Mode,
    
        [Parameter(Mandatory = $false, HelpMessage = "Array di nomi di file da combinare. Utilizzato quando la modalit� � 'list'.")]
        [string[]]$FileList,
    
        [Parameter(Mandatory = $false, HelpMessage = "Array di estensioni di file da includere (es. '.xaml', '.cs'). Utilizzato quando la modalit� � 'extensions'.")]
        [string[]]$Extensions,
    
        [Parameter(Mandatory = $false, HelpMessage = "Array di pattern regex per selezionare i file. Utilizzato quando la modalit� � 'regex'.")]
        [string[]]$RegexPatterns,
    
        [Parameter(Mandatory = $false, HelpMessage = "Percorso del file di output. Default: 'CombinedFile.txt' nella cartella corrente.")]
        [string]$OutputFile = "CombinedFile.txt",
    
        [Parameter(Mandatory = $false, HelpMessage = "Indica se cercare anche nelle sottocartelle.")]
        [switch]$Recurse,
    
        [Parameter(Mandatory = $false, HelpMessage = "Indica se stampare solo i nomi dei file invece che anche il contenuto.")]
        [switch]$FileNamesOnly,
    
        [Parameter(Mandatory = $false, HelpMessage = "Indica se stampare a video invece che creare un file.")]
        [switch]$OutputToConsole,
    
        [Parameter(Mandatory = $false, HelpMessage = "Array di percorsi di cartelle da escludere.")]
        [string[]]$ExcludePaths,
    
        [Parameter(Mandatory = $false, HelpMessage = "Array di nomi di file da escludere.")]
        [string[]]$ExcludeFiles,
    
        [Parameter(Mandatory = $false, HelpMessage = "Array di pattern regex per escludere i file.")]
        [string[]]$ExcludeFilePatterns,
    
        [Parameter(Mandatory = $false, HelpMessage = "Encoding del file di output. Default: UTF8.")]
        [ValidateSet("UTF8", "ASCII", "UTF7", "UTF32", "Unicode", "Default")]
        [string]$OutputEncoding = "UTF8",
    
        [Parameter(Mandatory = $false, HelpMessage = "Formato del file di output: 'txt', 'csv', 'json'. Default: 'txt'.")]
        [ValidateSet("txt", "csv", "json")]
        [string]$OutputFormat = "txt",
    
        [Parameter(Mandatory = $false, HelpMessage = "Data minima per i file da includere.")]
        [datetime]$MinDate,
    
        [Parameter(Mandatory = $false, HelpMessage = "Data massima per i file da includere.")]
        [datetime]$MaxDate,
    
        [Parameter(Mandatory = $false, HelpMessage = "Dimensione minima dei file (es. '1MB').")]
        [string]$MinSize,
    
        [Parameter(Mandatory = $false, HelpMessage = "Dimensione massima dei file (es. '10MB').")]
        [string]$MaxSize
    )
    
    # Variabili globali
    $sourcePath = Get-Location
    $logFile = Join-Path -Path $sourcePath -ChildPath "CombineFiles.log"
    
    # Inizializza il log
    try {
        Out-File -FilePath $logFile -Force -Encoding UTF8
        Write-Log "Inizio operazione di combinazione file."
    }
    catch {
        Write-Error "Impossibile creare il file di log: $logFile"
        Show-Message "Impossibile creare il file di log: $logFile" "Red"
        return
    }
    
    # Gestione del parametro -ListPresets
    if ($ListPresets) {
        List-CombineFilesPresets
        Write-Log "Elenco dei preset richiesto dall'utente."
        return
    }
    
    # Applicazione dei preset
    if ($Preset) {
        Apply-CombineFilesPreset -PresetName $Preset
    }
    
    Write-Log "Percorso sorgente: $sourcePath"
    Write-Log "File di output: $OutputFile"
    
    # Converti il percorso relativo del file di output in un percorso assoluto
    if (-not [System.IO.Path]::IsPathRooted($OutputFile)) {
        $OutputFile = Join-Path -Path $sourcePath -ChildPath $OutputFile
    }
    Write-Log "Percorso assoluto del file di output: $OutputFile"
    
    # Normalizza i percorsi in $ExcludePaths a percorsi completi
    $fullExcludePaths = Normalize-ExcludePaths -ExcludePaths $ExcludePaths -SourcePath $sourcePath
    
    # Definisci i file da escludere
    $fullExcludeFiles = $ExcludeFiles
    if ($fullExcludeFiles) {
        foreach ($file in $fullExcludeFiles) {
            Write-Log "File escluso aggiunto: $file"
        }
        Write-Log "Totale file esclusi: $($fullExcludeFiles.Count)"
    }
    
    # Definisci i pattern di file da escludere
    $fullExcludeFilePatterns = $ExcludeFilePatterns
    if ($fullExcludeFilePatterns) {
        foreach ($pattern in $fullExcludeFilePatterns) {
            Write-Log "Pattern di file escluso aggiunto: $pattern"
        }
        Write-Log "Totale pattern di file esclusi: $($fullExcludeFilePatterns.Count)"
    }
    
    # Validazione delle estensioni
    Validate-Extensions -Mode $Mode -Extensions $Extensions
    
    # Converti le dimensioni in byte
    $minSizeBytes = if ($MinSize) { Convert-SizeToBytes -Size $MinSize } else { 0 }
    $maxSizeBytes = if ($MaxSize) { Convert-SizeToBytes -Size $MaxSize } else { [int64]::MaxValue }
    
    # Ottieni la lista dei file da processare
    $filesToProcess = Get-FilesToProcess -Mode $Mode -FileList $FileList -Extensions $Extensions -RegexPatterns $RegexPatterns `
        -SourcePath $sourcePath -Recurse:$Recurse -FullExcludePaths $fullExcludePaths `
        -FullExcludeFiles $fullExcludeFiles -FullExcludeFilePatterns $fullExcludeFilePatterns
    
    Write-Log "Numero iniziale di file da processare: $($filesToProcess.Count)"
    Show-Message "Numero iniziale di file da processare: $($filesToProcess.Count)" "Cyan"
    
    # Gestione della modalit� InteractiveSelection
    if ($Mode -eq 'InteractiveSelection') {
        Write-Log "Modalit� 'InteractiveSelection' attivata."
        Show-Message "Modalit� 'InteractiveSelection' attivata." "Yellow"
    
        # Avvia la procedura di selezione interattiva
        $interactiveFiles = Start-InteractiveSelection -InitialFiles $filesToProcess -SourcePath $sourcePath
    
        if ($interactiveFiles.Count -eq 0) {
            Write-Warning "Nessun file selezionato dopo la selezione interattiva."
            Write-Log "Nessun file selezionato dopo la selezione interattiva." "WARNING"
            Show-Message "Nessun file selezionato dopo la selezione interattiva." "Yellow"
            return
        }
    
        # Sostituisci l'elenco dei file da processare con quelli aggiornati
        $filesToProcess = $interactiveFiles
    
        Write-Log "Numero di file dopo InteractiveSelection: $($filesToProcess.Count)"
        Show-Message "Numero di file dopo InteractiveSelection: $($filesToProcess.Count)" "Cyan"
    }
    
    # Filtra i file basati su data e dimensione
    if ($MinDate -or $MaxDate -or $MinSize -or $MaxSize) {
        $filesToProcess = $filesToProcess | Where-Object {
            $file = Get-Item $_
            $validDate = ($file.LastWriteTime -ge $MinDate -or -not $MinDate) -and
                         ($file.LastWriteTime -le $MaxDate -or -not $MaxDate)
            $validSize = ($file.Length -ge $minSizeBytes) -and
                         ($file.Length -le $maxSizeBytes)
            $validDate -and $validSize
        }
        Write-Log "Totale file dopo filtraggio per data e dimensione: $($filesToProcess.Count)"
        Show-Message "Totale file dopo filtraggio per data e dimensione: $($filesToProcess.Count)" "Cyan"
    }
    
    # Filtra nuovamente per escludere eventuali percorsi non gestiti
    if ($fullExcludePaths -or $fullExcludeFiles -or $fullExcludeFilePatterns) {
        $filesToProcess = $filesToProcess | Where-Object {
            -not (Is-PathExcluded -FilePath $_ -ExcludedPaths $fullExcludePaths -ExcludedFiles $fullExcludeFiles -ExcludedFilePatterns $fullExcludeFilePatterns)
        }
        Write-Log "Totale file da processare dopo esclusione finale: $($filesToProcess.Count)"
        Show-Message "Totale file da processare dopo esclusione finale: $($filesToProcess.Count)" "Cyan"
    }
    
    # Verifica se sono stati trovati file da unire
    if ($filesToProcess.Count -eq 0) {
        Write-Warning "Nessun file trovato per l'unione."
        Write-Log "Nessun file trovato per l'unione." "WARNING"
        Show-Message "Nessun file trovato per l'unione." "Yellow"
        return
    }
    else {
        Write-Log "Trovati $($filesToProcess.Count) file da processare."
        Show-Message "Trovati $($filesToProcess.Count) file da processare." "Green"
    }
    
    # Configura l'encoding
    $encodingSwitch = switch ($OutputEncoding) {
        'UTF8'    { "UTF8" }
        'ASCII'   { "ASCII" }
        'UTF7'    { "UTF7" }
        'UTF32'   { "UTF32" }
        'Unicode' { "Unicode" }
        'Default' { "Default" }
    }
    
    # Se non si stampa a video, crea o svuota il file di output
    if (-not $OutputToConsole) {
        try {
            switch ($OutputFormat) {
                'txt' {
                    Out-File -FilePath $OutputFile -Force -Encoding $encodingSwitch
                }
                'csv' {
                    @() | Export-Csv -Path $OutputFile -Force -NoTypeInformation -Encoding $encodingSwitch
                }
                'json' {
                    @() | ConvertTo-Json | Out-File -FilePath $OutputFile -Force -Encoding $encodingSwitch
                }
            }
            Write-Log "File di output creato/svuotato: $OutputFile"
            Show-Message "File di output creato/svuotato: $OutputFile" "Green"
        }
        catch {
            Write-Log "Impossibile creare o scrivere nel file di output: $OutputFile - $_" "ERROR"
            Show-Message "Errore: Impossibile creare o scrivere nel file di output: $OutputFile" "Red"
            return
        }
    }
    
    # Imposta la barra di avanzamento
    $totalFiles = $filesToProcess.Count
    $currentFile = 0
    
    # Processa ogni file
    foreach ($filePath in $filesToProcess) {
        $currentFile++
        Write-Progress -Activity "Combinazione dei file" -Status "Elaborazione file $currentFile di $totalFiles" -PercentComplete (($currentFile / $totalFiles) * 100)
    
        $fileName = [System.IO.Path]::GetFileName($filePath)
        $outputContent = if ($FileNamesOnly) { "### $fileName ###" } else { "### Contenuto di $fileName ###" }
    
        Write-OutputOrFile -Content $outputContent -OutputToConsole:$OutputToConsole -OutputFile $OutputFile -OutputFormat $OutputFormat
    
        if (-not $FileNamesOnly) {
            Write-Log "Aggiungendo contenuto di: $fileName"
            try {
                $fileContent = Get-Content -Path $filePath -ErrorAction Stop
                if ($OutputToConsole) {
                    $fileContent | Write-Output
                    Write-Output ""  # Linea vuota per separare i file
                }
                else {
                    switch ($OutputFormat) {
                        'txt' {
                            Add-Content -Path $OutputFile -Value $fileContent
                            Add-Content -Path $OutputFile -Value "`n"  # Linea vuota
                        }
                        'csv' {
                            # Gestisci CSV come necessario
                            foreach ($line in $fileContent) {
                                Add-Content -Path $OutputFile -Value $line
                            }
                        }
                        'json' {
                            # Gestisci JSON come necessario
                            foreach ($line in $fileContent) {
                                Add-Content -Path $OutputFile -Value $line
                            }
                        }
                    }
                }
                Write-Log "File aggiunto correttamente: $fileName"
            }
            catch {
                Write-Warning "Impossibile leggere il file: $filePath"
                Write-Log "Impossibile leggere il file: $filePath - $_" "WARNING"
                Show-Message "Attenzione: Impossibile leggere il file: $filePath" "Magenta"
            }
        }
    }
    
    # Messaggio di completamento
    if (-not $OutputToConsole) {
        Write-Log "Operazione completata. Controlla il file '$OutputFile'."
        Show-Message "Operazione completata. Controlla il file '$OutputFile'." "Green"
    }
    else {
        Write-Log "Operazione completata con output a console."
        Show-Message "Operazione completata con output a console." "Green"
    }
}

function List-CombineFilesPresets {
    <#
    .SYNOPSIS
    Elenca i preset disponibili per Combine-Files.

    .DESCRIPTION
    Questa funzione mostra tutti i preset disponibili definiti nel modulo Combine-Files.

    #>
    Show-Message "Preset disponibili:" "Cyan"
    foreach ($preset in $Presets.Keys) {
        Show-Message "- $preset" "Green"
    }
    Write-Log "Elenco dei preset richiesto dall'utente."
}

function Apply-CombineFilesPreset {
    <#
    .SYNOPSIS
    Applica un preset di configurazione.

    .DESCRIPTION
    Questa funzione applica i parametri definiti in un preset, permettendo di estendere o sovrascrivere i valori tramite i parametri passati all'invocazione dello script.

    .PARAMETER PresetName
    Il nome del preset da applicare.

    #>
    param (
        [Parameter(Mandatory = $true)]
        [string]$PresetName
    )

    if ($Presets.ContainsKey($PresetName)) {
        $presetParams = $Presets[$PresetName]
        foreach ($key in $presetParams.Keys) {
            if (-not $PSBoundParameters.ContainsKey($key)) {
                if ($presetParams[$key] -is [System.Collections.IEnumerable] -and -not ($presetParams[$key] -is [string])) {
                    # Se il parametro � un array, unisci con eventuali valori gi� presenti
                    if ($key -eq 'ExcludePaths') {
                        $ExcludePaths += $presetParams[$key]
                    }
                    elseif ($key -eq 'Extensions') {
                        $Extensions += $presetParams[$key]
                    }
                    elseif ($key -eq 'ExcludeFilePatterns') {
                        $ExcludeFilePatterns += $presetParams[$key]
                    }
                    # Aggiungi altri array se necessario
                }
                else {
                    # Imposta il valore del parametro se non � un array
                    Set-Variable -Name $key -Value $presetParams[$key]
                }
                Write-Log "Applicato preset '$PresetName': $key = $($presetParams[$key])"
                Show-Message "Applicato preset '$PresetName': $key = $($presetParams[$key])" "Yellow"
            }
        }
    }
    else {
        Write-Error "Preset '$PresetName' non trovato."
        Write-Log "Errore: Preset '$PresetName' non trovato." "ERROR"
        Show-Message "Errore: Preset '$PresetName' non trovato." "Red"
        return
    }
}
