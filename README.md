# PasswordAuditModule

## Description
PasswordAuditModule est un module PowerShell permettant d'identifier les comptes utilisant les mêmes mots de passe en analysant leurs hachages.

## Installation

```powershell
# Copier le module dans le dossier des modules PowerShell
$ModulePath = "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\PasswordAuditModule"
New-Item -ItemType Directory -Path $ModulePath -Force
Copy-Item -Path .\PasswordAuditModule.psm1 -Destination $ModulePath
Copy-Item -Path .\PasswordAuditModule.psd1 -Destination $ModulePath
```

## Utilisation

Importer le module :

```powershell
Import-Module PasswordAuditModule
```

Exécuter la fonction principale :

```powershell
Get-UserHashes -FilePath "C:\chemin\vers\fichier.csv"
```

## Structure du projet

```
PasswordAuditModule/
│── src/
│   ├── PasswordAuditModule.psd1
│   ├── PasswordAuditModule.psm1
│── .gitignore
│── README.md
