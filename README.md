# CombineFiles-PowerShell

> **Modulo PowerShell per la combinazione di file**  
> Unisciti a file multipli o elenca i loro nomi utilizzando preset predefiniti e modalità interattive per una personalizzazione completa.

## 🛠 Funzionalità principali

- **Preset configurabili:**  
  Il modulo include preset predefiniti (es. *CSharp*) che impostano automaticamente filtri su estensioni, cartelle da escludere, pattern regex e altre opzioni comuni. È possibile estendere o sovrascrivere questi preset con parametri personalizzati per adattare la combinazione alle proprie esigenze.

- **Modalità di selezione file multiple:**  
  - **List:** Combina file specificati in una lista.
  - **Extensions:** Seleziona file basandosi sulle estensioni (es. `.cs`, `.xaml`).
  - **Regex:** Selezione dei file tramite pattern regex.
  - **InteractiveSelection:** Avvia una modalità interattiva che permette di modificare manualmente l’elenco dei file da combinare.

- **Filtraggio avanzato:**  
  - Esclude file nascosti, cartelle specifiche e file che corrispondono a determinati pattern (inclusi quelli "auto-generated", sia per nome che per contenuto).  
  - Permette di filtrare i file in base a range di date e dimensioni, con supporto per formati come “1MB” o “10MB”.

- **Gestione degli hard link:**  
  Calcola l’hash dei file per evitare duplicazioni, garantendo che i file con hard link non vengano processati più volte.

- **Logging dettagliato:**  
  Il modulo genera log operativi (livelli INFO e DEBUG) per tracciare le operazioni, facilitando il debug e il monitoraggio delle attività.

- **Output flessibile:**  
  Il risultato può essere salvato in un file (formati configurabili: txt, csv, json) oppure visualizzato a video. È possibile specificare l’encoding del file di output (ad esempio, UTF8, ASCII, ecc.).

## ⚙️ Configurazione per un utilizzo comodo

Per rendere l’uso quotidiano del modulo ancora più semplice, puoi aggiungere una funzione wrapper al tuo profilo PowerShell (ad esempio, nel file `Microsoft.PowerShell_profile.ps1`). Ecco un esempio:

```powershell
function Combine-Files {
    & "C:\Percorso\Al\Modulo\Combine-Files.ps1" @args
}
```

Adatta il percorso in base alla posizione in cui hai clonato il repository. In questo modo, potrai eseguire il modulo semplicemente digitando `Combine-Files` seguito dai parametri desiderati.

## Parametri e Opzioni

Il modulo supporta numerosi parametri per personalizzare il comportamento della combinazione:

- **Preset:** Specifica il nome di un preset predefinito (es. `CSharp`) da utilizzare.
- **ListPresets:** Elenca i preset disponibili.
- **Mode:** Imposta la modalità di selezione dei file. Le opzioni disponibili sono:  
  - `list` – per combinare file specifici indicati in una lista.  
  - `extensions` – per selezionare file in base alle estensioni.  
  - `regex` – per selezionare file tramite pattern regex.  
  - `InteractiveSelection` – per avviare una modalità interattiva che consente di modificare l’elenco dei file.
- **FileList:** (Array) Specifica i nomi dei file da combinare (utilizzato in modalità `list`).
- **Extensions:** (Array) Indica le estensioni dei file da includere (es. `.cs`, `.xaml`), usato in modalità `extensions`.
- **RegexPatterns:** (Array) Definisce i pattern regex per selezionare i file (modalità `regex`).
- **OutputFile:** Il percorso del file di output. Il valore predefinito è `CombinedFile.txt` nella cartella corrente.
- **Recurse:** Se attivo, il modulo cerca i file anche nelle sottocartelle.
- **FileNamesOnly:** Se abilitato, il modulo stampa solo i nomi dei file invece del loro contenuto.
- **OutputToConsole:** Se attivo, l’output viene visualizzato a video invece di essere salvato su file.
- **ExcludePaths, ExcludeFiles, ExcludeFilePatterns:** Array di parametri per escludere specifiche cartelle, file o pattern.
- **OutputEncoding:** Specifica l’encoding per il file di output. Possibili valori includono: `UTF8`, `ASCII`, `UTF7`, `UTF32`, `Unicode`, `Default`.  
  (Default: `UTF8`)
- **OutputFormat:** Il formato del file di output; opzioni disponibili: `txt`, `csv`, `json`.  
  (Default: `txt`)
- **MinDate, MaxDate:** Impostano il range di date per includere i file.
- **MinSize, MaxSize:** Definiscono il range di dimensioni per includere i file, accettando formati come “1MB” o “10MB”.
- **EnableLog:** Se attivato, il modulo genera un file di log contenente le operazioni eseguite.
- **Help:** Mostra il messaggio di aiuto.

## Esempi di Utilizzo

- **Combinazione base con preset predefinito:**

  ```powershell
  .\Combine-Files.ps1 -Preset 'CSharp'
  ```

  Combina tutti i file con estensioni `.cs` e `.xaml` nelle cartelle correnti e sottocartelle, escludendo cartelle come `Properties`, `obj` e `bin`, e salva il risultato in `CombinedFile.cs`.

- **Utilizzo della modalità extensions:**

  ```powershell
  .\Combine-Files.ps1 -Mode 'extensions' -Extensions '.cs', '.xaml' -Recurse -EnableLog
  ```

  Combina tutti i file con estensione `.cs` e `.xaml`, cercandoli anche nelle sottocartelle e gestendo correttamente hard link e reparse point.

- **Modalità interattiva:**

  ```powershell
  .\Combine-Files.ps1 -Mode 'InteractiveSelection' -Extensions '.cs', '.xaml' -OutputFile 'CombinedFile.cs' -Recurse -ExcludePaths 'Properties', 'obj', 'bin' -ExcludeFilePatterns '.*\.g\.cs$', '.*\.designer\.cs$', '.*\.g\.i\.cs$' -EnableLog
  ```

  Avvia una modalità interattiva per personalizzare l’elenco dei file da combinare, utile quando si desidera intervenire manualmente sulla selezione.

## Conclusioni

CombineFiles-PowerShell offre una soluzione potente e flessibile per la combinazione dei file tramite PowerShell. Con preset preconfigurati, modalità di selezione multipla e opzioni avanzate di filtraggio e logging, il modulo può essere facilmente adattato a numerosi scenari. Configura il wrapper nel tuo profilo PowerShell per eseguire comodamente lo script e sfrutta le opzioni disponibili per ottenere esattamente il risultato desiderato.
