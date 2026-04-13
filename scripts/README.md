# Scripts Developer Guide

This directory includes one supported data collection script and several legacy/test scripts.

Global project context: [README.md](../README.md)

## Current Status

- Supported for normal use: `get_all_publications_by_date.py`
- Not supported for production use: all other `.py` scripts in this directory (`api_test.py`, `data_update_test.py`, `get_all_publications.py`, `update_all_publications.py`, `get_all_authors.py`)

## Supported Script

### `get_all_publications_by_date.py`

Primary extractor that pulls HAL records year-by-year and paginates results.

Behavior summary:
- Starts from the current year (`datetime.date.today().year`) and decrements down to year 1
- Queries HAL-UPEC search API with `https://api.archives-ouvertes.fr/search?rows=10000&indent=true&wt=json&fl=label_s,abstract_s,docid,collection_t,uri_s,collCode_s,keyword_s,authFullName_s,title_s,domainAll_s,domainAllCode_s,en_domainAllCodeLabel_fs,fr_domainAllCodeLabel_fs,publicationDateY_i,publicationDateM_i,publicationDateD_i&start={start}&fq=submittedDateY_i:[{year} TO {year + 1}]`
- Writes files to `/mnt/database_data/date_full_search/data_<year>_page_<n>.json`
- Appends run progress to `get_all_publications_by_date_log.txt` in this directory

Run from repository root:

```bash
python3 scripts/get_all_publications_by_date.py
```

Minimum setup:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r scripts/requirements.txt
mkdir -p /mnt/database_data/date_full_search
```

### List of all parameters used and their purpose:
- rows=10000
    - Maximum allowed value of amount of returned records
- indent=true
    - Formats the returned JSON in a more human readable format
- wt=json
    - Specifies to return JSON format response
- start={start}
    - The number to start at during the pagination of the request
- fq=submittedDateY_i:[{year} TO {year+1}]
    - the publication date years to query
- fl=label_s,abstract_s,docid,collection_t,uri_s,collCode_s,keyword_s,authFullName_s,title_s,domainAll_s,domainAllCode_s,en_domainAllCodeLabel_fs,fr_domainAllCodeLabel_fs,publicationDateY_i,publicationDateM_i,publicationDateD_i&start={start}&fq=submittedDateY_i:[{year} TO {year + 1}]
    - fl&emsp;&emsp;Parameter to return specific fields of the publications
    - label_s &emsp;&emsp;Authors, title, publication date and URI in one field
    - abstract_s &emsp;&emsp;The publications abstract if it has one
    - docid &emsp;&emsp;UPEC's unique id for the publication
    - collection_t &emsp;&emsp;nothing is returned
    - uri_s&emsp;&emsp;Link to the publication
    - collCode_s&emsp;&emsp;List of universities associated with the publication
    - keyword_s&emsp;&emsp;List of user defined keywords associated with publication if they exist
    - authFullName_s&emsp;&emsp;List of all authors for the publication
    - title_s&emsp;&emsp;List of titles of the publication in English, French or both
    - domainAllCode_s &emsp;&emsp;List of shorthand domains associated with the publication
    - en_domainAllCodeLabel_fs &emsp;&emsp;List of full domains associated with publication in English
    - fr_domainAlLCodeLabel_fs&emsp;&emsp;List of full domains associated with publicatin in French
    - publicationDateY_i&emsp;&emsp;Publication year (default value appears to be 1700)
    - publicationDateM_i&emsp;&emsp;Publication month (default value appears to be 0)
    - publicationDateD_i&emsp;&emsp;Publication Day (default value appears to be 0)

### Modifications

**Changing the filepath of the saved JSON files**

On line 43 change the filepath variable to your desired filepath
-  `filepath = f'/mnt/database_data/date_full_search/data_{year}_page_{count}.json'` change to  `filepath = f'{YOUR FILEPATH}/data_{year}_page_{count}.json'`

**Adding or removing fields from the request**


On line 9 change the url_path variable, add or remove fields in the fl parameter, a full list of available fields can be found in the UPEC documentation here https://api.archives-ouvertes.fr/docs/search/?schema=fields#fields

**Changing the year to start collection at**

In case of an uncompleted data collection process change the year variable on line 7 to the last year data was collected from, seen in either the terminal window or `get_all_publications_by_date_log.log`

## Unsupported Scripts (Legacy, Test, or Broken)

These files are kept for reference only and should not be treated as maintained workflows.

### `api_test.py`
- Test-only connectivity/sample script
- Contains non-portable output path assumptions (`/mnt/database_data/...`)
- Use only to test parameters and formatting 

### `data_update_test.py`
- Local exploratory test harness
- Depends on ad-hoc local files and partially commented experimental logic

### `get_all_publications.py`
- Legacy collector superseded by the date-based collector
- Uses hard-coded pagination offsets and no longer represents the maintained process
- Caused timeouts on data collection after about 300000 records

### `get_all_authors.py`
- Legacy author collector
- Uses older endpoint/assumptions and is not part of current supported pipeline
- Partially tested, and does collect a list of authors

### `update_all_publications.py`
- Experimental enrichment script
- Contains logic issues (for example, attempts `append` on a dict) and should be considered broken until refactored
- Purpose was to update data field without pulling all data 

## Developer Notes

- Scripts are file collectors only; no direct Oracle load is performed here.
- Paths are currently hard-coded in places (`/mnt/database_data/...`).
- For reproducibility, treat only `get_all_publications_by_date.py` as authoritative.
- Full data collection takes roughly 8 hours, and all files take up roughly 25GB

## Related Documentation

- Setup runbook: [setup/README.md](../setup/README.md)
- HAL Search API documentation: https://api.archives-ouvertes.fr/docs/search