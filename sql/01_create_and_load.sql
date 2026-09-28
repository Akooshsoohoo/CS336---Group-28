-- CS336 Project 1 - Group 28
-- Step 1: create the Preliminary table and load the NJ 2017 HMDA CSV into it.
--
-- Run this from the SAME directory as the CSV (so \copy's relative path works),
-- with:  psql -f 01_create_and_load.sql
-- or from inside psql:  \i 01_create_and_load.sql

DROP TABLE IF EXISTS Preliminary;

CREATE TABLE Preliminary (
    as_of_year                     integer,
    respondent_id                  text,
    agency_name                    text,
    agency_abbr                    text,
    agency_code                    integer,
    loan_type_name                 text,
    loan_type                      integer,
    property_type_name             text,
    property_type                  integer,
    loan_purpose_name              text,
    loan_purpose                   integer,
    owner_occupancy_name           text,
    owner_occupancy                integer,
    loan_amount_000s                integer,
    preapproval_name               text,
    preapproval                    integer,
    action_taken_name              text,
    action_taken                   integer,
    msamd_name                     text,
    msamd                          integer,
    state_name                     text,
    state_abbr                     text,
    state_code                     integer,
    county_name                    text,
    county_code                    integer,
    census_tract_number            text,
    applicant_ethnicity_name       text,
    applicant_ethnicity            integer,
    co_applicant_ethnicity_name    text,
    co_applicant_ethnicity         integer,
    applicant_race_name_1          text,
    applicant_race_1               integer,
    applicant_race_name_2          text,
    applicant_race_2               integer,
    applicant_race_name_3          text,
    applicant_race_3               integer,
    applicant_race_name_4          text,
    applicant_race_4               integer,
    applicant_race_name_5          text,
    applicant_race_5               integer,
    co_applicant_race_name_1       text,
    co_applicant_race_1            integer,
    co_applicant_race_name_2       text,
    co_applicant_race_2            integer,
    co_applicant_race_name_3       text,
    co_applicant_race_3            integer,
    co_applicant_race_name_4       text,
    co_applicant_race_4            integer,
    co_applicant_race_name_5       text,
    co_applicant_race_5            integer,
    applicant_sex_name             text,
    applicant_sex                  integer,
    co_applicant_sex_name          text,
    co_applicant_sex               integer,
    applicant_income_000s           integer,
    purchaser_type_name            text,
    purchaser_type                 integer,
    denial_reason_name_1           text,
    denial_reason_1                integer,
    denial_reason_name_2           text,
    denial_reason_2                integer,
    denial_reason_name_3           text,
    denial_reason_3                integer,
    rate_spread                    text,      -- fixed "NN.NN" display format (e.g. 01.90); kept as text to preserve the leading zero exactly
    hoepa_status_name              text,
    hoepa_status                   integer,
    lien_status_name               text,
    lien_status                    integer,
    edit_status_name               text,
    edit_status                    integer,
    sequence_number                integer,   -- always blank in the source file; populated below and promoted to primary key
    population                     integer,
    minority_population            numeric,
    hud_median_family_income       integer,
    tract_to_msamd_income          numeric,
    number_of_owner_occupied_units integer,
    number_of_1_to_4_family_units  integer,
    application_date_indicator     integer
);

-- Load the CSV. Empty, unquoted fields become NULL under CSV format by default.
\copy Preliminary FROM 'hmda_2017_nj_all-records_labels.csv' WITH (FORMAT csv, HEADER true)

-- sequence_number is 100% blank in the source data, so we number every row
-- 1..N in load (file) order and use that as the primary key, per the assignment.
WITH numbered AS (
    SELECT ctid, row_number() OVER () AS rn
    FROM Preliminary
)
UPDATE Preliminary p
SET sequence_number = numbered.rn
FROM numbered
WHERE p.ctid = numbered.ctid;

ALTER TABLE Preliminary ALTER COLUMN sequence_number SET NOT NULL;
ALTER TABLE Preliminary ADD PRIMARY KEY (sequence_number);
