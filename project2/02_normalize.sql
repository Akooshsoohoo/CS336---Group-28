-- CS336 Project 2 - Group 28
-- Steps 2-4: build the fully normalized (BCNF, 1NF) database from Preliminary.
--
-- Run with:  psql -f 02_normalize.sql      (Preliminary must already exist; it is
-- created by 01_create_and_load.sql from Project 1 and is never touched here.)
--
-- Conventions
-- * Every code -> name functional dependency gets its own lookup table; the main
--   table keeps only the (small) integer codes.
-- * Blank numeric fields were loaded as NULL; blank text fields were loaded as ''
--   in Preliminary. In the normalized tables a blank text value is stored as NULL
--   (NULLIF(x, '')) and the export turns NULL back into the blank field.
-- * Columns that are never NULL in the real data are NOT NULL.
-- * location_id is the only new key besides the application's sequence_number.

SET statement_timeout = 0;

BEGIN;

DROP TABLE IF EXISTS application_denial, co_applicant_race, applicant_race,
    application, location, county, msamd, state, all_null_columns, denial_reason,
    race, hoepa_status, lien_status, purchaser_type, sex, ethnicity, action_taken,
    preapproval, owner_occupancy, loan_purpose, property_type, loan_type, agency
    CASCADE;
DROP FUNCTION IF EXISTS keep_all_null_row();

-- ---------------------------------------------------------------- lookup tables

CREATE TABLE agency (
    agency_code smallint PRIMARY KEY,
    agency_name text NOT NULL,
    agency_abbr text NOT NULL
);
INSERT INTO agency SELECT DISTINCT agency_code, agency_name, agency_abbr FROM Preliminary;

CREATE TABLE loan_type (loan_type smallint PRIMARY KEY, loan_type_name text NOT NULL);
INSERT INTO loan_type SELECT DISTINCT loan_type, loan_type_name FROM Preliminary;

CREATE TABLE property_type (property_type smallint PRIMARY KEY, property_type_name text NOT NULL);
INSERT INTO property_type SELECT DISTINCT property_type, property_type_name FROM Preliminary;

CREATE TABLE loan_purpose (loan_purpose smallint PRIMARY KEY, loan_purpose_name text NOT NULL);
INSERT INTO loan_purpose SELECT DISTINCT loan_purpose, loan_purpose_name FROM Preliminary;

CREATE TABLE owner_occupancy (owner_occupancy smallint PRIMARY KEY, owner_occupancy_name text NOT NULL);
INSERT INTO owner_occupancy SELECT DISTINCT owner_occupancy, owner_occupancy_name FROM Preliminary;

CREATE TABLE preapproval (preapproval smallint PRIMARY KEY, preapproval_name text NOT NULL);
INSERT INTO preapproval SELECT DISTINCT preapproval, preapproval_name FROM Preliminary;

CREATE TABLE action_taken (action_taken smallint PRIMARY KEY, action_taken_name text NOT NULL);
INSERT INTO action_taken SELECT DISTINCT action_taken, action_taken_name FROM Preliminary;

CREATE TABLE purchaser_type (purchaser_type smallint PRIMARY KEY, purchaser_type_name text NOT NULL);
INSERT INTO purchaser_type SELECT DISTINCT purchaser_type, purchaser_type_name FROM Preliminary;

CREATE TABLE hoepa_status (hoepa_status smallint PRIMARY KEY, hoepa_status_name text NOT NULL);
INSERT INTO hoepa_status SELECT DISTINCT hoepa_status, hoepa_status_name FROM Preliminary;

CREATE TABLE lien_status (lien_status smallint PRIMARY KEY, lien_status_name text NOT NULL);
INSERT INTO lien_status SELECT DISTINCT lien_status, lien_status_name FROM Preliminary;

-- applicant and co-applicant share one ethnicity / sex / race code set
CREATE TABLE ethnicity (ethnicity smallint PRIMARY KEY, ethnicity_name text NOT NULL);
INSERT INTO ethnicity
SELECT applicant_ethnicity, applicant_ethnicity_name FROM Preliminary
UNION
SELECT co_applicant_ethnicity, co_applicant_ethnicity_name FROM Preliminary;

CREATE TABLE sex (sex smallint PRIMARY KEY, sex_name text NOT NULL);
INSERT INTO sex
SELECT applicant_sex, applicant_sex_name FROM Preliminary
UNION
SELECT co_applicant_sex, co_applicant_sex_name FROM Preliminary;

