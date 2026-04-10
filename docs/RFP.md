

| SciKey Project Proposal (Database Architecture & Performance Tuning) |
| ----- |
| **Project:** SciKey \- AI and NLP for Indexing French Scientific Publications **Submitted by:** Alex Anthony, Andrew Johnson, Cody Jorgenson, Emilio Iturbide Gonzalez **Submitted to:** Paris East University (UPEC) – Gaétan Hains, Hélène Pipet, Jean Bouyssou **Date:** February 8, 2026  |

**Table of contents:**

[Executive Summary/Project Overview](#executive-summary/project-overview)

[Objective](#objective)

[Expected Outcomes & Delivery](#expected-outcomes-&-delivery)

[Scope of Work](#scope-of-work)

[Key Deliverables:](#key-deliverables:)

[In Scope:](#in-scope:)

[Out of Scope:](#out-of-scope:)

[Team Roles](#team-roles)

[Technical Requirements](#technical-requirements)

[Technical Architecture](#technical-architecture)

[DBMS Selection & Hardware Context](#dbms-selection-&-hardware-context)

[Database Schema Design](#database-schema-design)

[Core Entities:](#core-entities:)

[Indexing Strategy:](#indexing-strategy:)

[Data Ingestion & ETL Pipeline](#data-ingestion-&-etl-pipeline)

[Architecture Scope Boundaries:](#architecture-scope-boundaries:)

[DBA Action Plan](#dba-action-plan)

[Performance Monitoring & Diagnostics](#performance-monitoring-&-diagnostics)

[SQL & Instance Tuning](#sql-&-instance-tuning)

[Security & Operations](#security-&-operations)

[Project Methodology](#project-methodology)

[Project Phases](#project-phases)

[Risk Assessment](#risk-assessment)

[Performance Schedule](#performance-schedule)

[Phase Milestones:](#phase-milestones:)

[Deliverables Summary:](#deliverables-summary:)

# Executive Summary/Project Overview {#executive-summary/project-overview}

## Objective {#objective}

Our team proposes to provide comprehensive Database Administration and Performance Tuning services for the SciKey project, focusing on a scalable Oracle Database 19c architecture for HAL metadata and UPEC publications. We will apply the COSC 416 top-down tuning methodology (Design -> SQL -> Instance) to deliver a robust, secure, and high-performance database system.

## Expected Outcomes & Delivery {#expected-outcomes-&-delivery}

### Scope of Work {#scope-of-work}

#### Key Deliverables: {#key-deliverables:}

* Normalized database schema for publications, authors, affiliations, and identifiers (DDL scripts with indexes)  
* Performance monitoring and diagnostics reports using AWR/ADDM and Oracle Enterprise Manager  
* SQL and instance tuning plan with measurable performance improvements (benchmark reports)  
* Encryption and auditing configuration using TDE and Unified Auditing  
* Backup automation scripts and DBA runbook documentation  
* Workload test scripts and technical documentation

#### In Scope: {#in-scope:}

* Database schema and index design  
* Performance monitoring reports and benchmark baselines  
* SQL and instance tuning recommendations with measured results  
* Security controls (encryption and auditing) with implementation steps

#### Out of Scope: {#out-of-scope:}

* NLP/LLM keyword extraction or model evaluation  
* Web UI/API development  
* Production operations or 24/7 monitoring  
* Hardware procurement or VM hosting  
* Legal/compliance reviews of data ownership or licensing  
* End-user training and change management

### Team Roles {#team-roles}

| Role | Team Member | Key Responsibilities | Deliverables | Milestones |
| :---- | :---- | :---- | :---- | :---- |
| Product Owner | Cody Jorgensen | Scope management, client alignment, stakeholder communication, final deliverables. | Requirements doc; Final report; Mid-project status updates; | **Iteration** 1: Finalize requirements; **Iteration** 4: Deliver final report. |
| Performance Manager | Alex Anthony | AWR/ADDM analysis, SQL tuning, query optimization, index strategy | Workload test scripts; Tuning benchmark reports; Query optimization docs; | **Iteration** 2: Baseline benchmarks; **Iteration** 3: Tuning iterations; **Iteration** 4: Performance report. |
| Security Manager | Emilio Iturbide | TDE/encryption implementation, unified auditing setup, access control, backup procedures | Security config scripts; Backup automation scripts;Security docs; | **Iteration** 2: Security design; **Iteration** 3: Implementation & testing; **Iteration** 4: Security documentation |
| User & Developer Support | Andrew Johnson | Documentation, GitHub repository, technical scripts, sprint coordination, regression testing | Schema creation scripts; GitHub artifacts; | **Iteration** 1-4: Continuous; Weekly deliverables to GitHub |

# Technical Requirements {#technical-requirements}

## Technical Architecture {#technical-architecture}

### DBMS Selection & Hardware Context {#dbms-selection-&-hardware-context}

**Database Platform:** Oracle Database 19c  
**Hardware Environment:** COSC Data Centre VM (Okanagan College)  
**Storage Requirements:** 50–150GB for HAL metadata and UPEC publications with growth capacity

**Rationale:** Oracle Database 19c provides the required monitoring, tuning, and security capabilities (AWR, ADDM, Enterprise Manager, Unified Auditing, TDE) while aligning with COSC 416 performance tuning methodologies.

### Database Schema Design {#database-schema-design}

The core database design will be based around a data warehousing approach using a star schema layout. This will ensure fast queries with a minimal amount of table joining.

#### Core Entities: {#core-entities:}

* publications (HAL records with unique identifiers, titles, abstracts, dates)  
* authors (researcher metadata with affiliations and identifiers)  
* affiliations (institutions with geographic and organizational data)  
* journals (journal metadata and publication categories)  
* upec\_subset (flag/tag field to identify UPEC-relevant records)

#### Indexing Strategy: {#indexing-strategy:}

* Primary indexes on publication and author IDs  
* Composite indexes for multi-column search queries (author \+ date ranges)  
* Bitmap or partial indexes for UPEC subset filtering  
* Full-text indexes for keyword and abstract searching

### Data Ingestion & ETL Pipeline {#data-ingestion-&-etl-pipeline}

Data extraction and transformation will be done with various scripts. Abstracts of articles will be read in order to be examined for keywords. Publication dates, authors, titles, journals, and any other metadata will all be put into associated tables.

1. **Staging Phase:** Load raw HAL exports into temporary staging tables  
2. **Validation:** Apply constraints, check referential integrity, deduplicate records  
3. **Transformation:** Map HAL schema to production normalized schema  
4. **Production Load:** Insert validated data with transaction logging

### Architecture Scope Boundaries: {#architecture-scope-boundaries:}

* **In Scope:** Oracle 19c schema design, indexing strategy, performance monitoring configuration, and security configuration setup  
* **Out of Scope:** VM provisioning, HA/DR architecture beyond backup/restore, application-layer schema integration, ETL orchestration tooling, advanced data cleansing workflows, and search/LLM infrastructure

# DBA Action Plan {#dba-action-plan}

## Performance Monitoring & Diagnostics {#performance-monitoring-&-diagnostics}

The database team will make use of a Top-Down tuning approach, beginning with an analysis of the requirements for resource allocation and identifying potential bottlenecks. As the project progresses, the team will narrow the focus from design, to code, and then instance.

At the design level, the project team will focus on understanding the expected workload before the database is placed under load. Key tasks include:

* Memory Target: Determining the necessary MEMORY\_TARGET and MEMORY\_MAX\_TARGET parameter values based on expected demands.  
* Memory Management: Determining whether Automatic Memory Management (AMM) or Automatic Shared Memory Management (ASMM) will be required for managing SGA and PGA sizing, opting for a strategy to mitigate reliance on disk reads.  
* Memory Advisors: Reviewing recommendations from Oracle advisors, such as Memory Size Advisor, to compare and validate that the proposed memory architecture fits the expected load \[1\].

The project team will make use of Oracle Enterprise Manager’s Performance page for a broad overview of Average Active Sessions, major wait events, logical and physical reads, and disk I/O to confirm whether the initial design can manage an active load. AWR snapshots and ADDM analysis will help identify bottlenecks \[1\]. 

At the code level, Enterprise Manager will be used as the primary tool to identify potential code/SQL-related problems with the initial design. The Top Consumers tab provides statistics for services, modules, actions, and sessions including CPU time, memory allocation, physical and logical reads, sorting them for an easy at-a-glance view of problematic areas. Spikes in the Average Active Sessions graph can be drilled down to reveal more granular insights such as Top Working SQL and Top Working Sessions \[1\].

At the instance level, the project team will make use of dynamic performance views to monitor critical wait events such as Concurrency and I/O waits over specific time periods. See the SQL & Instance Tuning section for further details. 

## SQL & Instance Tuning {#sql-&-instance-tuning}

### Optimization 

For query performance optimization, we will be using Explain Plans, which will provide a breakdown of how the database engine will execute a specific SQL statement. By doing this we will be able to identify operations that cause significant performance overhead, such as full table scans or inefficient joins. We will use these insights to determine where new indexes may be needed.

The team will also use the SQL Tuning Advisor in combination with Explain Plans to analyze query optimization and obtain suggestions to create new indexes, and reconstructing SQL statements.

To reduce query latency, we will use materialized views to store copies of complex SQL query results that are run frequently. This will allow us to improve performance on queries that involve aggregation and heavy joins.

### Memory Management

Since our database will need to handle high-concurrency inserts and heavy analytical joins, we will need to manage memory allocations to support our workloads. For high concurrency inserts, the Buffer Cache needs to have moderate sizing as data is mostly written and not read, the Shared Pool size needs to increase to be able to handle multiple SQL statements, and PGA size has to have moderate sizing as queries won’t be necessarily complex. On the other hand, heavy analytical joins work differently. The Buffer Cache size needs to increase significantly to cache large tables and indexes, the Shared Pool size is slightly moderate to focus on storing execution plans for complex queries, and the PGA size needs to increase to accommodate heavy sorting, hashing, and parallel query execution. Therefore, we will need to be able to balance the size of the DB Buffer Cache, the Shared Pool and the PGA.

To do this, we will be using the Automatic Shared Memory Management tool (ASMM) to automatically adjust memory allocations to maximize efficiency and performance. We will also use the V$SGA\_TARGET\_ADVICE, V$PGA\_TARGET\_ADVICE, and V$DB\_CACHE\_ADVICE views to simulate the workload impact of size changes on the DB Buffer Cache, SGA, and PGA. In the case of being necessary, we will enable and force the cursor sharing to allow multiple sessions to reuse parsed SQL statements and execution plan, this will reduce hard parsing.

## Security & Operations {#security-&-operations}

### Data Protection

The project team will implement data protection measures learned from the course materials to align with core DBA security responsibilities, prioritizing restricted access, user authentication, and monitoring for actions contrary to our approach. 

The data protection strategy will adhere to the principle of least privilege by: 

* Installing only required software and services to reduce maintenance, upgrades, potential security holes, and software conflicts.  
* Protecting the data dictionary by   
  * Running daily jobs to ensure the O7\_DICTIONARY\_ACCESSIBILITY parameter remains set to FALSE.  
  * Revoking unnecessary PUBLIC privileges  
  * Controlling directory access through OS-level permissions and DIRECTORY objects.  
* Enforcing distinct DBA and SYSADMIN roles with independent auditing  
* Securing administrative accounts with case-sensitive password files and strong authentication methods \[2\].

Transparent Data Encryption (TDE) and Unified Auditing will be considered for inclusion should they align with lecture material and the client’s (professor’s) guidance.

## Auditing and Compliance Monitoring

Standard database auditing will be used to ensure compliance and detect unauthorized activity. This will be enabled through the AUDIT\_TRAIL initialization parameter set to DB so that records can be viewed in the DBA\_AUDIT\_TRAIL view. Auditing will be specified for SQL statements, system privileges, and object privileges, separated by user, success/failure, and access. The database team will implement fine-grained auditing using DBMS\_FGA.ADD\_POLICY to audit on specific conditions. SYSDBA/SYSOPER will be audited with the AUDIT\_SYS\_OPERATIONS parameter set to true \[2\].

### Security Patches

Security updates will follow Oracle’s Critical Patch Update Process. The Security Manager will subscribe to receive emails about Critical Patch Update information from the Oracle Technology Network (OTN).

### Testing

Unit testing will be done to validate any changes to the database configuration, comparing database behavior after making the change (audit policy, privilege modifications, encryption settings). Regression tests will be done to verify that changes do not affect the existing configurations. Configuration changes will be monitored and compared using scripts to provide AWR/ADDM reports (following the change) and Enterprise Manager comparisons \[1\].

# Project Methodology {#project-methodology}

## Project Phases {#project-phases}

* **Assessment:** Clearly define the project requirements, and develop the RFP.  
    
* **Design:** Design the database schema, build data collection and ETL models.  
    
* **Implementation:** Create database and populate with real data  
    
* **Testing:** Test ETL process and data collection, performance tuning  
    
* **Maintenance:** Manage database growth to ensure good performance

## Risk Assessment {#risk-assessment}

Risk assessment and mitigation strategies were created using assistance from Gemini, knowledge from prior DBA projects, and course notes \[1\]\[2\]\[3\].

| Risk | Description | Likelihood | Impact | Mitigation |
| :---- | :---- | :---- | :---- | :---- |
| Data Loss or Corruption | Backup/Recovery strategy fails leading to unrecoverable data. | Medium | Critical | Perform regular recovery validation tests. Look into Data Guard. |
| Inadequate Memory Allocation | Incorrect initial sizing of SGA/PGA components leads to excessive disk access. | Medium | Medium-High | Validate initial estimation of appropriate memory target parameters with advisors. |
| Security Vulnerability | Failure to apply Critical Patch Updates. | Low-Medium | High | Security Manager subscribes to Oracle Critical Patch Update notifications. Enforce pre and post-patch validation. |
| Excessive Auditing Overhead | Performance degradation due to poor storage/ maintenance of audit trails. | Medium | Medium | Regular review of records, create scheduled jobs to trigger alerts when log files become too large. |
| VM Failure | Server hosting the VM goes down leaving it inaccessible. | Medium-High | Critical | Offload backup files to a location which does not require database/server access, restore on a separate VM. |
| Configuration Error | Manual changes lead to some inconsistencies in the database. | High | Medium | Regression testing to confirm no issues with existing functionality or data integrity. |
| Insufficient Monitoring Coverage | Performance degradation not noticed in time. | Medium | Medium | Create daily monitoring jobs to query dynamic performance views. |
| Excessive Resource Consumption | Poorly tuned SQL, missing or invalid indexes. | Medium | Medium | Create daily monitoring jobs to report high CPU sessions and services. |

## Performance Schedule {#performance-schedule}

### Phase Milestones: {#phase-milestones:}

* **Week 1:** Workload requirements definition, schema finalization  
* **Week 2:** Team role confirmation, baseline performance capture  
* **Weeks 3-4:** SQL tuning, security implementation, index optimization testing  
* **Week 5:** Performance validation, regression testing, documentation updates  
* **Week 6:** Final deliverables review, client handoff, GitHub repository finalization

### Deliverables Summary: {#deliverables-summary:}

* Schema creation scripts (DDL with indexes)  
* Workload test scripts for performance benchmarking  
* Security configuration scripts (TDE, Unified Auditing)  
* Backup automation scripts  
* Tuning benchmark reports (before/after metrics)  
* DBA runbook documentation

 

## References

\[1\] Oracle, “Performance Management,” presented to Class, Okanagan College, Kelowna, BC, Canada. January, 2026\. \[Powerpoint slides\]. Available:   
[https://mymoodle.okanagan.bc.ca/pluginfile.php/4781358/mod\_resource/content/0/less\_13.ppt](https://mymoodle.okanagan.bc.ca/pluginfile.php/4781358/mod_resource/content/0/less_13.ppt)

\[2\] Oracle, “Security,” presented to Class, Okanagan College, Kelowna, BC, Canada. January, 2026\. \[Powerpoint slides\]. Available:   
[https://mymoodle.okanagan.bc.ca/pluginfile.php/4781359/mod\_resource/content/0/less\_11.ppt](https://mymoodle.okanagan.bc.ca/pluginfile.php/4781359/mod_resource/content/0/less_11.ppt)

\[3\] Google, “Gemini,” Google LLC, accessed Feb. 01-08, 2026\. \[Online\]. Available: [https://gemini.google.com/](https://gemini.google.com/)

\[4\] Hains, Gaétan, et al. “SciKey Projet (Scientific Keywords): AI and NLP for Indexing French Scientific Publications.” Université Paris-Est Créteil (UPEC) Course Materials, COSC 416, Moodle, n.d., [https://mymoodle.okanagan.bc.ca/pluginfile.php/4809950/mod\_resource/content/0/SciKeyProject.pdf](https://mymoodle.okanagan.bc.ca/pluginfile.php/4809950/mod_resource/content/0/SciKeyProject.pdf).

\[5\] A. Johnson, "SciKey Database Performance Optimization," *GitHub*, 2026\. \[Online\]. Available: [https://github.com/hundrow/COSC416Winter2026](https://github.com/hundrow/COSC416Winter2026). \[Accessed: Feb. 8, 2026\].  