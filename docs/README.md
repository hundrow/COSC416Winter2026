# Documentation Index

This directory contains requirements, benchmark evidence, SQL assets, sample API payloads, and report artifacts for the SciKey HAL metadata database foundation.

For repository onboarding and operational boundaries, start with [README.md](../README.md).

## Start Here

- Project onboarding: [README.md](../README.md)
- Database setup runbook: [setup/README.md](../setup/README.md)
- Script execution runbook: [scripts/README.md](../scripts/README.md)

## Requirements and Project Framing

- [RFP.md](RFP.md): formal proposal, scope boundaries, and role expectations.
- [project description.md](project%20description.md): original project statement from SciKey context.
- [github_issues_catalog.md](github_issues_catalog.md): issue catalog and project tracking context.

## Performance and Transition Evidence

- [golden_queries.sql](golden_queries.sql): query set used for benchmark timing and execution plan consistency checks.

## SQL and Database Utility Assets

Related setup files are stored in [setup](../setup):
- [setup/create_structure.sql](../setup/create_structure.sql)
- [setup/tablespaces_setup.sql](../setup/tablespaces_setup.sql)
- [setup/database_params.ora](../setup/database_params.ora)

## API Response and Test Artifacts

- [api_response_example.json](api_response_example.json): representative HAL API response sample.
- [api_response_timeout.json](api_response_timeout.json): timeout/error behavior sample.
- [test.json](test.json): additional JSON test artifact.
- [update_test.json](update_test.json): test output artifact for update flow experiments.

## Notes for Production Documentation

- If you add new benchmark evidence files (AWR exports, host telemetry logs), place them under `docs/` and add them to this index.