CREATE TABLE race (race smallint PRIMARY KEY, race_name text NOT NULL);
INSERT INTO race
SELECT applicant_race_1, applicant_race_name_1 FROM Preliminary WHERE applicant_race_1 IS NOT NULL
UNION SELECT applicant_race_2, applicant_race_name_2 FROM Preliminary WHERE applicant_race_2 IS NOT NULL
UNION SELECT applicant_race_3, applicant_race_name_3 FROM Preliminary WHERE applicant_race_3 IS NOT NULL
UNION SELECT applicant_race_4, applicant_race_name_4 FROM Preliminary WHERE applicant_race_4 IS NOT NULL
UNION SELECT applicant_race_5, applicant_race_name_5 FROM Preliminary WHERE applicant_race_5 IS NOT NULL
UNION SELECT co_applicant_race_1, co_applicant_race_name_1 FROM Preliminary WHERE co_applicant_race_1 IS NOT NULL
UNION SELECT co_applicant_race_2, co_applicant_race_name_2 FROM Preliminary WHERE co_applicant_race_2 IS NOT NULL
UNION SELECT co_applicant_race_3, co_applicant_race_name_3 FROM Preliminary WHERE co_applicant_race_3 IS NOT NULL
UNION SELECT co_applicant_race_4, co_applicant_race_name_4 FROM Preliminary WHERE co_applicant_race_4 IS NOT NULL
UNION SELECT co_applicant_race_5, co_applicant_race_name_5 FROM Preliminary WHERE co_applicant_race_5 IS NOT NULL;

CREATE TABLE denial_reason (denial_reason smallint PRIMARY KEY, denial_reason_name text NOT NULL);
INSERT INTO denial_reason
SELECT denial_reason_1, denial_reason_name_1 FROM Preliminary WHERE denial_reason_1 IS NOT NULL
UNION SELECT denial_reason_2, denial_reason_name_2 FROM Preliminary WHERE denial_reason_2 IS NOT NULL
UNION SELECT denial_reason_3, denial_reason_name_3 FROM Preliminary WHERE denial_reason_3 IS NOT NULL;

-- columns that are blank in every row of the CSV live in one all-NULL row
-- id is always 1, so a second row is a primary key violation; the trigger blocks
-- DELETE and TRUNCATE. The export CROSS JOINs this table, so it must keep exactly one row.
CREATE TABLE all_null_columns (
    id                         smallint PRIMARY KEY DEFAULT 1 CHECK (id = 1),
    edit_status                integer CHECK (edit_status IS NULL),
    edit_status_name           text    CHECK (edit_status_name IS NULL),
    application_date_indicator integer CHECK (application_date_indicator IS NULL)
);
INSERT INTO all_null_columns DEFAULT VALUES;

CREATE OR REPLACE FUNCTION keep_all_null_row() RETURNS trigger AS $$
BEGIN
    RAISE EXCEPTION 'all_null_columns must keep its single row';
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER all_null_columns_keep_row BEFORE DELETE OR TRUNCATE ON all_null_columns
    FOR EACH STATEMENT EXECUTE FUNCTION keep_all_null_row();

-- ------------------------------------------------------------ location tables

CREATE TABLE state (
    state_code smallint PRIMARY KEY,
    state_name text NOT NULL,
    state_abbr text NOT NULL
);
INSERT INTO state SELECT DISTINCT state_code, state_name, state_abbr FROM Preliminary;

CREATE TABLE county (
    state_code  smallint NOT NULL REFERENCES state (state_code),
    county_code smallint NOT NULL,
    county_name text     NOT NULL,
    PRIMARY KEY (state_code, county_code)
);
INSERT INTO county
SELECT DISTINCT state_code, county_code, county_name FROM Preliminary WHERE county_code IS NOT NULL;

CREATE TABLE msamd (
    msamd      integer PRIMARY KEY,
    msamd_name text            -- NULL for the two msamd codes that have no name in the CSV
);
INSERT INTO msamd
SELECT DISTINCT msamd, NULLIF(msamd_name, '') FROM Preliminary WHERE msamd IS NOT NULL;

CREATE TABLE location (
    location_id                    integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    state_code                     smallint NOT NULL REFERENCES state (state_code),
    county_code                    smallint,
    msamd                          integer REFERENCES msamd (msamd),
    census_tract_number            text,
    population                     integer,
    minority_population            numeric,
    hud_median_family_income       integer,
    tract_to_msamd_income          numeric,
    number_of_owner_occupied_units integer,
    number_of_1_to_4_family_units  integer,
    -- no real county: county_code is NULL, so the composite FK is not checked
    FOREIGN KEY (state_code, county_code) REFERENCES county (state_code, county_code),
    -- one row per distinct location; NULLs count as equal so "no tract data" is one location
    UNIQUE NULLS NOT DISTINCT (county_code, msamd, state_code, census_tract_number, population,
        minority_population, hud_median_family_income, tract_to_msamd_income,
        number_of_owner_occupied_units, number_of_1_to_4_family_units)
);
INSERT INTO location (state_code, county_code, msamd, census_tract_number, population,
    minority_population, hud_median_family_income, tract_to_msamd_income,
    number_of_owner_occupied_units, number_of_1_to_4_family_units)
