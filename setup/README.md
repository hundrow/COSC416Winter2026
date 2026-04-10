# Database Setup Runbook

This directory contains Oracle bootstrap assets for the SciKey HAL database foundation.

Project-wide context is in [README.md](../README.md).

## Setup Assets

| File | Purpose |
|---|---|
| [create_structure.sql](create_structure.sql) | Creates HAL schema objects, grants, and core table structures. |
| [tablespaces_setup.sql](tablespaces_setup.sql) | Snapshot output of system tablespace DDL (reference artifact). |
| [database_params.ora](database_params.ora) | Captured instance parameter baseline used in project environment. |

## Prerequisites

- Oracle Database 19c instance and target PDB available.
- Privileged account access (SYSDBA or equivalent) for bootstrap steps.

Run commands in this document from the repository root unless noted otherwise.

## Execution Order

1. Run schema/object creation script:

```bash
sqlplus / as sysdba @setup/create_structure.sql
```

2. Validate resulting objects and storage:

```sql
SELECT table_name FROM dba_tables WHERE owner = 'HAL';
SELECT default_tablespace FROM dba_users WHERE username = 'HAL';
SELECT segment_name, segment_type, tablespace_name
FROM dba_segments
WHERE owner = 'HAL';
```

## Security and Privilege Notes

- Current setup scripts are tuned for course/project velocity and include broad grants.
- For non-course deployments, replace broad grants with least-privilege roles.
- Do not keep default/test credentials in shared or production environments.

## Operational Notes

- [tablespaces_setup.sql](tablespaces_setup.sql) is a captured reference artifact and not a full environment provisioning script.
- [database_params.ora](database_params.ora) documents one tested environment baseline; re-tune for different hardware profiles.
- Backup/restore automation is not provided in this repository.

## Related Documentation

- Main onboarding: [README.md](../README.md)
- Documentation index: [docs/README.md](../docs/README.md)
- Script operations: [scripts/README.md](../scripts/README.md)