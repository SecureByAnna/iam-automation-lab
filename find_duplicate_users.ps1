<#
.SYNOPSIS
    Finds potential duplicate user accounts in Active Directory.

.DESCRIPTION
    This script checks for AD users with matching or similar
    first names, last names, or display names to identify potential duplicates.

.NOTES
    Author: SecureByAnna
    Date: $(Get-Date -Format "yyyy-MM-dd")
#>

# Load users from AD
$users = Get-ADUser -Filter * -Properties GivenName, Surname, DisplayName, UserPrincipalName

# Group by full name
$duplicates = $users | Group-Object { "$($_.GivenName)|$($_.Surname)" } | Where-Object { $_.Count -gt 1 }

# Prepare results
$results = foreach ($group in $duplicates) {
    foreach ($user in $group.Group) {
        [PSCustomObject]@{
            GivenName = $user.GivenName
            Surname = $user.Surname
            DisplayName = $user.DisplayName
            SamAccountName = $user.SamAccountName
            UPN = $user.UserPrincipalName
        }
    }
}

# Export to CSV
$results | Export-Csv -Path ".\duplicate_users_report.csv" -NoTypeInformation -Encoding UTF8

Write-Host "`nPossible duplicate users saved to duplicate_users_report.csv" -ForegroundColor Cyan
