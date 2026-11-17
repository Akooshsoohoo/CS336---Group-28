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
    rate_spread                    numeric,   -- always written as "NN.NN" in the file (e.g. 01.90); the export re-pads it with to_char
    hoepa_status_name              text,
    hoepa_status                   integer,
    lien_status_name               text,
    lien_status                    integer,
    edit_status_name               text,
    edit_status                    integer,
    sequence_number_raw            text,      -- absorbs the file's blank sequence_number field so \copy stays positionally aligned; dropped below
    population                     integer,
    minority_population            numeric,
    hud_median_family_income       integer,
    tract_to_msamd_income          numeric,
    number_of_owner_occupied_units integer,
    number_of_1_to_4_family_units  integer,
    application_date_indicator     integer,
    -- sequence_number is 100% blank in the source data, so it's assigned here
    -- via IDENTITY rather than backfilled afterward with row_number(). IDENTITY
    -- calls nextval() once per input row as COPY parses it, in true file order,
    -- which matters because that order is NOT reliably recoverable after the
    -- fact: row_number() OVER () with no ORDER BY, run right after COPY, was
    -- tested against this data and mislabeled a large fraction of rows -- a
    -- bulk load's physical heap order for a wide (78-column) table does not
    -- reliably match input file order, even though it happens to for a
    -- narrow one-column table. IDENTITY sidesteps that because it's assigned
    -- during row parsing, before physical placement is decided.
    sequence_number                integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY
);

-- Load the CSV. Every field in the source file is double-quoted, including
-- blank ones (e.g. ""), and Postgres's CSV COPY only treats an *unquoted*
-- empty field as NULL by default -- a quoted "" is the literal empty string.
-- FORCE_NULL tells COPY to treat a quoted empty string as NULL too, for the
-- listed columns, which is required for every integer/numeric column here.
--
-- NOTE: \copy is a psql backslash (meta-)command, not plain SQL, so unlike a
-- regular multi-line SQL statement it must be entirely on one line -- psql
-- stops reading it at the first newline. Keep this as a single line.
\copy Preliminary (as_of_year, respondent_id, agency_name, agency_abbr, agency_code, loan_type_name, loan_type, property_type_name, property_type, loan_purpose_name, loan_purpose, owner_occupancy_name, owner_occupancy, loan_amount_000s, preapproval_name, preapproval, action_taken_name, action_taken, msamd_name, msamd, state_name, state_abbr, state_code, county_name, county_code, census_tract_number, applicant_ethnicity_name, applicant_ethnicity, co_applicant_ethnicity_name, co_applicant_ethnicity, applicant_race_name_1, applicant_race_1, applicant_race_name_2, applicant_race_2, applicant_race_name_3, applicant_race_3, applicant_race_name_4, applicant_race_4, applicant_race_name_5, applicant_race_5, co_applicant_race_name_1, co_applicant_race_1, co_applicant_race_name_2, co_applicant_race_2, co_applicant_race_name_3, co_applicant_race_3, co_applicant_race_name_4, co_applicant_race_4, co_applicant_race_name_5, co_applicant_race_5, applicant_sex_name, applicant_sex, co_applicant_sex_name, co_applicant_sex, applicant_income_000s, purchaser_type_name, purchaser_type, denial_reason_name_1, denial_reason_1, denial_reason_name_2, denial_reason_2, denial_reason_name_3, denial_reason_3, rate_spread, hoepa_status_name, hoepa_status, lien_status_name, lien_status, edit_status_name, edit_status, sequence_number_raw, population, minority_population, hud_median_family_income, tract_to_msamd_income, number_of_owner_occupied_units, number_of_1_to_4_family_units, application_date_indicator) FROM 'hmda_2017_nj_all-records_labels.csv' WITH (FORMAT csv, HEADER true, FORCE_NULL (as_of_year, agency_code, loan_type, property_type, loan_purpose, owner_occupancy, loan_amount_000s, preapproval, action_taken, msamd, state_code, county_code, applicant_ethnicity, co_applicant_ethnicity, applicant_race_1, applicant_race_2, applicant_race_3, applicant_race_4, applicant_race_5, co_applicant_race_1, co_applicant_race_2, co_applicant_race_3, co_applicant_race_4, co_applicant_race_5, applicant_sex, co_applicant_sex, applicant_income_000s, purchaser_type, denial_reason_1, denial_reason_2, denial_reason_3, rate_spread, hoepa_status, lien_status, edit_status, population, minority_population, hud_median_family_income, tract_to_msamd_income, number_of_owner_occupied_units, number_of_1_to_4_family_units, application_date_indicator))

ALTER TABLE Preliminary DROP COLUMN sequence_number_raw;
