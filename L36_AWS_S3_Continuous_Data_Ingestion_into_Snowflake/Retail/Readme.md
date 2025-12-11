# ❄️ Snowflake + AWS S3 + Snowpipe (Auto Ingest) – End-to-End Guide

All required SQL scripts and data files have been uploaded to the GitHub repository under the "Data" and "SQL" folders for your reference.

---

## Step 1: Use a powerful role

A role with full privileges is required to create warehouses, databases, schemas, stages, and pipes.

```sql
USE ROLE ACCOUNTADMIN;
```

**Why?**
This ensures you won’t face access/privilege issues while creating Snowflake objects for the project.

---

## Step 2: Create and select Warehouse

A warehouse is the compute engine that performs loading and querying.

```sql
CREATE WAREHOUSE IF NOT EXISTS DEMO_WAREHOUSE;
USE WAREHOUSE DEMO_WAREHOUSE;
```

**Note:** **Data loading will not work** unless a warehouse is active.

---

## Step 3: Create and select Project Database

A database is a logical container for schemas, tables, stages, and file formats.

```sql
-- Create the Database
CREATE DATABASE IF NOT EXISTS RETAILS_DATABASE;
USE RETAILS_DATABASE;
```

> Think of a database like a **project folder** for all retail data.

---

## Step 4: Create and select Schema

Schemas help you organize Snowflake objects inside a database.

```sql
-- Create Schema
CREATE SCHEMA IF NOT EXISTS RETAILS_SCHEMA;
USE SCHEMA RETAILS_SCHEMA;
```

> Example: `RETAILS_SCHEMA` will contain your **tables, stages, file formats, pipes**, etc.

---

## Step 5: Create Raw Tables in Snowflake

These tables will store the raw data coming from S3 via Snowpipe.

```sql
-- Create DEMOGRAPHIC Table
CREATE TABLE IF NOT EXISTS DEMOGRAPHIC_RAW (
  AGE_DESC               CHAR(20),
  MARITAL_STATUS_CODE    CHAR(5),
  INCOME_DESC            VARCHAR(40),
  HOMEOWNER_DESC         VARCHAR(40),
  HH_COMP_DESC           VARCHAR(50),
  HOUSEHOLD_SIZE_DESC    VARCHAR(50),
  KID_CATEGORY_DESC      VARCHAR(40),
  household_key          INT PRIMARY KEY
);

-- Create CAMPAIGN_DESC Table
CREATE OR REPLACE TABLE CAMPAIGN_DESC_RAW (
  DESCRIPTION CHAR(10),
  CAMPAIGN    INT,
  START_DAY   INT,
  END_DAY     INT,
  PRIMARY KEY (DESCRIPTION),
  UNIQUE (CAMPAIGN)
);

-- Create CAMPAIGN Table
CREATE OR REPLACE TABLE CAMPAIGN_RAW (
  DESCRIPTION   CHAR(10),
  household_key INT,
  CAMPAIGN      INT,
  FOREIGN KEY (DESCRIPTION)   REFERENCES CAMPAIGN_DESC_RAW(DESCRIPTION),
  FOREIGN KEY (CAMPAIGN)      REFERENCES CAMPAIGN_DESC_RAW(CAMPAIGN),
  FOREIGN KEY (household_key) REFERENCES DEMOGRAPHIC_RAW(household_key)
);

-- Create PRODUCT Table
CREATE OR REPLACE TABLE PRODUCT_RAW (
  PRODUCT_ID           INT PRIMARY KEY,
  MANUFACTURER         INT,
  DEPARTMENT           VARCHAR(50),
  BRAND                VARCHAR(30),
  COMMODITY_DESC       VARCHAR(65),
  SUB_COMMODITY_DESC   VARCHAR(65),
  CURR_SIZE_OF_PRODUCT VARCHAR(15)
);

-- Create COUPON Table
CREATE OR REPLACE TABLE COUPON_RAW (
  COUPON_UPC INT,
  PRODUCT_ID INT,
  CAMPAIGN   INT,
  FOREIGN KEY (PRODUCT_ID) REFERENCES PRODUCT_RAW(PRODUCT_ID),
  FOREIGN KEY (CAMPAIGN)   REFERENCES CAMPAIGN_DESC_RAW(CAMPAIGN)
);

-- Create COUPON_REDEMPT Table
CREATE OR REPLACE TABLE COUPON_REDEMPT_RAW (
  household_key INT,
  DAY           INT,
  COUPON_UPC    INT,
  CAMPAIGN      INT,
  FOREIGN KEY (household_key) REFERENCES DEMOGRAPHIC_RAW(household_key),
  FOREIGN KEY (CAMPAIGN)      REFERENCES CAMPAIGN_DESC_RAW(CAMPAIGN)
);

-- Create TRANSACTION Table
CREATE OR REPLACE TABLE TRANSACTION_RAW (
  household_key      INT,
  BASKET_ID          INT,
  DAY                INT,
  PRODUCT_ID         INT,
  QUANTITY           INT,
  SALES_VALUE        FLOAT,
  STORE_ID           INT,
  RETAIL_DISC        FLOAT,
  TRANS_TIME         INT,
  WEEK_NO            INT,
  COUPON_DISC        INT,
  COUPON_MATCH_DISC  INT,
  FOREIGN KEY (PRODUCT_ID)   REFERENCES PRODUCT_RAW(PRODUCT_ID),
  FOREIGN KEY (household_key) REFERENCES DEMOGRAPHIC_RAW(household_key)
);

-- Check all tables
SHOW TABLES IN RETAILS_DATABASE.RETAILS_SCHEMA;
```

