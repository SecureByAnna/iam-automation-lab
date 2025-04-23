<#
.SYNOPSIS
    Disables Active Directory users who have been inactive for 90+ days.

.DESCRIPTION
    This script finds enabled users who haven't logged in for more than 90 days
    and disables them. Includes logging and dry-run mode.

.NOTES
    Author: SecureByAnna
    Date: $(Get-Date -Format "yyyy-MM-dd")
#>

# Parameters
param(
    [int]$InactiveDays = 90,
    [switch]$DryRun
)

# Output Paths
$logPath = ".\disabled_users_log.txt"
$timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
"--- User Disable Log - $timestamp ---`n" | Out-File -FilePath $logPath

# Cutoff Date
$cutoff = (Get-Date).AddDays(-$InactiveDays)

# Get Users
$staleUsers = Get-ADUser -Filter {
    Enabled -eq $true -and LastLogonDate -lt $cutoff
} -Properties LastLogonDate

# Process Each Stale User
foreach ($user in $staleUsers) {
    $msg = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Found: $($user.SamAccountName), Last Login: $($user.LastLogonDate)"
    $msg | Out-File -Append -FilePath $logPath
    Write-Host $msg -ForegroundColor Yellow

    if (-not $DryRun) {
        Disable-ADAccount -Identity $user
        "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Disabled: $($user.SamAccountName)" | Out-File -Append -FilePath $logPath
        Write-Host "Disabled: $($user.SamAccountName)" -ForegroundColor Green
    }
}

Write-Host "`nComplete. Log saved to $logPath" -ForegroundColor Cyan