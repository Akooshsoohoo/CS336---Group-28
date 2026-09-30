CS336 - Project 1 - Group 28
=============================

0. Team Members
----------------
Full Name:                     NetID:
Keerthan Vijayavel             kv329
Udaya Chhetri                  ubc3
Harmon Jenkins                 hjj26
Akash Saha                     

1. Known Issues
----------------
The reconstructed CSV (sql/02_export_to_csv.sql output) is not byte-for-byte
identical to the original file for blank numeric fields. The source file
double-quotes every field, including blanks (e.g. ""), but Postgres's CSV
COPY only treats an *unquoted* empty field as NULL by default -- a quoted ""
is a literal empty string. We load blank numeric fields as SQL NULL (via
FORCE_NULL on COPY, since those columns can't hold an empty string), and
Postgres's COPY TO can never write a NULL back out as a quoted "" -- FORCE_QUOTE
explicitly excludes NULL values -- so those fields come back out as unquoted
empty fields instead. `diff` will report a difference on every row that has
at least one blank numeric field; the underlying data is otherwise identical
(verified programmatically, field-by-field, against the 500-row sample).


2. Collaboration
------------------
[Who did you collaborate with on this project? What resources and
references did you consult (e.g., draw.io guide, PostgreSQL docs, AI
tools)? Specify which aspect of the project each collaboration/resource
applied to.]


3. Data Insights & Entity Design
-----------------------------------
[What useful insights can you get from this data? What rules did you use
for dividing up the attributes into entities in the ER diagram?]


4. Development Challenges & Time Spent
------------------------------------------
[What problems did you face developing code for this project? Roughly how
long did you spend on this project?]


5. Database Storage
---------------------
[Which team member has stored the data in their database for grading
purposes? Provide their netid.]
