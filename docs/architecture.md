# JML Identity Lifecycle Architecture

## Overview

This project implements an automated Joiner-Mover-Leaver identity lifecycle
using Microsoft Entra ID, Microsoft Graph, and PowerShell.

The workflow uses employee attributes such as department to determine
group-based access according to a predefined RBAC model.

## Architecture

```mermaid
flowchart TD
    A[HR / Employee Lifecycle Event] --> B[PowerShell JML Automation]

    B --> C{Lifecycle Event}

    C -->|Joiner| D[New-JMLUser.ps1]
    C -->|Mover| E[Update-JMLUser.ps1]
    C -->|Leaver| F[Disable-JMLUser.ps1]

    D --> G[Microsoft Graph]
    E --> G
    F --> G

    G --> H[Microsoft Entra ID]

    H --> I[User Identity]
    H --> J[Security Groups / RBAC]

    D --> K[Create Identity]
    D --> L[Assign Department RBAC Group]

    E --> M[Update Identity Attributes]
    E --> N[Remove Obsolete Access]
    E --> O[Assign New RBAC Access]

    F --> P[Disable Account]
    F --> Q[Revoke Sessions]
    F --> R[Remove Group Access]
    F --> S[Validate Deprovisioning]
