-- CS336 Project 1 - Group 28
-- Screenshot queries: run with \i 03_screenshots.sql (or paste one at a time)
-- and screenshot each result. Together they cover all 78 attributes.
\pset pager off
\x on

SELECT sequence_number, as_of_year, respondent_id, agency_name, agency_abbr FROM Preliminary ORDER BY sequence_number LIMIT 3;
SELECT sequence_number, agency_code, loan_type_name, loan_type, property_type_name FROM Preliminary ORDER BY sequence_number LIMIT 3;
SELECT sequence_number, property_type, loan_purpose_name, loan_purpose, owner_occupancy_name FROM Preliminary ORDER BY sequence_number LIMIT 3;
SELECT sequence_number, owner_occupancy, loan_amount_000s, preapproval_name, preapproval FROM Preliminary ORDER BY sequence_number LIMIT 3;
SELECT sequence_number, action_taken_name, action_taken, msamd_name, msamd FROM Preliminary ORDER BY sequence_number LIMIT 3;
SELECT sequence_number, state_name, state_abbr, state_code, county_name FROM Preliminary ORDER BY sequence_number LIMIT 3;
SELECT sequence_number, county_code, census_tract_number, applicant_ethnicity_name, applicant_ethnicity FROM Preliminary ORDER BY sequence_number LIMIT 3;
SELECT sequence_number, co_applicant_ethnicity_name, co_applicant_ethnicity, applicant_race_name_1, applicant_race_1 FROM Preliminary ORDER BY sequence_number LIMIT 3;
SELECT sequence_number, applicant_race_name_2, applicant_race_2, applicant_race_name_3, applicant_race_3 FROM Preliminary ORDER BY sequence_number LIMIT 3;
SELECT sequence_number, applicant_race_name_4, applicant_race_4, applicant_race_name_5, applicant_race_5 FROM Preliminary ORDER BY sequence_number LIMIT 3;
SELECT sequence_number, co_applicant_race_name_1, co_applicant_race_1, co_applicant_race_name_2, co_applicant_race_2 FROM Preliminary ORDER BY sequence_number LIMIT 3;
SELECT sequence_number, co_applicant_race_name_3, co_applicant_race_3, co_applicant_race_name_4, co_applicant_race_4 FROM Preliminary ORDER BY sequence_number LIMIT 3;
SELECT sequence_number, co_applicant_race_name_5, co_applicant_race_5, applicant_sex_name, applicant_sex FROM Preliminary ORDER BY sequence_number LIMIT 3;
SELECT sequence_number, co_applicant_sex_name, co_applicant_sex, applicant_income_000s, purchaser_type_name FROM Preliminary ORDER BY sequence_number LIMIT 3;
SELECT sequence_number, purchaser_type, denial_reason_name_1, denial_reason_1, denial_reason_name_2 FROM Preliminary ORDER BY sequence_number LIMIT 3;
SELECT sequence_number, denial_reason_2, denial_reason_name_3, denial_reason_3, rate_spread FROM Preliminary ORDER BY sequence_number LIMIT 3;
SELECT sequence_number, hoepa_status_name, hoepa_status, lien_status_name, lien_status FROM Preliminary ORDER BY sequence_number LIMIT 3;
SELECT sequence_number, edit_status_name, edit_status, population, minority_population FROM Preliminary ORDER BY sequence_number LIMIT 3;
SELECT sequence_number, hud_median_family_income, tract_to_msamd_income, number_of_owner_occupied_units, number_of_1_to_4_family_units FROM Preliminary ORDER BY sequence_number LIMIT 3;
SELECT sequence_number, application_date_indicator FROM Preliminary ORDER BY sequence_number LIMIT 3;