SELECT DISTINCT state_code, county_code, msamd, NULLIF(census_tract_number, ''), population,
    minority_population, hud_median_family_income, tract_to_msamd_income,
    number_of_owner_occupied_units, number_of_1_to_4_family_units
FROM Preliminary
ORDER BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10;

-- --------------------------------------------------------------- application

CREATE TABLE application (
    sequence_number          integer GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    as_of_year               smallint NOT NULL,
    respondent_id            text     NOT NULL,
    agency_code              smallint NOT NULL,
    loan_type                smallint NOT NULL,
    property_type            smallint NOT NULL,
    loan_purpose             smallint NOT NULL,
    owner_occupancy          smallint NOT NULL,
    loan_amount_000s         integer  CHECK (loan_amount_000s >= 0),
    preapproval              smallint NOT NULL,
    action_taken             smallint NOT NULL,
    location_id              integer  NOT NULL,
    applicant_ethnicity      smallint NOT NULL,
    co_applicant_ethnicity   smallint NOT NULL,
    applicant_sex            smallint NOT NULL,
    co_applicant_sex         smallint NOT NULL,
    applicant_income_000s    integer  CHECK (applicant_income_000s >= 0),
    purchaser_type           smallint NOT NULL,
    rate_spread              numeric,
    hoepa_status             smallint NOT NULL,
    lien_status              smallint NOT NULL
);

-- Match each Preliminary row to its location. Plain "=" cannot match NULLs and a
-- NULL-safe IS NOT DISTINCT FROM join is a slow nested loop, so both sides are
-- turned into one text key (NULL -> '~') that can be hash-joined.
INSERT INTO application (sequence_number, as_of_year, respondent_id, agency_code, loan_type,
    property_type, loan_purpose, owner_occupancy, loan_amount_000s, preapproval, action_taken,
    location_id, applicant_ethnicity, co_applicant_ethnicity, applicant_sex, co_applicant_sex,
    applicant_income_000s, purchaser_type, rate_spread, hoepa_status, lien_status)
OVERRIDING SYSTEM VALUE
SELECT p.sequence_number, p.as_of_year, p.respondent_id, p.agency_code, p.loan_type,
    p.property_type, p.loan_purpose, p.owner_occupancy, p.loan_amount_000s, p.preapproval,
    p.action_taken, l.location_id, p.applicant_ethnicity, p.co_applicant_ethnicity,
    p.applicant_sex, p.co_applicant_sex, p.applicant_income_000s, p.purchaser_type,
    p.rate_spread, p.hoepa_status, p.lien_status
FROM Preliminary p
JOIN location l ON
    concat_ws('|', coalesce(p.county_code::text, '~'), coalesce(p.msamd::text, '~'),
        coalesce(p.state_code::text, '~'), coalesce(NULLIF(p.census_tract_number, ''), '~'),
        coalesce(p.population::text, '~'), coalesce(p.minority_population::text, '~'),
        coalesce(p.hud_median_family_income::text, '~'), coalesce(p.tract_to_msamd_income::text, '~'),
        coalesce(p.number_of_owner_occupied_units::text, '~'),
        coalesce(p.number_of_1_to_4_family_units::text, '~'))
  = concat_ws('|', coalesce(l.county_code::text, '~'), coalesce(l.msamd::text, '~'),
        coalesce(l.state_code::text, '~'), coalesce(l.census_tract_number, '~'),
        coalesce(l.population::text, '~'), coalesce(l.minority_population::text, '~'),
        coalesce(l.hud_median_family_income::text, '~'), coalesce(l.tract_to_msamd_income::text, '~'),
        coalesce(l.number_of_owner_occupied_units::text, '~'),
        coalesce(l.number_of_1_to_4_family_units::text, '~'));

-- keep the identity sequence ahead of the loaded rows so new inserts get fresh numbers
SELECT setval(pg_get_serial_sequence('application', 'sequence_number'),
              (SELECT max(sequence_number) FROM application));

-- ------------------------------------------- 1NF join tables (race_1..5, denial_1..3)

CREATE TABLE applicant_race (
    sequence_number integer  NOT NULL,
    race_number     smallint NOT NULL CHECK (race_number BETWEEN 1 AND 5),
    applicant_race  smallint NOT NULL,
    PRIMARY KEY (sequence_number, race_number)
);
INSERT INTO applicant_race
SELECT p.sequence_number, v.n, v.code
FROM Preliminary p
CROSS JOIN LATERAL (VALUES (1, p.applicant_race_1), (2, p.applicant_race_2), (3, p.applicant_race_3),
                           (4, p.applicant_race_4), (5, p.applicant_race_5)) AS v (n, code)
