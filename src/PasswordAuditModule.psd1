@{

# Ce manifeste est associé avec le module PasswordAuditModule
RootModule = 'PasswordAuditModule.psm1'

# Version du module
ModuleVersion = '1.0'

# ID unique
GUID = 'a763dd36-3162-4b2d-82b4-a7a72461e484'

# L'auteur du module
Author = 'Marsil'

# Copyright
Copyright = '(c) Marsil. All rights reserved.'

# Description du module
Description = 'Module PowerShell pour identifier les comptes avec les mêmes mots de passes'

# Version minimum requise
PowerShellVersion = '5.1'

# Les fonctions à exporter
FunctionsToExport = @(
    "Get-UserHashes", "Find-DuplicatePasswords", "Export-DuplicatePasswords", "New-SampleData")
    
}