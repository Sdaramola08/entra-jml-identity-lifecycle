# Leaver Automation

PowerShell automation used to securely deprovision employee identities when they leave the organization.

The Leaver workflow will include:

- Disable the user account
- Revoke active sessions
- Remove group memberships
- Remove assigned access
- Block future authentication
- Preserve required audit information
- Validate successful deprovisioning
