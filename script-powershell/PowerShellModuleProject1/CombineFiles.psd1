# CombineFiles.psd1
@{
    # Schema del modulo
    SchemaVersion = 2.0
    GUID = 'e1234567-89ab-4cde-8f01-23456789abcd'  # Genera un GUID unico
    Author = 'Il Tuo Nome'
    CompanyName = 'La Tua Azienda'
    Description = 'Modulo per combinare file con supporto per preset e modalità interattive.'

    # File principali del modulo
    RootModule = 'CombineFiles.psm1'

    # Sottomoduli inclusi
    NestedModules = @(
        'Logging\Logging.psm1',
        'FileSelection\FileSelection.psm1',
        'InteractiveSelection\InteractiveSelection.psm1',
        'Utilities\Utilities.psm1'
    )

    # Funzioni esportate
    FunctionsToExport = @('Start-CombineFiles', 'List-CombineFilesPresets')

    # Altre esportazioni (vacuate)
    CmdletsToExport = @()
    VariablesToExport = @()
    AliasesToExport = @()

    # Requisiti
    PowerShellVersion = '5.1'
}
