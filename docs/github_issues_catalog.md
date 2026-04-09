# COSC416Winter2026 GitHub Issues Catalog

Generated: 2026-04-02
Repository: hundrow/COSC416Winter2026

This document captures issue titles and descriptions from the repository for future Copilot agent context.

## Open Issues

### #14 - epic: Transition and Deployment
- URL: https://github.com/hundrow/COSC416Winter2026/issues/14
- Description:

Due: Wednesday, 8 April 2026, 11:59 PM
Project Transition & Performance-Validated Deployment
- [ ] 1. Performance-Centric Transition Plan
    - The transition from construction to operations in COSC 416 requires a "Performance Gate." The system is not considered "operational" until it meets the predefined service-level objectives (SLOs).

    - Baseline Performance Review: Before sign-off, teams must provide a baseline report (AWR, Query Store, or Profiler) demonstrating the system's "healthy" state. This serves as the benchmark for future troubleshooting.

    - Capacity & Scalability Plan: Document the "breaking point" of the current configuration. Based on your stress tests, at what point will the CPU or I/O subsystem require an upgrade?

    - Operational Runbooks (Tuning Focus): Provide specific instructions for common performance issues identified during the construction phase (e.g., "If Wait Event X appears, execute Reindex Script Y").

    - Knowledge Transfer (Root Cause Analysis): Conduct a session focused on the Execution Plans of the most critical queries to ensure the maintenance team understands the intended data access paths.

- [ ] 2. Advanced Deployment & CI/CD for DBAs
In an advanced environment, we move away from manual scripts toward Database-as-Code.

    - Schema Versioning (Git): All performance-tuning changes (new indexes, partitioning logic, or hint-embedded queries) must be version-controlled.

    - Automated Performance Testing (The "Gate"): Integration of a performance regression test in the deployment pipeline. If a schema change increases the execution time of a "Golden Query" by more than 10%, the deployment should automatically fail.

    - Blue-Green Deployment for Databases: Explain the strategy for deploying schema changes with zero downtime. This involves maintaining two identical environments to ensure immediate Rollback Capability if performance degrades in the "Green" environment.

    - Post-Deployment Monitoring: Configure real-time alerts for specific performance metrics (e.g., Buffer Cache Hit Ratio < 90% or High CPU Wait Times) to ensure the deployment didn't introduce "Plan Regression."

### #15 - epic: Final Presentation or Research Paper
- URL: https://github.com/hundrow/COSC416Winter2026/issues/15
- Description:

Due: Monday, 13 April 2026, 6:00 PM
Final Project Presentation Requirements: Performance & Tuning
Date: Monday, April 13 | Time: 18:00 – 21:00 | Room: E 301

Value: 30 Marks (Final Iteration)

## Presentation Structure (25-30 Minutes)
Each team member must present their specific contributions to the database architecture and tuning effort.

- [ ] 1. Customer & Performance Requirements:
    - Identify the stakeholder and the "Workload Profile" (e.g., OLTP, OLAP, or Hybrid).
    - Define the Success Metrics: Target query response times, transactions per second (TPS), and uptime requirements.
- [ ] 2. Advanced Architecture & Design:
    - Architecture Diagram: Detail the physical layout (Memory structures like SGA/PGA, Storage/ASM, and Network topology).
    - Design Diagrams: Show the evolution from Logical ERD to the Physical Tuning Model (Indexing, Partitioning, and Materialized Views).
- [ ] 3. The Tuning Methodology (The "Core"):
    - Risk Management: Focus on data integrity risks and performance regression risks.
    - Code & Optimization: Show "Before vs. After" SQL excerpts. Discuss used patterns (e.g., Parallel Processing, Hinting, or PL/SQL bulk collection).
- [ ] 4. Testing & Validation (The Evidence):
    - Performance Testing: Present results from stress tests or load generators.
    - Comparison Charts: Use graphs to show the impact of your tuning (e.g., reduced I/O wait times or CPU utilization).
- [ ] 5. Refactoring & Iteration:
    - Explain what was "broken" in the initial build and how you refactored the database objects or parameters to improve throughput.
