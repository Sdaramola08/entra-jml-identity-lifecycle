# JML Access Control Matrix

## Purpose

This document defines the baseline role-based access control (RBAC) model used by the JML identity lifecycle workflow.

Users receive access based on their department. Departmental access is assigned through Microsoft Entra ID security groups rather than through direct user permissions.

This design supports least privilege and simplifies Joiner, Mover, and Leaver operations.

## Department Access Matrix

| Department | Security Group | Access Model |
|---|---|---|
| Information Technology | GRP-IT-Employees | Baseline IT department access |
| Engineering | GRP-Engineering-Employees | Baseline Engineering department access |
| Finance | GRP-Finance-Employees | Baseline Finance department access |
| Human Resources | GRP-HR-Employees | Baseline HR department access |

## Joiner Rule

When a new employee is provisioned, the JML workflow evaluates the employee's department and assigns the corresponding security group.

Example:

Department: Information Technology

Assigned Group:

GRP-IT-Employees

## Mover Rule

When an employee changes departments:

1. Remove the employee from their previous departmental group.
2. Update the employee's department attribute.
3. Add the employee to the new departmental group.
4. Validate the resulting access.

Example:

Finance → Information Technology

Remove:

GRP-Finance-Employees

Add:

GRP-IT-Employees

## Leaver Rule

When an employee leaves the organization:

1. Disable the employee account.
2. Revoke active authentication sessions.
3. Remove departmental group memberships.
4. Remove assigned access.
5. Preserve required identity information for auditing.
6. Validate that the employee can no longer authenticate.

## Security Principles

This access model follows:

- Role-Based Access Control (RBAC)
- Least Privilege
- Group-Based Access Management
- Separation of Duties
- Identity Lifecycle Management
- Auditable Access Changes
