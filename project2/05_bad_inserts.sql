-- CS336 Project 2 - Group 28
-- Video 2: invalid changes the database must reject (each fails for a different reason).
-- Run with:  psql -f 05_bad_inserts.sql
\pset pager off
\set VERBOSITY terse

\echo '1. property_type 4 does not exist  -> foreign key violation'
INSERT INTO application (as_of_year, respondent_id, agency_code, loan_type, property_type, loan_purpose, owner_occupancy, preapproval, action_taken, location_id, applicant_ethnicity, co_applicant_ethnicity, applicant_sex, co_applicant_sex, purchaser_type, hoepa_status, lien_status) SELECT as_of_year, respondent_id, agency_code, loan_type, 4, loan_purpose, owner_occupancy, preapproval, action_taken, location_id, applicant_ethnicity, co_applicant_ethnicity, applicant_sex, co_applicant_sex, purchaser_type, hoepa_status, lien_status FROM application WHERE sequence_number = 1;

\echo '2. respondent_id is missing  -> NOT NULL violation'
INSERT INTO application (as_of_year) VALUES (2017);

\echo '3. sequence_number 1 already exists  -> primary key violation'
INSERT INTO application SELECT * FROM application WHERE sequence_number = 1;

\echo '4. race_number 6 is out of range  -> check violation'
INSERT INTO applicant_race VALUES (1, 6, 5);

\echo '5. county 999 does not exist in state 34  -> composite foreign key violation'
INSERT INTO location (state_code, county_code) VALUES (34, 999);

\echo '6. edit_status must stay empty  -> check violation'
INSERT INTO all_null_columns (edit_status) VALUES (1);

\echo '7. a second all_null_columns row  -> primary key violation'
INSERT INTO all_null_columns DEFAULT VALUES;

\echo '8. emptying all_null_columns  -> trigger rejects the delete'
DELETE FROM all_null_columns;

\echo 'Row count is unchanged:'
SELECT count(*) AS applications FROM application;