- [ ] 6. Operational Release & Transition:
    - Provide the Deployment Plan (CI/CD integration, rollback strategy).
    - Demonstration: A Live Demo or video of the system handling a heavy workload while maintaining stability.

### Project Documentation Deliverables
All files must be submitted via Moodle and Source Control in electronic form:

- [ ] DBA Operational Manual: (Runbooks for performance spikes, backup/recovery steps).
- [ ] Installation & Configuration Guide: (Detailed server parameters and environment setup).
- [ ] Tuning & Design Document: (The technical justification for your indexing and storage choices).
- [ ] Release Notes: (Known issues, residual risks, and hardware limitations).
- [ ] Source Code: (Full DDL, DML scripts, and Version Control history).

### Q&A Defence (10-15 Minutes)
Be prepared to defend your technical choices. Professors and peers may ask:

> "Why did you choose a Bitmap index over a B-Tree for this specific column?" * "What was the primary wait event during your stress test, and how did you resolve it?"


---

## COSC 416: Final Project Peer Evaluation Form
Presenter Team: ____________________ Reviewer: ____________________

1. Technical Depth & Performance Engineering (15 Marks)
Rate the following on a scale of 1–5 (1=Poor, 5=Excellent):
    - Physical Design Justification: Did the team explain why they chose specific storage structures, indexing, or partitioning strategies? (e.g., explaining why a Hash partition was chosen over Range).
    - Tuning Evidence: Did they provide clear "Before vs. After" metrics? Are the performance gains backed by execution plans or AWR/Statspack-style data?
    - Bottleneck Analysis: Did they accurately identify the primary system bottleneck (CPU, I/O, Memory, or Locking) and address it effectively?
2. Operational Readiness (5 Marks)
Transition & Deployment: Is the deployment automated (CI/CD)? Is there a clear rollback strategy and baseline for the maintenance team?
    - Risk Mitigation: Did they identify realistic database risks (e.g., plan regression, data corruption) and provide workarounds?
3. Demonstration & Defence (10 Marks)
Live Demonstration: Did the demo successfully show the system under load?
    - Technical Defence (Q&A): How well did the team handle difficult technical questions regarding their configuration and code?
4. Qualitative Feedback (The "Constructive" Part)
    - What was the most impressive tuning optimization they performed? 
    - One area where their database might struggle if the data volume tripled tomorrow: 

### Final Project Sign-off Checklist
To ensure no team misses a deliverable on April 13th, I recommend they include this "Gate" checklist in their final submission:

- [ ] Baseline Report: Initial performance stats before any tuning.
- [ ] Execution Plans: Documentation for the top 5 "Critical Queries."
- [ ] Stress Test Log: Proof of system behaviour under 80%+ load.
- [ ] Versioning History: Link to the Git repository showing the evolution of the schema.
- [ ] DBA Runbook: Clear instructions for index rebuilds, statistics updates, and space management.

### #29 - Transition/Deployment 1 - Performance-Centric Transition Plan
- URL: https://github.com/hundrow/COSC416Winter2026/issues/29
- Description:

The transition from construction to operations in COSC 416 requires a "Performance Gate." The system is not considered "operational" until it meets the predefined service-level objectives (SLOs).

- [ ] Baseline Performance Review: Before sign-off, teams must provide a baseline report (AWR, Query Store, or Profiler) demonstrating the system's "healthy" state. This serves as the benchmark for future troubleshooting.
- [ ] Capacity & Scalability Plan: Document the "breaking point" of the current configuration. Based on your stress tests, at what point will the CPU or I/O subsystem require an upgrade?
- [ ] Operational Runbooks (Tuning Focus): Provide specific instructions for common performance issues identified during the construction phase (e.g., "If Wait Event X appears, execute Reindex Script Y").
- [ ] Knowledge Transfer (Root Cause Analysis): Conduct a session focused on the Execution Plans of the most critical queries to ensure the maintenance team understands the intended data access paths.