> Note: Foreign keys in Snowflake are **not enforced** by default; they are mainly for documentation.

---

## Step 6: Create S3 Bucket and Folders

Now move to **AWS Console**.

1. Login to AWS (or create an account).

2. Click on your **username (top-right)** → **Security credentials** to later create access keys (already needed for other integrations).

3. In the AWS search bar, type **S3** and open the S3 service.

4. Click **Create bucket**.

5. Enter a bucket name in lowercase, for example:

   `retail-snowflake-aws`

6. Choose region → Click **Create bucket**.

Now create folders inside the bucket to match Snowflake tables:

1. Click your bucket: `retail-snowflake-aws`
2. Click **Create folder** and create each folder with **exact names** (case sensitive):

   * `CAMPAIGN_DESC`
   * `CAMPAIGN`
   * `COUPON`
   * `COUPON_REDEMPT`
   * `DEMOGRAPHIC`
   * `PRODUCT`
   * `TRANSACTION`

> Important: Folder names are **case sensitive**. They must match exactly what you will use in Snowpipe `FROM '@RETAIL/<FOLDER>/'`.

---

## Step 7: Create IAM Policy for S3 Access

This policy gives Snowflake permission to read/write from your S3 bucket.

1. In AWS search bar, type **IAM** → open IAM.
2. On left menu, click **Policies** → **Create policy**.
3. Go to the **JSON** tab.
4. Delete everything and paste your policy (adjust bucket name):

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:DeleteObject",
        "s3:DeleteObjectVersion"
      ],
      "Resource": "arn:aws:s3:::retail-snowflake-aws/*"
    },
    {
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::retail-snowflake-aws"
    }
  ]
}
```

> Replace `retail-snowflake-aws` with **your** bucket name. The `"/*"` after bucket ARN means the policy applies to **all objects** inside the bucket.

5. Click **Next**.
6. Give a **Policy Name** (e.g., `retail_snowflake_s3_policy`).
7. Click **Create policy**.

---

## Step 8: Create IAM Role and Attach Policy

We create a role that Snowflake will assume to access S3.

1. In IAM, go to **Roles** → **Create role**.
2. Under **Trusted entity type**, select **AWS account**.
3. Click **Next**.
4. In **Permissions**, search and attach the policy you just created (`retail_snowflake_s3_policy`).
5. Click **Next**.
6. Give a **Role name** (e.g., `retail_role`) and description
   *Example: “Role for Snowflake Retail Project S3 access”*
7. Click **Create role**.
8. Open the role you just created and copy its **Role ARN**, e.g.:

```
arn:aws:iam::954976291800:role/retail_role
```

> This ARN will be used in the Snowflake storage integration.

---

## Step 9: Get S3 Bucket ARN

1. Go to **S3** → open your bucket `retail-snowflake-aws`.
2. Click on the **Properties** tab.
3. Find and copy the **Bucket ARN**, e.g.:

```
arn:aws:s3:::retail-snowflake-aws
```

You now have:

* **Role ARN** (IAM role)
* **Bucket ARN** (S3 bucket)

---

## Step 10: Create Snowflake Storage Integration (S3)

Use the two ARNs in Snowflake to define the integration.

```sql
-- Create Storage Integration
CREATE OR REPLACE STORAGE INTEGRATION s3_int
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = S3
  ENABLED = TRUE
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::954976291800:role/retail_role'
  STORAGE_ALLOWED_LOCATIONS = ('s3://retail-snowflake-aws/');

