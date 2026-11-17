-- CS336 Project 2 - Group 28
-- Video 1: SELECT * from every normalized table (first rows only).
-- Run with:  psql -f 04_show_tables.sql
\pset pager off
\x auto
\echo '=== application'
SELECT * FROM application ORDER BY sequence_number LIMIT 3;
\echo '=== location'
SELECT * FROM location ORDER BY location_id LIMIT 5;
\echo '=== state'
SELECT * FROM state;
\echo '=== county'
SELECT * FROM county LIMIT 5;
\echo '=== msamd'
SELECT * FROM msamd LIMIT 5;
\echo '=== applicant_race'
SELECT * FROM applicant_race ORDER BY sequence_number, race_number LIMIT 5;
\echo '=== co_applicant_race'
SELECT * FROM co_applicant_race ORDER BY sequence_number, race_number LIMIT 5;
\echo '=== application_denial'
SELECT * FROM application_denial ORDER BY sequence_number, denial_reason_number LIMIT 5;
\echo '=== agency'
SELECT * FROM agency;
\echo '=== loan_type'
SELECT * FROM loan_type;
\echo '=== property_type'
SELECT * FROM property_type;
\echo '=== loan_purpose'
SELECT * FROM loan_purpose;
\echo '=== owner_occupancy'
SELECT * FROM owner_occupancy;
\echo '=== preapproval'
SELECT * FROM preapproval;
\echo '=== action_taken'
SELECT * FROM action_taken;
\echo '=== ethnicity'
SELECT * FROM ethnicity;
\echo '=== sex'
SELECT * FROM sex;
\echo '=== race'
SELECT * FROM race;
\echo '=== purchaser_type'
SELECT * FROM purchaser_type;
\echo '=== denial_reason'
SELECT * FROM denial_reason;
\echo '=== hoepa_status'
SELECT * FROM hoepa_status;
\echo '=== lien_status'
SELECT * FROM lien_status;
\echo '=== all_null_columns'
SELECT * FROM all_null_columns;
