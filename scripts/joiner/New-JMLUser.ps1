[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$FirstName,

    [Parameter(Mandatory = $true)]
    [string]$LastName,

    [Parameter(Mandatory = $true)]
    [ValidateSet(
        "Information Technology",
        "Engineering",
        "Finance",
        "Human Resources"
    )]
    [string]$Department,

    [Parameter(Mandatory = $true)]
    [string]$JobTitle,

    [Parameter(Mandatory = $true)]
    [string]$EmployeeId,

    [Parameter(Mandatory = $true)]
    [string]$TenantDomain

)

# Department-to-group RBAC mapping
$DepartmentGroupMap = @{
    "Information Technology" = "GRP-IT-Employees"
    "Engineering"            = "GRP-Engineering-Employees"
    "Finance"                = "GRP-Finance-Employees"
    "Human Resources"        = "GRP-HR-Employees"
}

$TargetGroup = $DepartmentGroupMap[$Department]

# Generate identity attributes
$DisplayName = "$FirstName $LastName"
$MailNickname = ("$FirstName.$LastName").ToLower()
$UserPrincipalName = "$MailNickname@$TenantDomain"

# Generate a temporary password
$PasswordChars = "abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789!@#$%"
$TemporaryPassword = -join ((1..16) | ForEach-Object {
    $PasswordChars[(Get-Random -Maximum $PasswordChars.Length)]
})

$PasswordProfile = @{
    Password = $TemporaryPassword
    ForceChangePasswordNextSignIn = $true
}

Write-Host "JML Joiner Workflow"
Write-Host "UPN: $UserPrincipalName"
Write-Host "Employee: $FirstName $LastName"
Write-Host "Employee ID: $EmployeeId"
Write-Host "Department: $Department"
Write-Host "Job Title: $JobTitle"
Write-Host "RBAC Group: $TargetGroup"

# Create the Entra ID user
Write-Host ""
Write-Host "Creating Entra ID user..."

try {
    $NewUser = New-MgUser `
        -AccountEnabled:$true `
        -DisplayName $DisplayName `
        -MailNickname $MailNickname `
        -UserPrincipalName $UserPrincipalName `
        -GivenName $FirstName `
        -Surname $LastName `
        -JobTitle $JobTitle `
        -Department $Department `
        -EmployeeId $EmployeeId `
        -PasswordProfile $PasswordProfile `
        -ErrorAction Stop

    Write-Host "User created successfully."
    Write-Host "Display Name: $($NewUser.DisplayName)"
    Write-Host "UPN: $($NewUser.UserPrincipalName)"
    Write-Host "Object ID: $($NewUser.Id)"
}
catch {
    Write-Error "Failed to create Entra ID user: $($_.Exception.Message)"
    exit 1
}

# Assign RBAC group based on department
Write-Host ""
Write-Host "Assigning RBAC group..."

try {
    $Group = Get-MgGroup `
        -Filter "displayName eq '$TargetGroup'" `
        -ErrorAction Stop

    if (-not $Group) {
        throw "RBAC group '$TargetGroup' was not found."
    }

    if (@($Group).Count -gt 1) {
        throw "Multiple groups named '$TargetGroup' were found."
    }

    $MemberReference = @{
        "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$($NewUser.Id)"
    }

    New-MgGroupMemberByRef `
        -GroupId $Group.Id `
        -BodyParameter $MemberReference `
        -ErrorAction Stop

    Write-Host "RBAC group assigned successfully."
    Write-Host "Group: $TargetGroup"
}
catch {
    Write-Error "Failed to assign RBAC group: $($_.Exception.Message)"
    exit 1
}