### #30 - Transition/Deployment 2 - Advanced Deployment & CI/CD for DBAs
- URL: https://github.com/hundrow/COSC416Winter2026/issues/30
- Description:

In an advanced environment, we move away from manual scripts toward Database-as-Code.

- [ ] Schema Versioning (Git): All performance-tuning changes (new indexes, partitioning logic, or hint-embedded queries) must be version-controlled.
- [ ] Automated Performance Testing (The "Gate"): Integration of a performance regression test in the deployment pipeline. If a schema change increases the execution time of a "Golden Query" by more than 10%, the deployment should automatically fail.
- [ ] Blue-Green Deployment for Databases: Explain the strategy for deploying schema changes with zero downtime. This involves maintaining two identical environments to ensure immediate Rollback Capability if performance degrades in the "Green" environment.
- [ ] Post-Deployment Monitoring: Configure real-time alerts for specific performance metrics (e.g., Buffer Cache Hit Ratio < 90% or High CPU Wait Times) to ensure the deployment didn't introduce "Plan Regression."

## Closed Issues

### #1 - Executive Summary
- URL: https://github.com/hundrow/COSC416Winter2026/issues/1
- Description:

Draft the Executive Summary, including project goal, tuning methodology, and key deliverables.

### #2 - Technical Architecture
- URL: https://github.com/hundrow/COSC416Winter2026/issues/2
- Description:

Write DBMS selection, hardware/storage context, and rationale for platform choice.

### #3 - Database Schema Design
- URL: https://github.com/hundrow/COSC416Winter2026/issues/3
- Description:

Define core entities and relationships; outline indexing strategy.

### #4 - Data Ingestion & ETL Pipeline
- URL: https://github.com/hundrow/COSC416Winter2026/issues/4
- Description:

Describe staging, validation, transformation, and production load steps.

### #5 - Performance Monitoring & Diagnostics
- URL: https://github.com/hundrow/COSC416Winter2026/issues/5
- Description:

Detail top-down tuning approach, baseline metrics, tools, and monitoring plan.

### #6 - SQL & Instance Tuning
- URL: https://github.com/hundrow/COSC416Winter2026/issues/6
- Description:

Provide SQL optimization methods, configuration tuning, and indexing iteration plan.

### #7 - Security & Operations
- URL: https://github.com/hundrow/COSC416Winter2026/issues/7
- Description:

Cover encryption, auditing, access control, backup, and recovery procedures.

### #8 - Schedule & Contributions
- URL: https://github.com/hundrow/COSC416Winter2026/issues/8
- Description:

Populate roles, responsibilities, and weekly milestones.

### #9 - Risk Assessment
- URL: https://github.com/hundrow/COSC416Winter2026/issues/9
- Description:

List risks, impacts, and mitigation strategies.

### #10 - Conclusion
- URL: https://github.com/hundrow/COSC416Winter2026/issues/10
- Description:

Summarize value, outcomes, and commitment to deliverables.

### #11 - epic: RFP submission
- URL: https://github.com/hundrow/COSC416Winter2026/issues/11
- Description:

Create an RFP

### #12 - epic: Elaboration
- URL: https://github.com/hundrow/COSC416Winter2026/issues/12
- Description:

Due: Tuesday, 10 March 2026, 11:59 PM

Definition & DBA Perspective
In the DBMS lifecycle, Elaboration is the transition from conceptual theory to a validated, implementable architecture. From a DBA perspective, this phase focuses on Risk Mitigation—ensuring that the chosen project (e.g., ParallelXGBoost or SciKey) is technically feasible within the Oracle 19c or PostgreSQL environment.

Key DBA Activities & Refinements:

### #13 - epic: Construction
- URL: https://github.com/hundrow/COSC416Winter2026/issues/13
- Description:

Due: Wednesday, 25 March 2026, 11:59 PM
Assignment: Advanced Database Performance & Construction
Course: COSC 416 – Advanced Database Topics

Term: Spring 2026

Due Date: Presentation – Wednesday, March 25th

