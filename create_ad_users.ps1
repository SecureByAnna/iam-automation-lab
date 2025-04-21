# create_ad_users.ps1
# Description: Bulk creates Active Directory users from a CSV file

# Import the CSV
$csvPath = ".\new_users.csv"
if (!(Test-Path $csvPath)) {
    Write-Host "CSV file not found at path: $csvPath" -ForegroundColor Red
    exit
}
$users = Import-Csv -Path $csvPath

# Set domain context (update as needed)
$ouPath = "OU=Users,DC=yourdomain,DC=com"

# Log file setup
$logFile = ".\create_users_log.txt"
"--- User Creation Log - $(Get-Date) ---`n" | Out-File -FilePath $logFile

foreach ($user in $users) {
    try {
        $samAccountName = $user.Username
        $displayName = "$($user.FirstName) $($user.LastName)"
        $userPrincipalName = "$samAccountName@yourdomain.com"

        # Check if user already exists
        if (Get-ADUser -Filter {SamAccountName -eq $samAccountName}) {
            "$displayName already exists. Skipped." | Out-File -Append $logFile
            continue
        }

        # Create new user
        New-ADUser `
            -Name $displayName `
            -GivenName $user.FirstName `
            -Surname $user.LastName `
            -SamAccountName $samAccountName `
            -UserPrincipalName $userPrincipalName `
            -Department $user.Department `
            -Title $user.Title `
            -AccountPassword (ConvertTo-SecureString "TempPass123!" -AsPlainText -Force) `
            -Path $ouPath `
            -Enabled $true

        "$displayName created successfully." | Out-File -Append $logFile
    }
    catch {
        "Failed to create $($user.FirstName) $($user.LastName): $_" | Out-File -Append $logFile
    }
}

Write-Host "User creation complete. Check log: $logFile" -ForegroundColor Green
