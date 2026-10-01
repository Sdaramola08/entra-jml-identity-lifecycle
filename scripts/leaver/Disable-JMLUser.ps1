[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$UserPrincipalName
)

Write-Host "JML Leaver Workflow"
Write-Host "User: $UserPrincipalName"

# Retrieve the Entra ID user
try {
    $CurrentUser = Get-MgUser `
        -UserId $UserPrincipalName `
        -Property Id,DisplayName,UserPrincipalName,Department,JobTitle,AccountEnabled `
        -ErrorAction Stop

    Write-Host ""
    Write-Host "Current Identity State"
    Write-Host "Display Name: $($CurrentUser.DisplayName)"
    Write-Host "Department: $($CurrentUser.Department)"
    Write-Host "Job Title: $($CurrentUser.JobTitle)"
    Write-Host "Account Enabled: $($CurrentUser.AccountEnabled)"
}
catch {
    Write-Error "Failed to retrieve Entra ID user: $($_.Exception.Message)"
    exit 1
}

# Discover current group memberships
try {
    $GroupMemberships = Get-MgUserMemberOf `
        -UserId $CurrentUser.Id `
        -All `
        -ErrorAction Stop

    Write-Host ""
    Write-Host "Current Group Access"

    if (@($GroupMemberships).Count -eq 0) {
        Write-Host "No group memberships found."
    }
    else {
        foreach ($Membership in $GroupMemberships) {
            $Group = Get-MgGroup `
                -GroupId $Membership.Id `
                -ErrorAction Stop

            Write-Host "Group: $($Group.DisplayName)"
        }
    }
}
catch {
    Write-Error "Failed to retrieve current group access: $($_.Exception.Message)"
    exit 1
}
# Disable the Entra ID account
Write-Host ""
Write-Host "Disabling Entra ID account..."

try {
    Update-MgUser `
        -UserId $CurrentUser.Id `
        -AccountEnabled:$false `
        -ErrorAction Stop

    Write-Host "Account disabled successfully."
}
catch {
    Write-Error "Failed to disable Entra ID account: $($_.Exception.Message)"
    exit 1
}
# Revoke active sign-in sessions
Write-Host ""
Write-Host "Revoking active sign-in sessions..."

try {
    Revoke-MgUserSignInSession `
        -UserId $CurrentUser.Id `
        -ErrorAction Stop | Out-Null

    Write-Host "Active sign-in sessions revoked successfully."
}
catch {
    Write-Error "Failed to revoke active sign-in sessions: $($_.Exception.Message)"
    exit 1
}
# Remove group-based access
Write-Host ""
Write-Host "Removing group-based access..."

try {
    if (@($GroupMemberships).Count -eq 0) {
        Write-Host "No group memberships require removal."
    }
    else {
        foreach ($Membership in $GroupMemberships) {

            $Group = Get-MgGroup `
                -GroupId $Membership.Id `
                -ErrorAction Stop

            Remove-MgGroupMemberByRef `
                -GroupId $Group.Id `
                -DirectoryObjectId $CurrentUser.Id `
                -ErrorAction Stop

            Write-Host "Removed access: $($Group.DisplayName)"
        }
    }

    Write-Host "Group-based access removal completed successfully."
}
catch {
    Write-Error "Failed to remove group-based access: $($_.Exception.Message)"
    exit 1
}
# Validate final deprovisioned state
Write-Host ""
Write-Host "Validating final deprovisioned state..."

try {
    $ValidatedUser = Get-MgUser `
        -UserId $CurrentUser.Id `
        -Property Id,DisplayName,UserPrincipalName,AccountEnabled `
        -ErrorAction Stop

    $RemainingMemberships = Get-MgUserMemberOf `
        -UserId $CurrentUser.Id `
        -All `
        -ErrorAction Stop

    Write-Host ""
    Write-Host "Final Leaver Validation"
    Write-Host "User: $($ValidatedUser.DisplayName)"
    Write-Host "Account Enabled: $($ValidatedUser.AccountEnabled)"
    Write-Host "Remaining Group Memberships: $(@($RemainingMemberships).Count)"

    if ($ValidatedUser.AccountEnabled -eq $false -and
        @($RemainingMemberships).Count -eq 0) {

        Write-Host ""
        Write-Host "Leaver workflow completed successfully."
    }
    else {
        throw "Final deprovisioning validation failed."
    }
}
catch {
    Write-Error "Failed final Leaver validation: $($_.Exception.Message)"
    exit 1
}