Overview
In this project, teams will move beyond basic administration to the Performance-Driven Construction of a database system. Your goal is to implement a physical database design in the DRI or COSC Data Centre using real data, and then systematically tune the environment to meet specific workload requirements.

Key Phases & Performance Requirements
- [ ] 1. Engineered Installation & Configuration
Instead of a default installation, you must configure the DBMS (Oracle, SQL Server, or PostgreSQL) with specific performance goals in mind.

    - Resource Allocation: Document your memory management strategy (e.g., Oracle SGA/PGA tuning or SQL Server Max Server Memory).

    - I/O Optimization: Justify your placement of data files, redo logs, and undo/temp segments across available storage to minimize disk contention.

- [ ] 2. Advanced Physical Design & Access Methods
The logical design is provided, but the Physical Implementation is your responsibility.

    - Advanced Indexing: Implement and compare at least two indexing strategies (e.g., B-Tree vs. Bitmap, or Clustered vs. Non-Clustered).

    - Partitioning: If using large datasets, implement table partitioning (Range, Hash, or List) to improve query pruning performance.

    - Storage Structures: Define custom tablespaces with optimized extent sizes and block sizes appropriate for your data type.

- [ ] 3. Data Loading & Stress Testing
Bulk Loading: Use tools like SQL*Loader, BCP, or COPY to ingest real-world datasets. Document the time taken and the impact on the transaction log.

    - Workload Simulation: Use a stress-testing tool or custom scripts to simulate concurrent user activity.

- [ ] 4. The Tuning Lab (Core of COSC 416)
You must demonstrate a "Before and After" scenario for a specific performance bottleneck:

    - Execution Plan Analysis: Identify a "heavy" query, analyze its execution plan, and apply a fix (e.g., adding a covering index, rewriting the SQL, or updating statistics).

    - Wait Event Analysis: Use AWR (Oracle) or pg_stat_statements to identify the top system wait events and mitigate them.

Deliverables
- [ ] 1. Performance Report (Documentation)
A technical document detailing the physical configuration, the schema DDL, security roles, and—most importantly—the results of your performance tuning efforts.

- [ ] 2. Presentation (Wednesday, March 25th)
Each team will provide a 5-7 minute presentation (5-7 slides).

    - Slide 1: Project Scope & Data Source.

    - Slide 2: Physical Architecture (Storage & Memory config).

    - Slide 3: Indexing & Partitioning Strategy.

    - Slide 4: Performance Bottleneck Identified (The "Problem").

    - Slide 5: Tuning Applied & Results (The "Fix" with metrics).

    - Slide 6: Backup & Recovery validation.

    - Slide 7: Team Contributions (Referencing the COSC 416 Performance Schedule).

Important Notes
Real Data: Use of synthetic data is discouraged; use open-source datasets (e.g., Kaggle, Census) to ensure realistic indexing challenges.

Contribution: Use the attached COSC 416 Performance Schedule to log individual hours and specific tasks (e.g., "Lead Tuner," "Data Architect," "Security Admin").

### #16 - Translating Conceptual to Logical Design:
- URL: https://github.com/hundrow/COSC416Winter2026/issues/16
- Description:

Refining the high-level ERD into a schema that enforces data integrity via primary/foreign keys and constraints. For SciKey, this includes planning the Partitioning strategy (Range/List) for 4 million+ records.

### #17 - Performance Prototyper & Baseline Diagnostics:
- URL: https://github.com/hundrow/COSC416Winter2026/issues/17
- Description:

Instead of just "evaluating patterns," the DBA must now establish AWR (Automatic Workload Repository) baselines. This allows the team to identify "Wait Events" and "Service Times" before the Construction phase begins.

### #18 - Physical Design & I/O Balancing:
- URL: https://github.com/hundrow/COSC416Winter2026/issues/18
- Description:

Critical decisions are made regarding Tablespaces and SGA/PGA memory allocation. For ParallelXGBoost, the DBA must plan for high-concurrency I/O to support 10GB training sets.

### #19 - Security Architecture:
- URL: https://github.com/hundrow/COSC416Winter2026/issues/19
- Description:

Planning the implementation of Transparent Data Encryption (TDE) and Unified Auditing to ensure compliance without causing significant performance overhead (optional).

### #20 - Capacity Planning:
- URL: https://github.com/hundrow/COSC416Winter2026/issues/20
- Description:

Using the hardware context (e.g., Digital Research Alliance Canada) to ensure the system can handle the specific workload, such as heavy analytical joins or high-frequency logging.

### #21 - Slide Content
- URL: https://github.com/hundrow/COSC416Winter2026/issues/21
- Description:

Preparation for Wednesday, March 11th (5-7 Slides)
To meet the project requirements, your 5-minute presentation should follow this structure:

  - Title & Team Roles
  - Project Selection
  - Technical Architecture
  - Elaboration: Design
  - Performance Schedule
  - Risk Assessment
  - Q&A / Next Steps

### #23 - Construction Phase 1 - Engineered Installation & Configuration
- URL: https://github.com/hundrow/COSC416Winter2026/issues/23
- Description:

Instead of a default installation, you must configure the DBMS (Oracle, SQL Server, or PostgreSQL) with specific performance goals in mind.

- [ ] Resource Allocation: Document your memory management strategy (e.g., Oracle SGA/PGA tuning or SQL Server Max Server Memory).

- [ ] I/O Optimization: Justify your placement of data files, redo logs, and undo/temp segments across available storage to minimize disk contention.

### #24 - Construction Phase 2 - Advanced Physical Design & Access Methods
- URL: https://github.com/hundrow/COSC416Winter2026/issues/24
- Description:

The logical design is provided, but the Physical Implementation is your responsibility.

- [ ] Advanced Indexing: Implement and compare at least two indexing strategies (e.g., B-Tree vs. Bitmap, or Clustered vs. Non-Clustered).

- [ ] Partitioning: If using large datasets, implement table partitioning (Range, Hash, or List) to improve query pruning performance.

- [ ] Storage Structures: Define custom tablespaces with optimized extent sizes and block sizes appropriate for your data type.

### #25 - Construction Phase 3 - Data Loading & Stress Testing
- URL: https://github.com/hundrow/COSC416Winter2026/issues/25
- Description:

- [ ] Bulk Loading: Use tools like SQL*Loader, BCP, or COPY to ingest real-world datasets. Document the time taken and the impact on the transaction log.

- [ ] Workload Simulation: Use a stress-testing tool or custom scripts to simulate concurrent user activity.

### #26 - Construction Phase 4 - The Tuning Lab (Core of COSC 416)
- URL: https://github.com/hundrow/COSC416Winter2026/issues/26
- Description:

You must demonstrate a "Before and After" scenario for a specific performance bottleneck:

- [ ] Execution Plan Analysis: Identify a "heavy" query, analyze its execution plan, and apply a fix (e.g., adding a covering index, rewriting the SQL, or updating statistics).

- [ ] Wait Event Analysis: Use AWR (Oracle) or pg_stat_statements to identify the top system wait events and mitigate them.

### #27 - Construction Deliverable 1 - Performance Report (Documentation)
- URL: https://github.com/hundrow/COSC416Winter2026/issues/27
- Description:

- [ ] A technical document detailing the physical configuration, the schema DDL, security roles, and—most importantly—the results of your performance tuning efforts.

### #28 - Construction Deliverable 2 - Presentation (Wednesday, March 25th)
- URL: https://github.com/hundrow/COSC416Winter2026/issues/28
- Description:

Each team will provide a 5-7 minute presentation (5-7 slides).

- [ ] Slide 1: Project Scope & Data Source.
- [ ] Slide 2: Physical Architecture (Storage & Memory config).
- [ ] Slide 3: Indexing & Partitioning Strategy.
- [ ] Slide 4: Performance Bottleneck Identified (The "Problem").
- [ ] Slide 5: Tuning Applied & Results (The "Fix" with metrics).
- [ ] Slide 6: Backup & Recovery validation.
- [ ] Slide 7: Team Contributions (Referencing the COSC 416 Performance Schedule).
