# SciKey HAL Metadata Platform

COSC 416 Winter 2026 SciKey database.

This repository currently delivers the Oracle data platform layer and HAL metadata collection scripts used to build and benchmark a publication catalog. It is designed for developer/DBA onboarding and reproducible baseline testing.

## Current Status

This release is **Phase 1: database foundation**.

Implemented now:
- Oracle 19c schema and physical design for HAL publication metadata.
- HAL API metadata extraction scripts (JSON staging workflow).
- Golden query workload and baseline performance evidence.

## Implemented Scope

### 1. Database Architecture
- Partitioned core table: `RESEARCH_ARTICLES` (partitioned by `PUBLISH_YEAR`).
- Child tables for abstracts, authors, keywords, domains, and collections.
- Materialized summary tables for common analytical patterns.
- DDL and setup assets in [setup/create_structure.sql](setup/create_structure.sql).

### 2. HAL Metadata Collection
- Python extraction scripts that pull from `https://api.archives-ouvertes.fr/search`.
- Year-sliced bulk extraction and file-based staging in `/mnt/database_data/date_full_search/`.
- Operational scripts cataloged in [scripts/README.md](scripts/README.md).

### 3. Performance Gate Evidence
- Baseline process and SLO evidence in [docs/gh_issue_29_solution.md](docs/gh_issue_29_solution.md).
- Golden query definitions and timing comments in [docs/golden_queries.sql](docs/golden_queries.sql).
- Methodology aligns to top-down Oracle tuning used in project documentation.

## Repository Layout

| Path | Purpose |
|---|---|
| [README.md](README.md) | Project-level onboarding and operational boundaries. |
| [docs](docs) | Requirements, benchmark evidence, and report artifacts. |
| [scripts](scripts) | HAL extraction/update scripts and ingestion-side utilities. |
| [setup](setup) | Oracle schema/bootstrap assets and instance parameter snapshot. |
| [LICENSE](LICENSE) | MIT license terms. |

## Prerequisites

### Platform
- Oracle Linux host machine.
- Oracle Database 19c instance with access to target PDB.
- Python 3.9+ (or equivalent modern Python 3.x).

### Python dependencies
- `requests`

Install example:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install requests
```

## Quick Start (Developer/DBA)

### 1. Review setup and script guides
- Database bootstrap guide: [setup/README.md](setup/README.md)
- Script operations guide: [scripts/README.md](scripts/README.md)

### 2. Create schema and storage objects
Run as a privileged Oracle account:

```bash
sqlplus / as sysdba @setup/create_structure.sql
```

### 3. Validate schema objects
Use SQL*Plus/SQLcl to confirm tables and tablespace placement:

```sql
SELECT table_name FROM dba_tables WHERE owner = 'HAL';
SELECT default_tablespace FROM dba_users WHERE username = 'HAL';
```

### 4. Run metadata collection

```bash
cd scripts
python3 get_all_publications_by_date.py
```
### 5. Insert data into the DB

```bash
# TODO: Insert command to insert data into HAL users database.
```

### 6. Run baseline query set

```bash
# TODO: Insert the command to run the baseline db load using golden queries.
```

## Baseline Performance Snapshot (Current Evidence)

Source: [docs/gh_issue_29_solution.md](docs/gh_issue_29_solution.md), [docs/golden_queries.sql](docs/golden_queries.sql)

| Metric | Current documented value |
|---|---|
| Worst observed Golden Query latency in 3-run set | 0.161 s |
| Throughput baseline | 72 user calls/min |
| Avg host CPU during baseline window | 52.17% |
| Avg storage await (`xvdb`) | 5.04 ms |
| Top non-idle wait event share | 3.3% (`direct path read`) |

These metrics are baseline evidence for the current workload profile, not a guarantee for all future data volumes or concurrency levels.

## Known Limitations

- No fully automated JSON-to-Oracle loader is included yet.
- Collection scripts include hardcoded paths and basic retry behavior.
- Bulk extraction can run for long durations due to paging and inter-request delays.
- Throughput target discussions in project docs include draft thresholds; validate against your own environment before production sign-off.
- Security hardening beyond baseline setup (least privilege refinement, audit policy expansion, encryption lifecycle ops) is not fully automated in this repository.

## Security and Credential Notes

- SQL setup scripts currently assume privileged execution and create a high-privilege schema user.
- Replace default/local credentials before any real deployment.
- Restrict grants and quotas to least privilege for non-course environments.

## Documentation Map

- Main documentation index: [docs/README.md](docs/README.md)
- Script runbook: [scripts/README.md](scripts/README.md)
- Setup runbook: [setup/README.md](setup/README.md)
- Project proposal and boundaries: [docs/RFP.md](docs/RFP.md)

## Roadmap

Planned next major additions:
- Robust ingest pipeline from staged JSON into Oracle target tables.
- NLP/LLM keyword extraction and confidence scoring workflow.
- Wikidata/BNF enrichment integration.
- Application/API layer for researcher search and export.

## License

Distributed under the MIT License. See [LICENSE](LICENSE).