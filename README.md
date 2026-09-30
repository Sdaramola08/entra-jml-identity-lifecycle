# Microsoft Entra ID JML Identity Lifecycle Automation

## Overview

This project demonstrates the implementation of a Joiner-Mover-Leaver (JML) identity lifecycle workflow using Microsoft Entra ID, Microsoft Graph, and PowerShell.

The goal of the project is to simulate how an IAM engineer manages identities throughout the employee lifecycle while enforcing role-based access control (RBAC), least privilege, and secure account deprovisioning.

## Technologies

- Microsoft Entra ID
- Microsoft Graph
- PowerShell
- Role-Based Access Control (RBAC)
- Multi-Factor Authentication (MFA)

## JML Lifecycle

### Joiner
Provision a new employee identity and assign access based on the employee's role and department.

### Mover
Modify an existing employee's access when their role or department changes while removing permissions that are no longer required.

### Leaver
Disable the employee identity, revoke access, and remove group memberships when the employee leaves the organization.

## Project Objectives

- Design an IAM lifecycle management workflow
- Automate identity provisioning with PowerShell
- Implement role-based access
- Apply least-privilege principles
- Manage group memberships
- Demonstrate secure deprovisioning
- Document identity lifecycle events
- Produce auditable evidence of access changes

## Architecture

Architecture documentation will be added as the project is developed.

## Project Status

🚧 In Progress
