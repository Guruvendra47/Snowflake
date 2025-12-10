# Snowflake — Internal Data Load (GitHub Project)

## Overview
This repo demonstrates a clear, repeatable **internal** data-loading workflow into Snowflake (local/internal stage). It's built from user's notes and expanded to be GitHub-ready. The focus is step-by-step: **role -> warehouse -> database -> schema -> stage -> file format -> table -> load -> dedup/checks**. Use this as reference and copy into your own projects.

### What you'll find
- `sql/setup.sql` — statements to create roles, warehouse, database, schema, stage, file format, and table.
- `sql/load_and_validate.sql` — COPY, validation, dedup detection + MERGE pattern for idempotent loads.
- `data/sample_customers.csv` — example CSV to test the pipeline (small sample).
- `.gitignore` — ignore local artifacts for Git.

---
## Step-by-step guide (as requested)
**Format**: Step 1 → Step 5 and brief explanation for each step (so you can refer from GitHub quickly).

### Step 1 — Create role, warehouse, database, schema, stage
Why: clear separation of privileges and compute. Roles let you control access; warehouse controls compute cost; database/schema organize objects; stage stores files before loading.
Key example (see `sql/setup.sql`):
- `CREATE ROLE IF NOT EXISTS demo_role;`
- `CREATE WAREHOUSE IF NOT EXISTS demo_warehouse;` and `USE WAREHOUSE demo_warehouse;`
- `CREATE DATABASE IF NOT EXISTS demo_database;` and `CREATE SCHEMA IF NOT EXISTS demo_schema;`
- `CREATE STAGE IF NOT EXISTS demo_stage;` (internal stage)

### Step 2 — File format
Why: Consistent parsing of incoming files. Having a named FILE FORMAT makes COPY reusable and maintenance easier.
- Example in `sql/setup.sql` (`CUSTOMER_CSV_FF`) set to CSV, skip header, error controls, delimiter config.

### Step 3 — Create table schema
Why: The table is the canonical destination. Define appropriate types and any constraints (Snowflake doesn't enforce primary keys by default).
- The project includes `CUSTOMER_CVS_FF` table (note: intentionally keep names consistent with your notes).

### Step 4 — Load the data (stage → table)
Two ways you described:
- Direct table INSERTs (client-side uploads) — repeated identical loads may create duplicates.
- Stage-based loads: put files into a stage, then `COPY INTO` the table from that stage using the file format. Staging + COPY is the recommended pattern for large/batched files.
- `sql/load_and_validate.sql` contains `PUT`/`LIST`/`COPY INTO` examples and an idempotent MERGE approach.

Why use stage-first? You can validate file metadata and control idempotency (by using a control column like `source_file` + `loaded_at` or by staging into a temporary table then deduplicating).

### Step 5 — Check for duplicates and validation
Why: Snowflake does not force a primary key—so check after load. The repo includes queries to detect duplicates and a MERGE pattern to safely handle re-loads without blindly duplicating rows.
- Example duplicate check provided in `sql/load_and_validate.sql` (GROUP BY + HAVING > 1).

---
## How to use
1. Open `sql/setup.sql` and run in Snowflake worksheet (or from CLI using `snowsql`).
2. Upload `data/sample_customers.csv` to the `demo_stage` via Snowflake UI or use `PUT` if using SnowSQL (internal stage only works with SnowSQL for PUT). See notes in `sql/load_and_validate.sql`.
3. Run `sql/load_and_validate.sql` to COPY the file, validate, and deduplicate if needed.
4. Inspect duplicate queries and the MERGE pattern included for idempotent loads.

---
## Notes / pro tips
- Use `VALIDATION_MODE = RETURN_ERRORS` on COPY INTO if you want to preview parsing errors without loading.
- Use a staging (temp) table + MERGE to make loads idempotent.
- Keep `ERROR_ON_COLUMN_COUNT_MISMATCH = TRUE` during development; for production you may relax and capture rejected files into an error table.
- Always record `source_file` and `loaded_at` for each batch to improve traceability.

---
If you want, I can now:
- Produce more realistic sample CSVs (thousands of rows) and include them in the zip.
- Add a `README` badge and GitHub Actions workflow to run validations automatically.
- Move next to **external** loads (AWS S3) when you say *next*.

