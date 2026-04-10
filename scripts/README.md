# Script Operations Guide

This directory contains HAL extraction and update scripts used by the SciKey database foundation workflow.

Global project context is in [README.md](../README.md).

## Runtime Requirements

- Python 3.9+ (or equivalent modern Python 3.x)
- Python package: `requests`
- Network access to `https://api.archives-ouvertes.fr`
- Writable filesystem paths referenced by scripts

Example environment setup:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install requests
```

Run commands in this document from the repository root unless noted otherwise.

## Script Catalog

| Script | Purpose | Output | Notes |
|---|---|---|---|
| `api_test.py` | Quick HAL API connectivity/sample payload test. | `/mnt/database_data/api_response.json` | Small sample request (`rows=5`) for response shape validation. |
| `get_all_publications.py` | Bulk publication pagination collector (legacy flow). | `scripts/data/data_page_<n>.json` | Uses `rows=10000`, increments `start`, sleeps 61s between successful pages. |
| `get_all_publications_by_date.py` | Primary year-by-year publication collector. | `/mnt/database_data/date_full_search/data_<year>_page_<n>.json` and local log `get_all_publications_by_date_log.txt` | Starts at year 2026 and iterates downward; designed for long-running extraction. |
| `get_all_authors.py` | Author reference collector. | `scripts/authors/author_page_<n>.json` | Uses author endpoint and 30s sleep cadence. |
| `update_all_publications.py` | Post-collection enrichment/patch experiment for staged files. | Writes updated data under `/mnt/database_data/...` | Requires staged input files; review script behavior before production use. |
| `data_update_test.py` | Development/test harness for update logic exploration. | Console output, optional JSON test output | Contains exploratory/commented sections; not a production loader. |

## Suggested Execution Order

1. Validate endpoint and payload structure:

```bash
python3 api_test.py
```

2. Run primary extractor:

```bash
python3 get_all_publications_by_date.py
```

3. Optionally run update/enrichment experiments:

```bash
python3 update_all_publications.py
```

4. Optionally collect authors for side datasets:

```bash
python3 get_all_authors.py
```

## Required Directories

Create required directories before large runs:

```bash
mkdir -p scripts/data
mkdir -p scripts/authors
```

## Operational Caveats

- Scripts are file-based collectors; no built-in Oracle load step is included.
- Retry/checkpoint behavior is minimal; interrupted runs may require manual recovery.
- API throttling and timeout behavior can make full extraction long-running.
- Some script endpoints/URLs and paths are hardcoded.
- Validate script output before downstream import into database objects.

## Related Documentation

- Setup runbook: [setup/README.md](../setup/README.md)
- Benchmark/process evidence: [docs/gh_issue_29_solution.md](../docs/gh_issue_29_solution.md)
- Golden workload SQL: [docs/golden_queries.sql](../docs/golden_queries.sql)