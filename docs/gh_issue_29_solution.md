# Issue #29 - Performance-Centric Transition Plan

## #29 - Transition/Deployment 1 - Performance-Centric Transition Plan

- URL: https://github.com/hundrow/COSC416Winter2026/issues/29
- Description:

The transition from construction to operations in COSC 416 requires a "Performance Gate." The system is not considered "operational" until it meets the predefined service-level objectives (SLOs).

- [ ] Baseline Performance Review: Before sign-off, teams must provide a baseline report (AWR, Query Store, or Profiler) demonstrating the system's "healthy" state. This serves as the benchmark for future troubleshooting.
- [ ] Capacity & Scalability Plan: Document the "breaking point" of the current configuration. Based on your stress tests, at what point will the CPU or I/O subsystem require an upgrade?
- [ ] Operational Runbooks (Tuning Focus): Provide specific instructions for common performance issues identified during the construction phase (e.g., "If Wait Event X appears, execute Reindex Script Y").
- [ ] Knowledge Transfer (Root Cause Analysis): Conduct a session focused on the Execution Plans of the most critical queries to ensure the maintenance team understands the intended data access paths.

## Phase 0: Define the Performance Gate (SLO)
Goal: set the pass/fail criteria before testing.

The system is not considered operational until all SLO targets below pass during the agreed baseline window.

| SLO ID | Metric | Target (Pass Criteria) | Measurement Source | Test Window | Status |
|---|---|---|---|---|---|
| SLO-1 | Golden Query latency (P95) | <= 1.5 s at nominal load | SQL Developer query timing + OEM SQL Monitoring | 15 min steady-state | Pending baseline run |
| SLO-2 | Throughput | TBD by course/project criteria (draft placeholder was >= 120 requests/min) | Workload driver cycle/request rate + OEM DB throughput | 15 min steady-state | Baseline documented |
| SLO-3 | Host CPU saturation | <= 75% average CPU utilization | Linux `sar -u`, `vmstat`, OEM Host CPU | 15 min steady-state | Pending baseline run |
| SLO-4 | Storage latency | <= 20 ms average await on active DB disk | Linux `iostat -xz`, OEM I/O metrics | 15 min steady-state | Pending baseline run |
| SLO-5 | Top wait-event pressure | No single non-idle wait event > 25% DB time | AWR report + OEM Top Activity | Snapshot pair around test | At risk from prior snapshot |
| SLO-6 | Plan stability (critical SQL) | Same plan hash across 3 repeated runs per Golden Query | SQL Developer Explain Plan + AWR SQL section | 3-run validation | Pending baseline run |

### Environment Baseline
- DB: ORCL, Oracle 19c Enterprise, CDB = YES, OPEN_MODE = READ WRITE, LOG_MODE = NOARCHIVELOG.
- Instance: cdb1 on host cosc-ora.
- AWR snapshots available hourly and recent enough for bracketing baseline windows.

### Current Risk Signals (Pre-baseline)
- Top non-idle wait observed: free buffer waits (Configuration) with highest waited time in current snapshot.
- Additional high waits: direct path write temp, local write wait, control file parallel write.
- Interpretation: current system behavior suggests memory/buffer or write-path pressure under workload, so SLO-5 is risk-prone until validated in a controlled baseline interval.

### Top SQL Signals (HAL schema)
- High elapsed SQL IDs observed include:
dzq5p8kvryx86, 6ymkph9ukt8pj, 1d87tbb8tw990, 29ncfz4uzkf0f, 9fndv6q3mqzc7.
- These are candidates for SLO-6 plan stability checks and knowledge-transfer walkthroughs.

## Stop Point A Documentation Checklist

- [x] Final SLO thresholds drafted.
- [x] Golden Query list and representative seed values defined.
- [x] Nominal workload profile defined.
- [x] Measurement tooling and command set identified.
- [x] Known constraints documented.

## Measurement Command Set (Locked for Baseline Session)

### Linux
- `sar -u 1 900 > perf_logs/cpu_utilization.log &`
- `vmstat 1 900 > perf_logs/resource_state.log &`
- `iostat -xz 1 900 > perf_logs/disk_io.log &`

### SQL / Oracle
- Capture AWR snapshots before/after window (from DBA_HIST_SNAPSHOT timeline).

## Phase 1 - Baseline Performance Review (Execution Plan)

Objective: produce a defensible healthy-state baseline package using Linux telemetry, SQL workload evidence, and OEM/AWR evidence for the same 15-minute window.

### Step 1 - Capture Pre-Run Oracle State (Terminal: SQLcl)

- [x] Capture current AWR snapshot ID list
- [x] Create/manual note of pre-run snapshot ID: `217`

### Step 2 - Execute 15-Minute Workload Window (Terminal: SQLcl - COSC416_SciKey)

- [x] Confirm driver completed full 15-minute window
- [x] Record end time: `2026-04-06 16:19:01.055`

Latest validated driver run (patched auto-stop behavior):
- Start: `2026-04-06 16:04:01.056`
- End: `2026-04-06 16:19:01.055`
- Elapsed seconds: `900`
- SQLcl elapsed: `00:15:00.437`
- Result: no manual interruption required

### Step 3 - Capture Post-Run Oracle Evidence (Terminal: SQLcl)
- [x] Record post-run snapshot ID: `218`
- [x] Export/save result sets for SLO-1 through SLO-6