-- Describe integration to get details like STORAGE_AWS_IAM_USER_ARN
DESC INTEGRATION s3_int;
```

> Note: `STORAGE_ALLOWED_LOCATIONS` restricts which S3 paths this integration can access.

---

## Step 11: Create CSV File Format in Snowflake

This defines how Snowflake reads your CSV files.

```sql
-- Create file format
CREATE FILE FORMAT IF NOT EXISTS CSV_FORMAT
  TYPE = 'CSV'
  COMPRESSION = 'AUTO'
  FIELD_DELIMITER = ','
  RECORD_DELIMITER = '\n'
  SKIP_HEADER = 1
  SKIP_BLANK_LINES = TRUE
  ERROR_ON_COLUMN_COUNT_MISMATCH = TRUE;
```

> This ensures Snowflake correctly handles **headers, delimiters, line breaks, and column counts**.

---

## Step 12: Create External Stage for S3 Bucket

This stage points to your S3 bucket via the storage integration.

```sql
-- Create stage
CREATE OR REPLACE STAGE RETAIL
  URL = 's3://retail-snowflake-aws'
  FILE_FORMAT = CSV_FORMAT
  STORAGE_INTEGRATION = s3_int;
```

> `RETAIL` is now your external stage pointing to S3.

---

## Step 13: Test Stage Access with LIST

```sql
LIST @RETAIL;
```

* If it works, you will see files (when you upload them).
* If you get an error related to access / trust policy, fix it in the next step.

---

## Step 14: Fix Trust Relationship (if access error)

If `LIST @RETAIL;` fails with a trust/permission error:

1. In Snowflake, run:

```sql
DESC INTEGRATION s3_int;
```

2. Copy the value of `STORAGE_AWS_IAM_USER_ARN` (looks like):

```
arn:aws:iam::013001369188:user/xogc1000-s
```

3. Go to AWS → **IAM → Roles** → open your role `retail_role`.
4. Click the **Trust relationships** tab → **Edit trust policy**.
5. Replace the existing `AWS` principal (like `"arn:aws:iam::954976291800:root"`) with the `STORAGE_AWS_IAM_USER_ARN` from Snowflake.

Example (simplified):

```json
"Principal": {
  "AWS": "arn:aws:iam::013001369188:user/xogc1000-s"
}
```

6. Click **Update policy**.

Then re-run:

```sql
LIST @RETAIL;
```

> Now the stage should list files correctly once they exist in S3.

---

## Step 15: Verify All Stages

```sql
SHOW STAGES;
```

> Use this to confirm your `RETAIL` stage exists and uses `s3_int`.

---

## Step 16: Create Snowpipes for Each Folder (Auto Ingest)

Each pipe listens to a specific folder in S3 and loads the corresponding table.

```sql
-- DEMOGRAPHIC
CREATE PIPE IF NOT EXISTS RETAIL_SNOWPIPE_DEMOGRAPHIC AUTO_INGEST = TRUE AS
COPY INTO RETAILS_DATABASE.RETAILS_SCHEMA.DEMOGRAPHIC_RAW
FROM '@RETAIL/DEMOGRAPHIC/'
FILE_FORMAT = CSV_FORMAT;

