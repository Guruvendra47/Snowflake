-- 04_verify_and_dedup.sql
-- Step 5: verification & duplicate detection

-- Basic row count
SELECT COUNT(*) AS total_rows
FROM DEMO_DATABASE.DEMO_SCHEMA.CUSTOMER_CVS_FF;

-- Duplicate detection based on CUST_ID
SELECT CUST_ID, COUNT(*) AS TOTAL_COUNT
FROM DEMO_DATABASE.DEMO_SCHEMA.CUSTOMER_CVS_FF
GROUP BY CUST_ID
HAVING COUNT(*) > 1
ORDER BY TOTAL_COUNT DESC;

-- Example deduplication strategy (create a deduped table using windowing):
CREATE OR REPLACE TABLE DEMO_DATABASE.DEMO_SCHEMA.CUSTOMER_CVS_FF_DEDUP AS
SELECT *
FROM (
  SELECT *,
    ROW_NUMBER() OVER (PARTITION BY CUST_ID ORDER BY DATE_OF_TXN DESC NULLS LAST) AS rn
  FROM DEMO_DATABASE.DEMO_SCHEMA.CUSTOMER_CVS_FF
) WHERE rn = 1;

-- Or use MERGE for incremental idempotent loads:
-- MERGE INTO target_table t
-- USING (SELECT * FROM staging_table) s
--   ON t.CUST_ID = s.CUST_ID
-- WHEN MATCHED THEN UPDATE SET ...
-- WHEN NOT MATCHED THEN INSERT (...);