### Step 4 - OEM 13c Capture (Same Time Window)
- [x] AWR report exported for `217` to `218`

## Stop Point B - Baseline Evidence Checklist
- [x] AWR snapshot pair identified and report exported — snapshots `217` to `218` (16:03:58 to 16:19:01, elapsed 15.05 min)
- [x] Golden Query timings captured (P95 or repeated-run proxy) — Q1-Q5 timings from embedded comments in [GH_ISSUE_29_SOLUTION.sql](./GH_ISSUE_29_SOLUTION.sql)
- [x] Throughput metric calculated with locked denominator — 72 user calls/min from AWR Load Profile (1.2 calls/sec)
- [x] CPU utilization average computed for same 15-minute window proxy — 52.17% avg from fallback SLO-3 output (provisional)
- [x] Storage latency average computed for same 15-minute window — 5.04 ms xvdb await from `iostat`
- [x] Top non-idle wait event share computed — `direct path read` at 3.3% DB time (no dominant non-idle wait event)
- [x] Plan hash consistency checked for all 5 Golden Queries — AWR history confirms 1 plan hash per query (5/5)

## Stop Point B - Result Summary Table

| SLO ID | Measured Value | Target | Pass/Fail | Evidence Reference |
|---|---|---|---|---|
| SLO-1 | P95 = 0.161 s (Q1 worst-case from 3-run set) | `<= 1.5 s` | **PASS** | `docs/GH_ISSUE_29_SOLUTION.sql` (Section 3, lines ~100-120, embedded timing comments) |
| SLO-2 | 72 user calls/min (AWR Load Profile 1.2 calls/sec) | `Documented baseline value` | **BASELINE RECORDED** | `docs/db_snapshot/awr_report_217_218.html` (Load Profile table) |
| SLO-3 | 52.17% avg CPU (51.55% run 1, 52.78% run 2) | `<= 75%` | **PASS** | `docs/GH_ISSUE_29_SOLUTION.sql` (fallback output comments, lines 238-249) |
| SLO-4 | 5.04 ms avg xvdb await (iostat -xz snapshot) | `<= 20 ms` | **PASS** | `iostat -xz 1 10` output on cosc-ora VM (user-provided) |
| SLO-5 | Top non-idle wait event `direct path read` = 3.3% DB time | `<= 25% single non-idle wait` | **PASS** | `docs/db_snapshot/awr_report_217_218.html` (Top 10 Foreground Events section) |
| SLO-6 | AWR-history output confirms 1 plan hash each for 1d87tbb8tw990 (1347002797), 29ncfz4uzkf0f (345071254), 9fndv6q3mqzc7 (2389557843), dzq5p8kvryx86 (2111472318), gufvudqhs1fag (209240523). `6ymkph9ukt8pj` is the PL/SQL workload driver block, not a Golden Query SQL statement. | `1 distinct plan_hash/query` | **PASS** | SQLcl AWR-history query result from DBA_HIST_SQLSTAT + DBA_HIST_SQL_PLAN |

## Phase 2 - Capacity and Scalability Run Checklist

Objective: determine the practical breaking point of the current configuration by increasing load from the validated 15-minute baseline and recording when response time, CPU, or I/O headroom begins to collapse.

### Phase 2 Starting Point

- [x] Use the validated 15-minute baseline window: AWR snapshots `217` to `218`
- [x] Use the baseline throughput: `72 user calls/min` from the AWR Load Profile
- [x] Use the baseline DB time mix: `98.56%` DB CPU, `3.26%` User I/O wait class, top foreground event `direct path read` at `3.3%`
- [x] Use the baseline host shape: `2 vCPU`, `15.33 GB` RAM, SSD-backed `xvdb`

### Phase 2 Run Steps

1. [ ] Keep the same Golden Query mix and DOCID/pattern inputs so the workload remains comparable.
2. [ ] Run the workload at 1 session and capture a full 15-minute AWR window.
3. [ ] Repeat at 2 sessions and capture a full 15-minute AWR window.
4. [ ] Repeat at 4 sessions and capture a full 15-minute AWR window.
5. [ ] Repeat at 8 sessions only if the 2-session and 4-session runs remain stable.
6. [ ] Compare each run against the Phase 1 baseline rather than a fixed placeholder throughput number.

### Phase 2 Evidence Checklist For Each Run

- [ ] Take one manual AWR snapshot before the first session starts and one after the last session ends.
- [ ] `sar -u` output captured for the run window
- [ ] `vmstat` output captured for the run window
- [ ] `iostat -xz` output captured for the run window
- [ ] Top SQL by elapsed time captured
- [ ] Top SQL by CPU time captured
- [ ] Top wait events and wait-class percentages captured
- [ ] Golden Query plan hash values captured

### Phase 2 Stop Conditions

Stop the ramp test and document the first failing limit when any of the following is observed:

- [ ] average host CPU stays above `85%` for most of the window
- [ ] P95 Golden Query latency exceeds `1.5 s`
- [ ] DB CPU consumes nearly all DB time while throughput stops improving
- [ ] User I/O wait or direct path read time begins to dominate the wait profile
- [ ] AWR shows plan drift for the Golden Queries without a schema or statistics change

### Phase 2 Deliverable

- [ ] Record the most aggressive stable concurrency level
- [ ] Record the first metric that failed as load increased
- [ ] Summarize the capacity conclusion in one short paragraph for the report