-- CAMPAIGN_DESC
CREATE PIPE IF NOT EXISTS RETAIL_SNOWPIPE_CAMPAIGN_DESC AUTO_INGEST = TRUE AS
COPY INTO RETAILS_DATABASE.RETAILS_SCHEMA.CAMPAIGN_DESC_RAW
FROM '@RETAIL/CAMPAIGN_DESC/'
FILE_FORMAT = CSV_FORMAT;

-- CAMPAIGN
CREATE PIPE IF NOT EXISTS RETAIL_SNOWPIPE_CAMPAIGN AUTO_INGEST = TRUE AS
COPY INTO RETAILS_DATABASE.RETAILS_SCHEMA.CAMPAIGN_RAW
FROM '@RETAIL/CAMPAIGN/'
FILE_FORMAT = CSV_FORMAT;

-- PRODUCT
CREATE PIPE IF NOT EXISTS RETAIL_SNOWPIPE_PRODUCT AUTO_INGEST = TRUE AS
COPY INTO RETAILS_DATABASE.RETAILS_SCHEMA.PRODUCT_RAW
FROM '@RETAIL/PRODUCT/'
FILE_FORMAT = CSV_FORMAT;

-- COUPON
CREATE PIPE IF NOT EXISTS RETAIL_SNOWPIPE_COUPON AUTO_INGEST = TRUE AS
COPY INTO RETAILS_DATABASE.RETAILS_SCHEMA.COUPON_RAW
FROM '@RETAIL/COUPON/'
FILE_FORMAT = CSV_FORMAT;

-- COUPON_REDEMPT
CREATE PIPE IF NOT EXISTS RETAIL_SNOWPIPE_COUPON_REDEMPT AUTO_INGEST = TRUE AS
COPY INTO RETAILS_DATABASE.RETAILS_SCHEMA.COUPON_REDEMPT_RAW
FROM '@RETAIL/COUPON_REDEMPT/'
FILE_FORMAT = CSV_FORMAT;

-- TRANSACTION
CREATE PIPE IF NOT EXISTS RETAIL_SNOWPIPE_TRANSACTION AUTO_INGEST = TRUE AS
COPY INTO RETAILS_DATABASE.RETAILS_SCHEMA.TRANSACTION_RAW
FROM '@RETAIL/TRANSACTION/'
FILE_FORMAT = CSV_FORMAT;

-- Verify
SHOW PIPES;
```

> `AUTO_INGEST = TRUE` enables **event-based loading** when S3 sends notifications.

---

## Step 17: Get Snowpipe SQS ARN (Notification Channel)

From:

```sql
SHOW PIPES;
```

* Find your pipe (e.g., `RETAIL_SNOWPIPE_TRANSACTION`).
* Copy the value of `notification_channel`, which looks like:

```
arn:aws:sqs:us-east-1:013001369188:sf-snowpipe-AIDAQGBXREZSFQESYYH57-veE23Zx0sW1EbAf8RLoWQw
```

You will use this in the S3 event notification.

---

## Step 18: Configure S3 Event Notification for Snowpipe

This allows S3 to notify Snowpipe when new files are uploaded.

1. Go to **S3 → your bucket** `retail-snowflake-aws`.
2. Click **Properties** tab.
3. Scroll down to **Event notifications**.
4. Click **Create event notification**.
5. Give it a name (e.g., `aws_s3_retail_event`).
6. Under **Event types**, select:

   * **All object create events** (or whatever create events you want).
7. Under **Destination**, select **SQS queue**.
8. Under **Specify SQS queue**, choose **Enter SQS queue ARN** and paste the ARN from `SHOW PIPES` (notification_channel).
9. Save changes.

> Now, whenever a file is uploaded to the bucket/folders, an event will go to Snowpipe’s SQS and trigger loading.

---

## Step 19: Manually Refresh Pipes (if needed)

If files already exist in S3 before Snowpipe setup, or you want to force re-check:

```sql
----------------------------------------------------------PIPEREFRESH-----------------------------------------------------------------

