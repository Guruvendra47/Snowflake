# ❄️ Internal Stage Data Loading in Snowflake
**All required SQL scripts and data files have been uploaded to the GitHub repository under the "Data" and "SQL" folders for your reference.**

## Step 1: Use a powerful role

A role with full privileges is required to create warehouses, databases, schemas, and stages.
```sql
USE ROLE ACCOUNTADMIN;
```
This ensures you won’t face access issues while creating objects.

## Step 2: Create and select Warehouse
A warehouse is the compute engine that performs loading and querying.
```sql
CREATE WAREHOUSE IF NOT EXISTS DEMO_WAREHOUSE;
USE WAREHOUSE DEMO_WAREHOUSE;
```
**Note:** Data loading will not work unless a warehouse is active.

## Step 3: Create and select Database
A database is a logical container for schemas, tables, stages, and file formats.
```sql
CREATE DATABASE IF NOT EXISTS DEMO_DATABASE;
USE DEMO_DATABASE;
```
**Note:** Think of a database like a project folder.

## Step 4: Create and select Schema
Schemas help you organize Snowflake objects inside a database.
```sql
CREATE SCHEMA IF NOT EXISTS DEMO_SCHEMA;
USE SCHEMA DEMO_SCHEMA;
```
**For example:** DEMO_SCHEMA contains your table, stage, and file formats.

## Step 5: Create Internal Stage
An **Internal Stage** stores the files you want to load.
```sql
CREATE STAGE IF NOT EXISTS DEMO_STAGE;
```
This is where we will place files before loading them into a table.

**Note:** Internal stages are fully managed by Snowflake — no external cloud storage required.

## Step 6: Create File Format
A file format tells Snowflake how to read your CSV file.
```sql
CREATE FILE FORMAT IF NOT EXISTS DEMO_DATABASE.DEMO_SCHEMA.CUSTOMER_CSV_FF  
TYPE = 'CSV'  
COMPRESSION = 'AUTO'  
FIELD_DELIMITER = ','  
RECORD_DELIMITER = '\n'  
SKIP_HEADER = 1  
SKIP_BLANK_LINES = TRUE  
ERROR_ON_COLUMN_COUNT_MISMATCH = TRUE;
```
**Note:** Why this is important:
              - Snowflake knows how rows are separated
              - Snowflake handles missing lines and headers
              - Snowflake validates column structure (data quality)
              
## Step 7: Create Target Table
This is where your final data will be stored.
```sql
CREATE OR REPLACE TABLE DEMO_DATABASE.DEMO_SCHEMA.CUSTOMER_CVS_FF (  
CUST_ID VARCHAR(50) Primary key,  
CREDIT_CARD_NUMBER VARCHAR(50),  
BALANCE NUMBER(10,2),  
PURCHASES NUMBER(10,2),  
INSTALLMENTS_PURCHASES NUMBER(10,2),  
CASH_ADVANCE NUMBER(10,2),  
CREDIT_LIMIT NUMBER(10,2),  
PAYMENTS NUMBER(10,2),  
MINIMUM_PAYMENTS NUMBER(10,2),  
TENURE NUMBER(10,2),  
DATE_OF_TXN DATE  
);
```
**Note:** Primary keys are optional in Snowflake and are not enforced during loading. Duplicate values may exist unless you check them manually.


# ⭐ Step 8: Load File INTO STAGE (MANUALLY USING SNOWFLAKE UI)

This step uploads your CSV file into the internal stage.

**Why this step is required?**

Before loading into a table, Snowflake must store the file inside the internal stage.

**How to do it:**

1. Go to Snowflake Web UI
2. On the left menu, under **Work with data section**
3. Click on **Ingestion button** then click on **Add Data**
4. Select **Load files into a stage**
5. A popup window will appear:
    - Click **Browse**
    - Select the local CSV file from your computer
    - Click **Upload**
6. Now in the same popup:
    - Select **Database which you created in step 3 (DEMO_DATABASE)**
    - Select **Schema which you created in step 4 (DEMO_SCHEMA)**
    - Select **Stage which you created in step 5 (DEMO_STAGE)**
7. Click **Load**
   
**Note:** Your file is now stored inside Snowflake.


# ⭐ Step 9: Load Data FROM STAGE INTO TABLE (MANUALLY USING SNOWFLAKE UI)

This step loads data from the uploaded file into the target table.

**Why this step is required?**

Staged files are not queryable — you must load them into a Snowflake table to use them.

**How to do it:**

1. Again Click on **Ingestion button** then click on **Add Data**
2. Select **Load files into a table**
3. A popup window appears
4. Choose: **Add from stage**
5. Another popup opens:
     - Select **Database which you created in step 3 (DEMO_DATABASE)**
     - Select **Schema which you created in step 4 (DEMO_SCHEMA)**
     - A list of stages appears → choose **DEMO_STAGE (created in Step 5)**
     - Inside the stage you can view all uploaded files, select the file you want to **uploaded**
     - Click **Add**
6. Now in the main popup:
     - Select **Database which you created in step 3 (DEMO_DATABASE)**
     - Select **Schema which you created in step 4 (DEMO_SCHEMA)**
     - Select target table **Table which you created in step 7 (CUSTOMER_CVS_FF)** 
7. Click **Next**
8. Review settings → If errors appear, fix them
9. Click **Load**

**Note:** Snowflake reads the staged file and inserts rows into the table.


# Step 10: Validate Loaded Data
Check if data is successfully loaded.
```sql
SELECT COUNT(*) FROM DEMO_DATABASE.DEMO_SCHEMA.CUSTOMER_CVS_FF;
```
```sql
SELECT * FROM DEMO_DATABASE.DEMO_SCHEMA.CUSTOMER_CVS_FF LIMIT 10;
```
**Note:** Good practice: always validate row counts and sample records.

# Step 11: Check Duplicate Records
Because Snowflake does not enforce primary keys, duplicates can exist.
```sql
SELECT  
  CUST_ID,  
  COUNT(*) AS TOTAL_COUNT  
FROM DEMO_DATABASE.DEMO_SCHEMA.CUSTOMER_CVS_FF  
GROUP BY ALL  
HAVING COUNT(*) > 1  
ORDER BY TOTAL_COUNT DESC;
```
**Note:** This helps you identify duplicate customer IDs and row counts.