WHERE v.code IS NOT NULL;

CREATE TABLE co_applicant_race (
    sequence_number   integer  NOT NULL,
    race_number       smallint NOT NULL CHECK (race_number BETWEEN 1 AND 5),
    co_applicant_race smallint NOT NULL,
    PRIMARY KEY (sequence_number, race_number)
);
INSERT INTO co_applicant_race
SELECT p.sequence_number, v.n, v.code
FROM Preliminary p
CROSS JOIN LATERAL (VALUES (1, p.co_applicant_race_1), (2, p.co_applicant_race_2), (3, p.co_applicant_race_3),
                           (4, p.co_applicant_race_4), (5, p.co_applicant_race_5)) AS v (n, code)
WHERE v.code IS NOT NULL;

CREATE TABLE application_denial (
    sequence_number      integer  NOT NULL,
    denial_reason_number smallint NOT NULL CHECK (denial_reason_number BETWEEN 1 AND 3),
    denial_reason        smallint NOT NULL,
    PRIMARY KEY (sequence_number, denial_reason_number)
);
INSERT INTO application_denial
SELECT p.sequence_number, v.n, v.code
FROM Preliminary p
CROSS JOIN LATERAL (VALUES (1, p.denial_reason_1), (2, p.denial_reason_2), (3, p.denial_reason_3)) AS v (n, code)
WHERE v.code IS NOT NULL;

-- Foreign keys are added after the bulk load: Postgres validates a new FK with one
-- join instead of one lookup per inserted row (per-row checks hit the server timeout).
ALTER TABLE application ADD FOREIGN KEY (agency_code) REFERENCES agency (agency_code);
ALTER TABLE application ADD FOREIGN KEY (loan_type) REFERENCES loan_type (loan_type);
ALTER TABLE application ADD FOREIGN KEY (property_type) REFERENCES property_type (property_type);
ALTER TABLE application ADD FOREIGN KEY (loan_purpose) REFERENCES loan_purpose (loan_purpose);
ALTER TABLE application ADD FOREIGN KEY (owner_occupancy) REFERENCES owner_occupancy (owner_occupancy);
ALTER TABLE application ADD FOREIGN KEY (preapproval) REFERENCES preapproval (preapproval);
ALTER TABLE application ADD FOREIGN KEY (action_taken) REFERENCES action_taken (action_taken);
ALTER TABLE application ADD FOREIGN KEY (location_id) REFERENCES location (location_id);
ALTER TABLE application ADD FOREIGN KEY (applicant_ethnicity) REFERENCES ethnicity (ethnicity);
ALTER TABLE application ADD FOREIGN KEY (co_applicant_ethnicity) REFERENCES ethnicity (ethnicity);
ALTER TABLE application ADD FOREIGN KEY (applicant_sex) REFERENCES sex (sex);
ALTER TABLE application ADD FOREIGN KEY (co_applicant_sex) REFERENCES sex (sex);
ALTER TABLE application ADD FOREIGN KEY (purchaser_type) REFERENCES purchaser_type (purchaser_type);
ALTER TABLE application ADD FOREIGN KEY (hoepa_status) REFERENCES hoepa_status (hoepa_status);
ALTER TABLE application ADD FOREIGN KEY (lien_status) REFERENCES lien_status (lien_status);
ALTER TABLE applicant_race ADD FOREIGN KEY (sequence_number) REFERENCES application (sequence_number);
ALTER TABLE applicant_race ADD FOREIGN KEY (applicant_race) REFERENCES race (race);
ALTER TABLE co_applicant_race ADD FOREIGN KEY (sequence_number) REFERENCES application (sequence_number);
ALTER TABLE co_applicant_race ADD FOREIGN KEY (co_applicant_race) REFERENCES race (race);
ALTER TABLE application_denial ADD FOREIGN KEY (sequence_number) REFERENCES application (sequence_number);
ALTER TABLE application_denial ADD FOREIGN KEY (denial_reason) REFERENCES denial_reason (denial_reason);

COMMIT;

-- sanity checks
SELECT 'application' AS tbl, count(*) FROM application
UNION ALL SELECT 'location', count(*) FROM location
UNION ALL SELECT 'applicant_race', count(*) FROM applicant_race
UNION ALL SELECT 'co_applicant_race', count(*) FROM co_applicant_race
UNION ALL SELECT 'application_denial', count(*) FROM application_denial;