ALTER PIPE RETAIL_SNOWPIPE_DEMOGRAPHIC       REFRESH;
ALTER PIPE RETAIL_SNOWPIPE_CAMPAIGN_DESC     REFRESH;
ALTER PIPE RETAIL_SNOWPIPE_CAMPAIGN          REFRESH;
ALTER PIPE RETAIL_SNOWPIPE_PRODUCT           REFRESH;
ALTER PIPE RETAIL_SNOWPIPE_COUPON            REFRESH;
ALTER PIPE RETAIL_SNOWPIPE_COUPON_REDEMPT    REFRESH;
ALTER PIPE RETAIL_SNOWPIPE_TRANSACTION       REFRESH;
```

> This tells Snowpipe to scan the S3 location and load any files that haven’t been loaded yet.

---

## Step 20: Validate Row Counts in Each Table

After files are uploaded and Snowpipe runs, check counts:

```sql
SELECT COUNT(*) FROM DEMOGRAPHIC_RAW;
SELECT COUNT(*) FROM CAMPAIGN_DESC_RAW;
SELECT COUNT(*) FROM CAMPAIGN_RAW;
SELECT COUNT(*) FROM PRODUCT_RAW;
SELECT COUNT(*) FROM COUPON_RAW;
SELECT COUNT(*) FROM COUPON_REDEMPT_RAW;
SELECT COUNT(*) FROM TRANSACTION_RAW;
```

> Good practice: verify row counts against source or expectations.

---

## Step 21: Check Snowpipe Status & Load History

These commands help debug loading or verify what was loaded.

```sql
--------------------------------------------------------Snowpipe-Status-----------------------------------------------------------------

-- Check status of a specific pipe
SELECT SYSTEM$PIPE_STATUS('RETAIL_SNOWPIPE_TRANSACTION');

-- Check recent copy history for a specific table (last 1 hour example)
SELECT *
FROM TABLE(
  INFORMATION_SCHEMA.COPY_HISTORY(
    TABLE_NAME => 'TRANSACTION_RAW',
    START_TIME => DATEADD(hours, -1, CURRENT_TIMESTAMP())
  )
);
```

> Use different table names and time windows as needed.

---

## Step 22: View Loaded Data

Finally, view the actual data:

```sql
SELECT * FROM DEMOGRAPHIC_RAW;
SELECT * FROM CAMPAIGN_DESC_RAW;
SELECT * FROM CAMPAIGN_RAW;
SELECT * FROM PRODUCT_RAW;
SELECT * FROM COUPON_RAW;
SELECT * FROM COUPON_REDEMPT_RAW;
SELECT * FROM TRANSACTION_RAW;
```

---

## Step 23: Show All Tables in the Schema

To confirm all raw tables exist and are in the correct schema:

```sql
SHOW TABLES IN SCHEMA RETAILS_DATABASE.RETAILS_SCHEMA;
```

---

If you want, I can next convert this into a GitHub-ready `.md` file with a title, TOC, and separate SQL files attached, or make a condensed quick-check checklist. Let me know which format you prefer.
