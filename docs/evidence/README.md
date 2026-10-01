# JML Workflow Validation Evidence

This directory documents validation results from the Microsoft Entra ID
Joiner-Mover-Leaver automation project.

All identities used in this project are lab identities created specifically
for testing.

Tenant-specific identifiers, passwords, authentication tokens, and other
sensitive values are intentionally excluded from this repository.

---

## Test Identity

**Employee:** Taylor Morgan  
**Employee ID:** EMP1002

The identity was used to validate the complete employee lifecycle.

---

# 1. Joiner Validation

Initial employee configuration:

- Department: Finance
- Job Title: Financial Analyst
- RBAC Group: GRP-Finance-Employees
- Account Status: Enabled

The Joiner workflow successfully:

1. Created the Entra ID identity.
2. Populated employee attributes.
3. Determined required access from the department.
4. Assigned the Finance RBAC group.
5. Returned the created identity information.

### Result

**PASS**

The employee was provisioned with the expected Finance access.

---

# 2. Mover Validation

The employee was transferred from:

**Finance → Engineering**

The job title changed from:

**Financial Analyst → Systems Engineer**

The Mover workflow successfully:

1. Retrieved the existing identity.
2. Determined the employee's current department.
3. Updated the department to Engineering.
4. Updated the job title to Systems Engineer.
5. Removed GRP-Finance-Employees.
6. Assigned GRP-Engineering-Employees.
7. Preserved the employee identity and Employee ID.
8. Prevented unnecessary RBAC changes when the workflow was rerun with the
   same department.

### Result

**PASS**

Obsolete Finance access was removed and Engineering access was assigned.

---

# 3. Leaver Validation

The Leaver workflow successfully:

1. Retrieved the existing employee identity.
2. Inventoried current group-based access.
3. Disabled the Entra ID account.
4. Revoked active sign-in sessions.
5. Removed group-based access.
6. Preserved the identity record for audit/history.
7. Validated the final deprovisioned state.

Final validation:

- Account Enabled: False
- Remaining Group Memberships: 0

The workflow was executed again against the already-deprovisioned identity
and completed safely without restoring access.

### Result

**PASS**

The identity remained available for audit purposes while authentication and
group-based access were removed.

---

# Security Controls Demonstrated

This lab demonstrates:

- Identity lifecycle management
- Role-Based Access Control (RBAC)
- Least privilege
- Group-based authorization
- Automated provisioning
- Automated access modification
- Automated deprovisioning
- Session revocation
- Access validation
- Safe workflow reruns
- Error handling
- Audit-oriented identity retention

---

## Lifecycle Result

JOINER → MOVER → LEAVER

Provision → Modify Access → Deprovision

**End-to-end JML workflow successfully validated.**
