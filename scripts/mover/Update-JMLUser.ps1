[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$UserPrincipalName,

    [Parameter(Mandatory = $true)]
    [ValidateSet(
        "Information Technology",
        "Engineering",
        "Finance",
        "Human Resources"
    )]
    [string]$NewDepartment,

    [Parameter(Mandatory = $true)]
    [string]$NewJobTitle
)

# Department-to-group RBAC mapping
$DepartmentGroupMap = @{
    "Information Technology" = "GRP-IT-Employees"
    "Engineering"            = "GRP-Engineering-Employees"
    "Finance"                = "GRP-Finance-Employees"
    "Human Resources"        = "GRP-HR-Employees"
}

$TargetGroup = $DepartmentGroupMap[$NewDepartment]

# Retrieve the current Entra ID user
try {
    $CurrentUser = Get-MgUser `
        -UserId $UserPrincipalName `
        -Property Id,DisplayName,UserPrincipalName,Department,JobTitle `
        -ErrorAction Stop

    if (-not $CurrentUser.Department) {
        throw "The user's current department is not defined."
    }

    if (-not $DepartmentGroupMap.ContainsKey($CurrentUser.Department)) {
        throw "The current department '$($CurrentUser.Department)' is not defined in the RBAC mapping."
    }

    $CurrentDepartment = $CurrentUser.Department
    $CurrentGroup = $DepartmentGroupMap[$CurrentDepartment]
    if ($CurrentDepartment -eq $NewDepartment) {
    Write-Host ""
    Write-Host "No department change detected."
    Write-Host "Current Department: $CurrentDepartment"
    Write-Host "Requested Department: $NewDepartment"
    Write-Host "No RBAC transition is required."
    exit 0
    }
}

catch {
    Write-Error "Failed to retrieve current user state: $($_.Exception.Message)"
    exit 1
}

# Validate current and target RBAC groups before making changes
try {
    $OldGroup = Get-MgGroup `
        -Filter "displayName eq '$CurrentGroup'" `
        -ErrorAction Stop

    $NewGroup = Get-MgGroup `
        -Filter "displayName eq '$TargetGroup'" `
        -ErrorAction Stop

    if (-not $OldGroup) {
        throw "Current RBAC group '$CurrentGroup' was not found."
    }

    if (-not $NewGroup) {
        throw "Target RBAC group '$TargetGroup' was not found."
    }

    if (@($OldGroup).Count -gt 1) {
        throw "Multiple groups named '$CurrentGroup' were found."
    }

    if (@($NewGroup).Count -gt 1) {
        throw "Multiple groups named '$TargetGroup' were found."
    }
}
catch {
    Write-Error "RBAC validation failed: $($_.Exception.Message)"
    exit 1
}


Write-Host "JML Mover Workflow"
Write-Host "User: $UserPrincipalName"
Write-Host "New Department: $NewDepartment"
Write-Host "New Job Title: $NewJobTitle"
Write-Host "Target RBAC Group: $TargetGroup"
Write-Host "Current Department: $CurrentDepartment"
Write-Host "Current RBAC Group: $CurrentGroup"

# Update employee attributes
Write-Host ""
Write-Host "Updating employee attributes..."

try {
    Update-MgUser `
        -UserId $CurrentUser.Id `
        -Department $NewDepartment `
        -JobTitle $NewJobTitle `
        -ErrorAction Stop

    Write-Host "Employee attributes updated successfully."
    Write-Host "Department: $NewDepartment"
    Write-Host "Job Title: $NewJobTitle"
}
catch {
    Write-Error "Failed to update employee attributes: $($_.Exception.Message)"
    exit 1
}

# Transition RBAC access
Write-Host ""
Write-Host "Transitioning RBAC access..."

try {   
    # Remove obsolete access
    Remove-MgGroupMemberByRef `
        -GroupId $OldGroup.Id `
        -DirectoryObjectId $CurrentUser.Id `
        -ErrorAction Stop

    Write-Host "Removed obsolete access: $CurrentGroup"

    # Assign new access
    $MemberReference = @{
        "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$($CurrentUser.Id)"
    }

    New-MgGroupMemberByRef `
        -GroupId $NewGroup.Id `
        -BodyParameter $MemberReference `
        -ErrorAction Stop

    Write-Host "Assigned new access: $TargetGroup"
    Write-Host ""
    Write-Host "Mover workflow completed successfully."
}
catch {
    Write-Error "Failed to transition RBAC access: $($_.Exception.Message)"
    exit 1
}
