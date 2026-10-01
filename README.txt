CS336 - Project 1 - Group 28
=============================

0. Team Members
----------------
Full Name:                     NetID:
Keerthan Vijayavel            kv329
Udaya Chhetri                   ubc3
Harmon Jenkins                 hjj26
Akash Saha                      as3880

1. Known Issues
----------------
None. Both scripts were run on ilab (ilab1.cs.rutgers.edu, database as3880):
01_create_and_load.sql loads all 349,563 rows into Preliminary, with
sequence_number filled 1..349,563 as the primary key.
02_export_to_csv.sql writes reconstructed.csv, and
`diff hmda_2017_nj_all-records_labels.csv reconstructed.csv` reports no
differences (both files are 278,834,016 bytes). See
screenshots/25_rowcount_export_and_diff_identical.jpg.

Note: in Preliminary, blank numeric fields are stored as NULL and blank text
fields are stored as the empty string '', because COPY reads every field in
this file as quoted. So to find non-blank text values use  col <> ''  rather
than  col IS NOT NULL.


2. Collaboration
------------------
All four team members collaborated on this project:
- ER diagram: designed together in draw.io (er_diagram/Group28_ER_Diagram.drawio,
  submitted as er_diagram/Group28_ER_Diagram.pdf),
  following the crow's foot / Oracle notation from the lecture slides
  ("Database Design and ER diagrams") and the draw.io ER guide linked in the
  assignment (drawio-app.com/blog/entity-relationship-diagrams-with-draw-io/).
- SQL load/export scripts: written and tested by the group, with help from
  an AI tool (Claude / Claude Code) for debugging the COPY options and
  writing the scripts' comments. AI use is permitted for this assignment.
- References: PostgreSQL documentation (COPY / \copy, FORCE_NULL,
  FORCE_QUOTE, GENERATED ... AS IDENTITY, numeric vs. float types), and the
  CFPB's HMDA documentation PDFs (lar_record_codes.pdf and
  lar_record_format.pdf) to understand what each column and code means.


3. Data Insights & Entity Design
-----------------------------------
Insights (NJ, 2017, all records -- 349,563 rows from 856 reporting lenders):
- 169,196 loans were originated and 49,214 applications were denied, so
  about 22.5% of applications that reached a decision were denied. Another
  48,680 were withdrawn by the applicant and 54,938 were loans purchased
  from another institution rather than applied for.
- The most common denial reason is debt-to-income ratio (10,360), then
  credit history (8,816) and collateral (7,021).
- Denial rates differ a lot by applicant race: ~20% for White and ~19% for
  Asian applicants vs. ~36% for Black and ~44% for American Indian/Alaska
  Native applicants. The data can be used to look for lending
  discrimination, which is the purpose of HMDA.
- Home purchase (184,956) is the most common loan purpose, ahead of
  refinancing (139,078). Conventional loans are ~72% of all records, and
  FHA-insured loans are ~23%.
- The median originated loan is $251k and the median applicant income is
  $102k. Bergen, Ocean, Monmouth and Middlesex counties have the most
  applications.
- sequence_number, edit_status, edit_status_name and
  application_date_indicator are blank in every row of the NJ 2017 file.
  We generate sequence_number ourselves as the primary key.

Rules for dividing attributes into entities:
- Each table represents one real-world thing, and each attribute goes in
  the entity it describes. Each code is kept in the same table as its
  plain-language *_name label (e.g. loan_type with loan_type_name).
- Application (PK sequence_number) is the central entity: one row per
  loan application/record. Loan-level facts (amount, type, purpose,
  property type, owner occupancy, preapproval, action taken, purchaser,
  rate spread, HOEPA/lien/edit status, year, application date indicator)
  stay here.
- Agency (agency_code, name, abbr) supervises Respondents (the lending
  institutions, identified by respondent_id + agency_code). A respondent
  handles many applications.
- Applicant and Co-Applicant hold the demographic attributes of the people
  on the application (ethnicity, race 1-5, sex; income for the applicant).
  They are 1:1 with Application and keyed by sequence_number. Every
  application has an applicant, and the co-applicant is optional.
- Denial holds the three denial reasons. It is optional (0..1) per
  application because only denied applications have reasons.
- Location (location_id, the one attribute we were allowed to add) holds the
  census-tract-level data: census_tract_number, population,
  minority_population, HUD median family income, tract-to-MSA income,
  housing unit counts. It references State, County and MSAMD, which hold
  their own codes and names. A County is identified by state_code +
  county_code because county codes are only unique within a state.


4. Development Challenges & Time Spent
------------------------------------------
- Every field in the CSV is double-quoted, including blanks, so Postgres
  read blank numeric fields as empty strings and the integer columns failed
  to load. We fixed this with FORCE_NULL on the numeric columns.
- \copy is a psql meta-command and must be on one line, so our first
  multi-line version would not parse.
- Filling sequence_number with row_number() OVER () after the load gave
  the wrong numbers on this wide table, because the order rows come back
  in does not match the file order. We switched to GENERATED ALWAYS AS
  IDENTITY so the number is assigned in file order during the COPY.
- In the export query, our NULL alias named sequence_number hid the real
  column in ORDER BY, so we qualify it as p.sequence_number.
- Choosing types: census_tract_number and rate_spread are zero-padded
  ("0218.04", "01.90"), so they stay text to keep the leading zeros.
  minority_population and tract_to_msamd_income use numeric (not float) so
  no precision is lost.
- Our first export wrote blank fields unquoted (Postgres never quotes a
  NULL, even with FORCE_QUOTE), so diff flagged every row. We fixed this
  by exporting coalesce(col::text, '') for every column. An empty string
  does get quoted as "", so the output is now byte-for-byte identical.
- The full file is ~278 MB, so we tested against a 500-row sample
  (data/sample_500.csv) first.
- Time spent: roughly 10-12 hours total across the group (about 2.5-3
  hours each): ~4 hours on the ER diagram, ~5 hours writing and debugging
  the SQL scripts, and ~2 hours on the ilab load, screenshots and README.


5. Database Storage
---------------------
Akash Saha -- netid as3880 (table Preliminary, loaded on ilab1)
