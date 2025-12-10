# ❄️ Snowflake Internal Data Loading Project (Phase 1: Internal Stage)

This mini‑project treats **internal data loading into Snowflake** like a real GitHub repo you would show to hiring managers.

> Roadmap:  
> ✅ Phase 1 – Internal loading (this project)  
> ⏭️ Phase 2 – External data from AWS  
> ⏭️ Phase 3 – External data from Azure  

---

## 🎯 Objective

Load a **credit card customer CSV file** into a Snowflake table using:

1. A **clean role / warehouse / database / schema** setup  
2. A reusable **FILE FORMAT**  
3. An **internal named STAGE**  
4. A target **TABLE**  
5. A controlled **COPY INTO** from stage → table  
6. Basic **data‑quality checks** (duplicates, row count, history)

You told me what you currently do. I’ve kept all your good ideas but fixed / tightened the parts that are wrong or risky, like trying to `CREATE ROLE ACCOUNTADMIN` and table naming.

---

## 🧱 Folder / Script Structure

Suggested structure in your GitHub repo:

```text
snowflake-internal-loading/
├─ 01_setup_env.sql
├─ 02_create_internal_objects.sql
├─ 03_load_from_internal_stage.sql
├─ 04_direct_table_load_and_quality_checks.sql
└─ README_internal_loading.md
```

**What each script does:**

- **01_setup_env.sql**  
  - Uses the existing `ACCOUNTADMIN` role (no fake creation).  
  - Creates `DEMO_ROLE`, `DEMO_WAREHOUSE`, `DEMO_DATABASE`, `DEMO_SCHEMA`.  
  - Grants privileges so `DEMO_ROLE` can actually work.

- **02_create_internal_objects.sql**  
  - Creates a **CSV FILE FORMAT** (`CUSTOMER_CSV_FF`).  
  - Creates an **internal named stage** (`DEMO_STAGE`).  
  - Creates the **target table** `CUSTOMER_TRANSACTIONS` with all your columns.

- **03_load_from_internal_stage.sql**  
  - Assumes you uploaded `credit_card_customers.csv` into `DEMO_STAGE`.  
  - Runs `LIST @DEMO_STAGE` to confirm files.  
  - Runs `COPY INTO CUSTOMER_TRANSACTIONS ...` to load the data.  
  - Shows how `FORCE = TRUE` re‑loads the same file (duplicates).  
  - Shows how to query `COPY_HISTORY` to see what happened.

- **04_direct_table_load_and_quality_checks.sql**  
  - Explains **direct table load** (via UI) vs **stage then COPY**.  
  - Gives a **clean duplicate check** on `CUST_ID`.  
  - Shows an example de‑duplication pattern using `ROW_NUMBER`.  

---

## 🧠 Key Concepts (as your ruthless mentor)

1. **Do NOT create system roles**  
   - `ACCOUNTADMIN`, `SYSADMIN`, `SECURITYADMIN` already exist.  
   - You don’t do `CREATE ROLE IF NOT EXISTS ACCOUNTADMIN;` → that’s wrong.  
   - Instead: use `ACCOUNTADMIN` once to create a dedicated `DEMO_ROLE`.

2. **Internal stage vs direct table load**
   - **Internal stage first (recommended for projects):**
     - You control file naming and re‑runs.
     - You can re‑use the same staged file for multiple tables.
     - You can safely test `COPY` logic.
   - **Direct table load (UI “Load Data” on table):**
     - Fast for ad‑hoc loads.
     - Still uses a stage behind the scenes, but you don’t manage it.
     - Not ideal for a serious GitHub‑style project or production pipeline.

3. **Why you saw “0 rows loaded” when re‑loading a file from stage**
   - Snowflake tracks which **file names** were already loaded into a table.
   - If you run `COPY` again with the **same file name**, Snowflake by default **skips** it.
   - That’s why you saw zero rows.
   - To force it to load again, you use:
     ```sql
     COPY INTO CUSTOMER_TRANSACTIONS
     FROM @DEMO_STAGE/credit_card_customers.csv
     FILE_FORMAT = (FORMAT_NAME = CUSTOMER_CSV_FF)
     FORCE = TRUE;
     ```
   - Or you change the file name before upload.

4. **Primary keys are NOT enforced**
   - Even if you declare `PRIMARY KEY (CUST_ID)`, Snowflake will still allow duplicates.
   - That’s why your duplicate query is important and correct in spirit.
   - Final cleaned‑up duplicate check:
     ```sql
     SELECT
       CUST_ID,
       COUNT(*) AS TOTAL_COUNT
     FROM CUSTOMER_TRANSACTIONS
     GROUP BY CUST_ID
     HAVING COUNT(*) > 1
     ORDER BY TOTAL_COUNT DESC;
     ```

---

## 🚀 How to Run the Project End‑to‑End

1. **Run `01_setup_env.sql` as ACCOUNTADMIN**  
   - This prepares `DEMO_ROLE`, `DEMO_WAREHOUSE`, `DEMO_DATABASE`, `DEMO_SCHEMA`.  
   - Edit the line to `GRANT ROLE DEMO_ROLE TO USER <your_user>`.

2. **Switch to the project role**
   ```sql
   USE ROLE DEMO_ROLE;
   USE WAREHOUSE DEMO_WAREHOUSE;
   USE DATABASE DEMO_DATABASE;
   USE SCHEMA DEMO_SCHEMA;
   ```

3. **Run `02_create_internal_objects.sql`**  
   - Creates file format, stage, and table.

4. **Upload your CSV to the internal stage**  
   - UI or SnowSQL (`PUT ... @DEMO_STAGE`).

5. **Run `03_load_from_internal_stage.sql`**  
   - Confirms staged files.  
   - Executes `COPY INTO` to load data.

6. **Run `04_direct_table_load_and_quality_checks.sql`**  
   - Compare the “stage first, then COPY” approach with direct table load.  
   - Check for duplicates and row counts.

---

## 🔜 Next Phases

Once you say **“next”**, we’ll treat this as Phase 1 complete and:

1. **Phase 2 – AWS External Loading**
   - Create external stage pointing to S3.
   - IAM policy, storage integration.
   - COPY from S3 into the same `CUSTOMER_TRANSACTIONS` table (or a staging table).

2. **Phase 3 – Azure External Loading**
   - External stage for Azure Blob/ADLS.
   - Storage integration.
   - COPY into Snowflake with similar data‑quality checks.

You can drop these scripts and this README directly into a GitHub repo and you’ll have a **clean, professional internal loading project** ready.

