# Uploading the HMDA data to the ilab database

Source file: `hmda_2017_nj_all-records_labels.csv` (NJ, 2017, "All records",
plain-language labels, downloaded from the
[CFPB HMDA historic data page](https://www.consumerfinance.gov/data-research/hmda/historic-data/)).
78 columns, ~349,563 rows, ~278 MB — it is intentionally **not** committed to
git (see `data/.gitignore`); each teammate downloads it themselves.

## Schema notes

`sql/01_create_and_load.sql` types every column from the CSV header. The rule
used:

- **`integer`** — genuine numeric codes/counts (loan_type, action_taken,
  applicant_race_1, population, sequence_number, etc.)
- **`text`** — free-text labels (every `*_name` column), IDs (`respondent_id`),
  and the two fixed-width formatted fields **`census_tract_number`**
  (`"0218.04"`) and **`rate_spread`** (`"01.90"`). These are kept as text
  instead of `numeric` specifically because they're zero-padded to a fixed
  width — casting to `numeric` would silently drop the leading zero and break
  the round-trip diff.
- **`numeric`** — `minority_population` and `tract_to_msamd_income`. Postgres's
  `numeric` type stores decimal digits exactly as parsed (unlike `float`), so
  these survive the round trip even though some values carry 15+ decimal
  digits.
- `sequence_number` is blank for every row in the source file. We fill it with
  `row_number() OVER ()` in load order and make it the primary key, per the
  assignment. On export it's written back out as blank so the reconstructed
  CSV matches the original.

## Steps (run on ilab)

```bash
# 1. get the CSV onto ilab, in the same directory as the SQL scripts
scp hmda_2017_nj_all-records_labels.csv <netid>@ilab.cs.rutgers.edu:~/CS336-Group-28/sql/
scp sql/01_create_and_load.sql sql/02_export_to_csv.sql <netid>@ilab.cs.rutgers.edu:~/CS336-Group-28/sql/

# 2. ssh in, cd to that folder, open the postgres shell
ssh <netid>@ilab.cs.rutgers.edu
cd CS336-Group-28/sql
postgres
```

Inside the `psql` shell:

```sql
\i 01_create_and_load.sql
```

Check a few columns to confirm the load and grab the screenshots required for
submission, e.g.:

```sql
SELECT loan_type_name, loan_amount_000s, action_taken_name FROM Preliminary LIMIT 20;
```

Then reconstruct the CSV and diff it against the original:

```sql
\i 02_export_to_csv.sql
\q
```

```bash
diff hmda_2017_nj_all-records_labels.csv reconstructed.csv
```

No output from `diff` means the files are identical. If it reports
differences, they should only ever be in formatting of a numeric column —
document any remaining mismatch in the README's "Known Issues" section
rather than silently leaving it.

## What to submit

- Screenshots of `SELECT X, Y, Z FROM Preliminary;` covering every attribute.
- `sql/01_create_and_load.sql`
- `sql/02_export_to_csv.sql`
