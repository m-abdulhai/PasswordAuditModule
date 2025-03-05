function Get-UserHashes {
        <#
    .SYNOPSIS
    Récupère les hachages de mot de passe des utilisateurs.
    .DESCRIPTION
    Utilise un outil externe pour extraire les hachages (comme dsquery + mimikatz).
    #>

    param (
        [Parameter(Mandatory)]
        [string]$FilePath
    )

    # Vérifier si le fichier existe
    if (-Not (Test-Path $FilePath)) {
        throw "Erreur : Le fichier spécifié n'existe pas à l'emplacement : $FilePath"
    }

    # Lire le fichier CSV
    $csvData = Import-Csv -Path $FilePath

    # Vérifier que le fichier n'est pas vide
    if (-Not $csvData) {
        throw "Erreur : Le fichier est vide ou mal formaté."
    }

    # Vérifier les colonnes nécessaires
    if (-Not ($csvData[0].PSObject.Properties.Name -contains 'Username') -or 
        -Not ($csvData[0].PSObject.Properties.Name -contains 'Hash')) {
        throw "Erreur : Le fichier doit contenir les colonnes 'Username' et 'Hash'."
    }

    # Initialiser une liste pour stocker les résultats
    $userHashes = @()

    # Traiter chaque ligne du fichier CSV
    foreach ($row in $csvData) {
        if (-Not $row.Username -or -Not $row.Hash) {
            Write-Warning "Ligne ignorée : une colonne est vide (Username ou Hash)."
            continue
        }

        # Ajouter l'utilisateur à la liste
        $userHashes += [PSCustomObject]@{
            Username = $row.Username
            Hash     = $row.Hash
        }
    }

    # Vérifier si des utilisateurs valides ont été trouvés
    if (-Not $userHashes) {
        throw "Erreur : Aucun utilisateur valide trouvé dans le fichier."
    }

    # Retourner les résultats
    return $userHashes
}

function Find-DuplicatePasswords {
        <#
    .SYNOPSIS
    Identifie les comptes utilisant le même mot de passe.
    .DESCRIPTION
    Compare les hachages de mot de passe pour détecter les doublons.
    #>

    param (
        [Parameter(Mandatory)]
        [array]$UserHashes
    )

    # Vérifier si les données sont valides
    if (-Not $UserHashes -or $UserHashes.Count -eq 0) {
        throw "Erreur : Les données fournies sont vides ou non valides."
    }

    # Vérifier les propriétés des objets
    if (-Not ($UserHashes[0].PSObject.Properties.Name -contains 'Username') -or 
        -Not ($UserHashes[0].PSObject.Properties.Name -contains 'Hash')) {
        throw "Erreur : Les objets doivent contenir les propriétés 'Username' et 'Hash'."
    }

    # Regrouper les hachages
    $groupedHashes = $UserHashes | Group-Object -Property Hash

    # Filtrer les groupes ayant des doublons
    $duplicates = $groupedHashes | Where-Object { $_.Count -gt 1 }

    # Vérifier s'il y a des doublons
    if (-Not $duplicates) {
        Write-Host "Aucun doublon trouvé."
        return @()
    }

    # Initialiser une liste pour les résultats
    $result = @()

    # Construire les objets pour chaque doublon
    foreach ($group in $duplicates) {
        $result += [PSCustomObject]@{
            Hash        = $group.Name
            Users       = ($group.Group | Select-Object -ExpandProperty Username) -join ", "
            UserCount   = $group.Count
        }
    }

    # Retourner les résultats
    return $result
}

function Export-DuplicatePasswords {
    <#
    .SYNOPSIS
    Exporte les comptes avec des mots de passe identiques dans un fichier CSV.
    .DESCRIPTION
    Prend en entrée une liste de doublons générée par `Find-DuplicatePasswords`
    et les exporte dans un fichier spécifié.
    .PARAMETER DuplicateData
    La liste des doublons à exporter.
    .PARAMETER OutputPath
    Chemin où le fichier CSV sera sauvegardé.
    .EXAMPLE
    Export-DuplicatePasswords -DuplicateData $duplicates -OutputPath '.\duplicates.csv'
    #>

    param (
        [Parameter(Mandatory)]
        [array]$DuplicateData,

        [Parameter(Mandatory)]
        [string]$OutputPath
    )

    # Vérifier si les doublons sont valides
    if (-Not $DuplicateData -or $DuplicateData.Count -eq 0) {
        throw "Erreur : Aucun doublon à exporter."
    }

    # Vérification des propriétés requises
    if (-Not ($DuplicateData[0].PSObject.Properties.Name -contains 'Hash') -or
        -Not ($DuplicateData[0].PSObject.Properties.Name -contains 'Users')) {
        throw "Erreur : Les données doivent contenir les propriétés 'Hash' et 'Users'."
    }

    # Exporter les données dans un fichier CSV
    try {
        $DuplicateData | Export-Csv -Path $OutputPath -NoTypeInformation -Encoding UTF8
        Write-Host "Les doublons ont été exportés avec succès vers : $OutputPath"
    } catch {
        throw "Erreur : Impossible d'exporter les données. Vérifiez le chemin ou les permissions."
    }
}

function New-SampleData {
    <#
    .SYNOPSIS
    Génère un fichier CSV contenant des données d'utilisateurs fictifs.
    .DESCRIPTION
    Crée un fichier CSV avec des colonnes 'Username' et 'Hash' contenant des données générées aléatoirement. Utile pour tester les fonctions du module.
    .PARAMETER OutputPath
    Chemin où le fichier CSV sera sauvegardé.
    .PARAMETER UserCount
    Nombre d'utilisateurs à inclure dans les données.
    .EXAMPLE
    New-SampleData -OutputPath '.\sample_data.csv' -UserCount 100
    #>

    param (
        [Parameter(Mandatory)]
        [string]$OutputPath,

        [Parameter(Mandatory)]
        [int]$UserCount
    )

    # Initialiser une liste d'utilisateurs
    $sampleData = @()
    $hashes = @("ABC123", "DEF456", "GHI789", "JKL012") # Exemple de hachages possibles

    for ($i = 1; $i -le $UserCount; $i++) {
        $username = "user$i"
        $hash = $hashes[(Get-Random -Minimum 0 -Maximum $hashes.Count)]
        $sampleData += [PSCustomObject]@{
            Username = $username
            Hash     = $hash
        }
    }

    # Exporter les données dans un fichier CSV
    try {
        $sampleData | Export-Csv -Path $OutputPath -NoTypeInformation -Encoding UTF8
        Write-Host "Fichier généré avec succès : $OutputPath"
    } catch {
        throw "Erreur : Impossible de générer les données. Vérifiez le chemin ou les permissions."
    }
}

Export-ModuleMember -Function Get-UserHashes, Find-DuplicatePasswords, Export-DuplicatePasswords, New-SampleData