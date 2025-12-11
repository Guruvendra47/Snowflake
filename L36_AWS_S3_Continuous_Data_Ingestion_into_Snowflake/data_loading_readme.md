# ❄️ Continuous Data Loading — AWS S3 → Snowflake (Step-by-step)

This guide is a **step-by-step** procedure that follows the PDF you uploaded. Images from the PDF are embedded under each relevant step to make the flow visual and easy to follow.

> Source screenshots and examples come from the original PDF (extracted images). See the end for a download link to all images.

---

## Table of contents

1. [Overview & prerequisites](#overview--prerequisites)
2. [Step 1 — Create S3 bucket](#step-1---create-s3-bucket)
3. [Step 2 — Create folder(s) in the bucket](#step-2---create-folders-in-the-bucket)
4. [Step 3 — Create IAM policy for the bucket](#step-3---create-iam-policy-for-the-bucket)
5. [Step 4 — Create IAM role and attach policy](#step-4---create-iam-role-and-attach-policy)
6. [Step 5 — Create Snowflake storage integration](#step-5---create-snowflake-storage-integration)
7. [Step 6 — Update role trust relationship with Snowflake values](#step-6---update-role-trust-relationship-with-snowflake-values)
8. [Step 7 — Create file format & external stage in Snowflake](#step-7---create-file-format--external-stage-in-snowflake)
9. [Step 8 — Create Snowpipe (AUTO_INGEST) per folder](#step-8---create-snowpipe-auto_ingest-per-folder)
10. [Step 9 — Configure S3 Event Notification (SQS) → Snowpipe](#step-9---configure-s3-event-notification-sqs--snowpipe)
11. [Validation & monitoring commands](#validation--monitoring-commands)
12. [Images archive](#images-archive)

---

## Overview & prerequisites

* Goal: Auto-ingest CSV files dropped into S3 folders into Snowflake tables using **Snowpipe**.
* You need: AWS account (S3, IAM, SQS), Snowflake account with `ACCOUNTADMIN` privileges.

> Keep the Snowflake `DESC INTEGRATION` output handy — it provides `STORAGE_AWS_IAM_USER_ARN` and `STORAGE_AWS_EXTERNAL_ID` which you will copy into AWS role trust policy.

---

## Step 1 - Create S3 bucket

1. Login to AWS Console → Services → S3 → Create bucket.
2. Use a lowercase bucket name (example: `retail-snowflake-aws`).

![S3 Console - create bucket](sandbox:/mnt/data/extracted_pdf_images/page1_img1.png)

---

## Step 2 - Create folders inside the bucket

1. Open your bucket → Create folder.
2. Create one folder per data feed (case-sensitive). Example folders from the PDF:

   * `snowpipe` (or `DEMOGRAPHIC`, `TRANSACTION`, etc.)

![Create folder in bucket](sandbox:/mnt/data/extracted_pdf_images/page2_img1.png)

---

## Step 3 - Create IAM policy for the bucket

1. AWS Console → IAM → Policies → Create policy → JSON tab.
2. Paste the policy JSON (replace the bucket name):

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

![IAM - Create policy JSON tab](sandbox:/mnt/data/extracted_pdf_images/page3_img1.png)

---

## Step 4 - Create IAM role and attach the policy

1. IAM → Roles → Create role → Trusted entity type: **AWS account**.
2. (Optional) Check **Require external ID** and enter a placeholder (we update this later).
3. Attach the policy created in Step 3 and create the role (e.g., `retail_role`).
4. Copy the **Role ARN** — you will use it in Snowflake.

![Create role and attach policy](sandbox:/mnt/data/extracted_pdf_images/page5_img1.png)

---

## Step 5 - Create Snowflake storage integration

In Snowflake (use `ACCOUNTADMIN`):

```sql
CREATE OR REPLACE STORAGE INTEGRATION snowpipe_integration
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = S3
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::YOUR_ACCOUNT_ID:role/retail_role'
  ENABLED = TRUE
  STORAGE_ALLOWED_LOCATIONS = ('s3://retail-snowflake-aws/');

-- Get integration metadata
DESC INTEGRATION snowpipe_integration;
```

The `DESC INTEGRATION` result returns two important values you will copy: **`STORAGE_AWS_IAM_USER_ARN`** and **`STORAGE_AWS_EXTERNAL_ID`**.

![Storage integration example in Snowflake](sandbox:/mnt/data/extracted_pdf_images/page8_img1.png)

---

## Step 6 - Update role trust relationship with Snowflake values

1. In AWS Console → IAM → Roles → open your role (e.g., `retail_role`).
2. Click **Trust relationships** → **Edit trust policy**.
3. Replace the `Principal` value with the `STORAGE_AWS_IAM_USER_ARN` and set the `sts:ExternalId` to the `STORAGE_AWS_EXTERNAL_ID` from `DESC INTEGRATION`.

*Sample trust policy structure (fill with your actual strings):*

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "AWS": "arn:aws:iam::012345678901:user/snowflake_user" },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": { "sts:ExternalId": "<STORAGE_AWS_EXTERNAL_ID>" }
      }
    }
  ]
}
```

![Edit trust relationship in IAM role](sandbox:/mnt/data/extracted_pdf_images/page4_img1.png)

---

## Step 7 - Create file format & external stage in Snowflake

Create a CSV file format:

```sql
CREATE FILE FORMAT IF NOT EXISTS CSV_FORMAT
  TYPE = 'CSV'
  COMPRESSION = 'AUTO'
  FIELD_DELIMITER = ','
  RECORD_DELIMITER = '\n'
  SKIP_HEADER = 1
  SKIP_BLANK_LINES = TRUE
  ERROR_ON_COLUMN_COUNT_MISMATCH = TRUE;
```

Create the external stage pointing to your bucket/folder:

```sql
CREATE OR REPLACE STAGE patient_snowpipe_stage
  STORAGE_INTEGRATION = snowpipe_integration
  URL = 's3://patientsnowpipebucket/snowpipe'
  FILE_FORMAT = (FORMAT_NAME = 'CSV_FORMAT');

LIST @patient_snowpipe_stage;
```

![Create file format UI example](sandbox:/mnt/data/extracted_pdf_images/page10_img1.png)

---

## Step 8 - Create Snowpipe(s) with AUTO_INGEST = TRUE

Create a pipe for the folder that should auto-load into a Snowflake table:

```sql
CREATE OR REPLACE PIPE patient_snowpipe
  AUTO_INGEST = TRUE
AS
COPY INTO tab_patient
FROM @patient_snowpipe_stage
FILE_FORMAT = (FORMAT_NAME = 'CSV_FORMAT');

SHOW PIPES;
```

Copy the `notification_channel` value (SQS ARN) from `SHOW PIPES` or from the Pipes UI — you will use it as the destination for S3 notifications.

![Create pipe - Snowpipe example](sandbox:/mnt/data/extracted_pdf_images/page11_img1.png)

---

## Step 9 - Configure S3 Event Notification → SQS → Snowpipe

1. Go to the S3 bucket → **Properties** → **Event notifications** → **Create event notification**.
2. Name it (e.g., `snowpipe_event`).
3. Event types: **All object create events**.
4. Destination: **SQS queue** → **Enter SQS queue ARN** → paste the `notification_channel` ARN from Snowflake.
5. Save.

![S3 Event notification UI example](sandbox:/mnt/data/extracted_pdf_images/page12_img1.png)

Now, files uploaded to the configured folder will trigger S3 → SQS → Snowpipe and Snowpipe will auto-load the files into the target table.

---

## Validation & monitoring commands

* Force Snowpipe to scan for existing files:

```sql
ALTER PIPE patient_snowpipe REFRESH;
```

* Check row counts in tables:

```sql
SELECT COUNT(*) FROM my_schema.demographic_raw;
```

* Check Snowpipe status and load history:

```sql
SELECT SYSTEM$PIPE_STATUS('patient_snowpipe');

SELECT *
FROM TABLE(
  INFORMATION_SCHEMA.COPY_HISTORY(
    TABLE_NAME => 'tab_patient',
    START_TIME => DATEADD(hours, -1, CURRENT_TIMESTAMP())
  )
);
```

![ALT_TEXT](images/screenshot1.png)

![Snowpipe status & copy history example](sandbox:/mnt/data/extracted_pdf_images/page1_img1.png)

---

## Images archive

I extracted the PDF screenshots and saved them for you. Download the full archive here:

[Download extracted images (ZIP)](sandbox:/mnt/data/extracted_pdf_images.zip)

---

If you want any of these changes:

* Move this guide into a GitHub-ready `.md` repo (I can split SQL into separate `.sql` files).
* Produce a one-page printable checklist.
* Replace any image with a different page image from the extracted set.
