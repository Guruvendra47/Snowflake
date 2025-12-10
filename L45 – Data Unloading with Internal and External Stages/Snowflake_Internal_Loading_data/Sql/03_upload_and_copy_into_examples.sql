-- 03_upload_and_copy_into_examples.sql
-- Step 4: upload to internal stage (PUT) and COPY INTO table
-- NOTE: PUT is executed from SnowSQL (or SnowPipe ingest), example shown here for SnowSQL:
-- from your shell:
-- PUT file://<local_path>/customers_sample.csv @DEMO_STAGE AUTO_COMPRESS=FALSE;

-- Check files in stage:
-- LIST @DEMO_STAGE;

-- Example COPY INTO (from a named file in stage):
COPY INTO DEMO_DATABASE.DEMO_SCHEMA.CUSTOMER_CVS_FF
FROM @DEMO_STAGE/customers_sample.csv
FILE_FORMAT = (FORMAT_NAME = DEMO_DATABASE.DEMO_SCHEMA.CUSTOMER_CSV_FF)
ON_ERROR = 'ABORT_STATEMENT';

-- Alternatively, copy all CSVs in stage:
-- COPY INTO DEMO_DATABASE.DEMO_SCHEMA.CUSTOMER_CVS_FF
-- FROM @DEMO_STAGE
-- FILE_FORMAT = (FORMAT_NAME = DEMO_DATABASE.DEMO_SCHEMA.CUSTOMER_CSV_FF)
-- PATTERN = '.*\.csv'
-- ON_ERROR = 'CONTINUE';

-- After successful load, you can REMOVE or MOVE processed files:
-- REMOVE @DEMO_STAGE/customers_sample.csv;
-- or use 'COPY INTO ...' clause to move files after success (if configured via pipe)
