# ⚡ Auto Data Load into Snowflake from Azure — Step‑by‑Step Procedure

> **Source:** original PDF screenshots and instructions (see page references noted below).

---

## Overview

This document converts the provided PDF into a single, clear, ordered **step-by-step** Markdown guide for setting up automatic ingestion from an Azure Storage account into Snowflake using Azure Event Grid / Storage Queue and Snowpipe. Where multiple short PDF steps were merged for clarity I note those merges in the **Merged steps** section at the end.

> Note: page references (e.g., `page 4`) refer to the pages of the uploaded PDF used to assemble this guide.

---

## Prerequisites

* Azure subscription with privileges to create Resource Groups, Storage Accounts, Queues, Event Grid / Event Subscriptions, and Enterprise Applications.
* Snowflake account with ability to create databases, tables, stages, integrations, and pipes.
* A CSV file to upload to the Azure Blob container for testing.

---

## 1 — Create an Azure Resource Group (pdf: pages 1–3)

1. In the Azure portal click **Create a resource**.
2. Search for **Resource group** and open it.
3. Click **Create**.
4. Enter a Resource Group name (e.g., `snowpipe`) and choose region.
5. Click **Review + create**, then **Create**.

> (pdf pages 1–3 show screenshots for these steps).

---

## 2 — Create an Azure Storage Account (pdf: pages 4–6)

1. Open the Resource Group you created (e.g., `snowpipe`).
2. Click **+ Create** inside the resource group.
3. Search the Marketplace for **Storage account** and select it.
4. Enter a Storage Account name (e.g., `snowpipeautodataload`).
5. Proceed through the tabs (Basics → Advanced … → Review) and click **Create** after validation.
6. Wait for deployment to complete (you will land on the deployment page).

---

## 3 — Create a Blob Container inside the Storage Account (pdf: page 7)

1. Open the created Storage Account in the portal.
2. From the left menu click **Containers**.
3. Click **+ Container**, provide a container name (e.g., `nkhealthcaredatablob`) and **Create**.

---

## 4 — Create a Storage Queue (pdf: pages 7–9)

1. In the Storage Account left menu click **Queues**.
2. Click **+ Queue**, provide a queue name (e.g., `nkhealthcaredataqueue`) and click **OK**.

---

## 5 — Register Azure Resource Providers (Event Grid / Event Hubs) (pdf: page 10)

1. Search for **Resource provider** from the portal home.
2. Search for `Microsoft.EventGrid` and register it.
3. Search for `Microsoft.EventHub` and register it.
4. Wait 4–5 minutes for registration to complete.

---

## 6 — Create Event Subscription for Storage Queue (pdf: pages 11–13)

1. From the Storage Account menu click **Events**.
2. Click **Create Event Subscription**.
3. Enter an Event Subscription name and System Topic name (e.g., `snowflakesnowpipeeventgrid`).
4. For **Endpoint type** choose **Storage Queues** and click **Select an endpoint**.
5. Choose the Storage Account and the Queue you created earlier, then **Create**.
6. Wait for the subscription to deploy — you will see a success page.

---

## 7 — Collect two important IDs: Tenant ID and Storage Queue ID (pdf: pages 14–15)

* **Tenant ID** (Azure Active Directory):

  1. From Azure Home, search **Azure Active Directory** and open it.
  2. Copy the **Tenant ID** from the Overview page.
* **Storage Notification Queue ID**:

  1. Open your Storage Account → **Queues** → click the queue.
  2. Copy the Queue ID / URL (you will paste this later into Snowflake integration settings).

---

## 8 — Create Snowflake database, table, and notification integration (pdf: page 16 ff)

Run the following SQL on Snowflake (adjust names and IDs to match your setup):

```sql
-- 1. Create database + use it
CREATE DATABASE IF NOT EXISTS AZURE_PIPELINE;
USE AZURE_PIPELINE;

-- 2. Create target table
CREATE OR REPLACE TABLE AZ_HEALTHCARE(
  Patientid VARCHAR(15),
  gender CHAR(8),
  age VARCHAR(5),
  hypertension CHAR(20),
  heart_disease CHAR(20),
  ever_married CHAR(30),
  work_type VARCHAR(60),
  Residence_type CHAR(30),
  avg_glucose_level VARCHAR(20),
  bmi VARCHAR(20),
  smoking_status VARCHAR(20),
  stroke CHAR(20)
);

-- 3. Create notification integration (replace tenant id & queue primary uri)
CREATE OR REPLACE NOTIFICATION INTEGRATION AZ_HEALTHCARE_EVENT
  ENABLED = TRUE
  TYPE = QUEUE
  NOTIFICATION_PROVIDER = AZURE_STORAGE_QUEUE
  AZURE_STORAGE_QUEUE_PRIMARY_URI = 'https://<your-storage-account>.queue.core.windows.net/<your-queue-name>'
  AZURE_TENANT_ID = '<your-tenant-id>';

-- 4. Verify
SHOW INTEGRATIONS;
DESC NOTIFICATION INTEGRATION AZ_HEALTHCARE_EVENT;
```

> After running `DESC NOTIFICATION INTEGRATION` you will get an `AZURE_CONSENT_URL` in the output. Copy and open that URL to grant Snowflake access to the Azure resources (next steps).

---

## 9 — Complete Azure consent for the Snowflake enterprise app (pdf: pages 17–19)

1. From the results of `DESC NOTIFICATION INTEGRATION` in Snowflake copy the `AZURE_CONSENT_URL` and open it in a new browser tab.
2. The page shows permission requests. Mark the checkbox **Consent on behalf of your organization** and click **Accept**.
3. In the Azure Portal search for **Enterprise applications**.
4. Find the created application (Snowflake-related enterprise app). Click it and copy the **Application Name**, **Application ID**, and **Object ID** for later.

---

## 10 — Assign Storage Queue Data role to the Snowflake Enterprise App (pdf: pages 20–22)

1. Go to the Storage Account → **Access control (IAM)**.
2. Click **Role assignments** → **+ Add** → **Add role assignment**.
3. Search for **Storage Queue Data Contributor** in the role list and select it.
4. Click **+ Select members** and paste/choose the Snowflake enterprise application name (from previous step).
5. Select it and click **Review + assign** → **Review + assign** again.
6. Confirm role assignment created successfully.

---

## 11 — Capture Blob service endpoint & generate Shared Access Signature (pdf: pages 23–26)

1. In the Storage Account go to **Endpoints** and copy the **Blob Service Primary Endpoint** (e.g., `https://<account>.blob.core.windows.net/`).
2. Search **Shared access signature (SAS)** in the Storage Account settings.
3. Tick required permissions (at minimum **container** and **object** permissions) and click **Generate SAS and connection string**.
4. Copy the **Blob Service SAS URL** and **SAS token** — you will use the SAS token when creating the Snowflake Stage.

---

## 12 — Note the blob container name and blob path (pdf: page 26–27)

1. From the Resource Group → Storage Account → Containers, locate the container and note the **Blob name** (container name and any folder path). Example used in the PDF: `nkhealthcaredatablob`.

---

## 13 — Create a Snowflake external stage referencing the Azure blob (pdf: page 27)

1. In Snowflake create a stage and reference the Azure blob URL in the `azure://` form and use the `azure_sas_token` credential. Example:

```sql
create or replace STAGE AZ_HEALTHCARE_STAGE
  URL = 'azure://<your-storage-account>.blob.core.windows.net/<your-container-name>/'
  credentials = (azure_sas_token = '<your-sas-token-here>');

-- Verify
SHOW STAGES;
LS @AZ_HEALTHCARE_STAGE;
```

> Replace `<your-sas-token-here>` with the token string produced by the SAS generator (do not include whitespace).

---

## 14 — Create a Snowpipe pipe (auto-ingest) (pdf: page 27)

Run the SQL to create a pipe that listens for events and loads files automatically:

```sql
create or replace pipe AZ_HEALTHCARE_PIPE
  auto_ingest = true
  integration = AZ_HEALTHCARE_EVENT
as
  copy into AZ_HEALTHCARE
  from @AZ_HEALTHCARE_STAGE
  file_format = (type = 'CSV' /* replace with your CSV file format or named file format like CSV_HEALTHCARE */);

-- Show pipes
SHOW PIPES;
```

---

## 15 — Upload a file to the blob container (pdf: page 28–29)

1. In Azure Portal navigate to Storage Account → Containers → select your container.
2. Click **Upload** → **Browse for files** → pick the CSV file → tick the checkbox → **Upload**.
3. Wait for the upload to complete.

---

## 16 — Validate data in Snowflake (pdf: page 29)

1. After upload Snowpipe (triggered by the Storage Queue event) should automatically copy the file into the Snowflake table.
2. Verify by running:

```sql
select count(*) from AZ_HEALTHCARE;
-- or
select * from AZ_HEALTHCARE limit 50;

-- If you need to force a scan:
alter pipe AZ_HEALTHCARE_PIPE refresh;
```

The PDF example shows row counts after the initial file (e.g., `Row Count: 5110`) and after subsequent upload (`5114`).

---

## Troubleshooting & Notes

* If `DESC NOTIFICATION INTEGRATION` does not return an `AZURE_CONSENT_URL`, confirm your integration creation and that the `AZURE_TENANT_ID` is correct.
* Role assignment (Storage Queue Data Contributor) must be applied to the Snowflake enterprise app. If ingestion fails, re-check IAM permissions and that the queue endpoint URL matches what was entered into the integration.
* Ensure SAS token expiry dates are long enough for testing; rotate SAS tokens securely for production.

---

## Merged steps (where I combined small PDF steps for clarity)

* **Merged steps 1–5 (pdf pages 1–3)**: Combined the separate clicks and minor validations for Resource Group creation into one grouped section.
* **Merged steps 6–11 (pdf pages 4–6)**: Grouped the Storage Account creation sequence (search → name → validation → create → deployment page) as one flow.
* **Merged steps 12–17 (pdf pages 7–9)**: Container + Queue creation and the immediate follow-ups were merged.
* **Merged steps 26–33 (pdf pages 14–17)**: The `Tenant ID` and `Queue ID` capture and Snowflake integration creation + `DESC` output handling are grouped into the Snowflake integration section for a smoother read-through.

---

## Quick checklist (copy-paste)

* [ ] Create Resource Group
* [ ] Create Storage Account
* [ ] Create Blob Container
* [ ] Create Storage Queue
* [ ] Register `Microsoft.EventGrid` & `Microsoft.EventHub`
* [ ] Create Event Subscription → Queue endpoint
* [ ] Collect Tenant ID & Queue ID
* [ ] Create Snowflake DB / Table
* [ ] Create Snowflake Notification Integration and run consent URL
* [ ] Assign Storage Queue Data Contributor role to Snowflake enterprise app
* [ ] Create Snowflake Stage (with SAS token)
* [ ] Create Snowpipe Pipe (auto_ingest = true)
* [ ] Upload file to Blob container
* [ ] Verify records in Snowflake

---

## Where in the PDF to look for screenshots

* Resource Group creation: pages **1–3**
* Storage Account creation: pages **4–6**
* Container & Queue creation: pages **7–9**
* Resource Provider registration: page **10**
* Event subscription and queue endpoint selection: pages **11–13**
* Tenant ID / Queue ID instructions: pages **14–15**
* Snowflake SQL + consent flow: pages **16–19**
* IAM role assignment steps: pages **20–22**
* SAS generation and blob endpoint: pages **23–26**
* Stage / Pipe creation and upload: pages **27–29**

---

Happy learning — this guide follows the PDF's sequence but reorganizes steps for clarity and practicality. If you want, I can also generate a single downloadable `.md` file or a GitHub-ready README with the exact SQL commands parameterized for your environment.

