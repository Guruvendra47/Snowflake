-------------------------------------------------------------AWS-Storage-Integration-----------------------------------------------------

-- Create Storage Integration
CREATE STORAGE integration IF NOT EXISTS s3_int
TYPE = EXTERNAL_STAGE
STORAGE_PROVIDER = S3
ENABLED = TRUE
STORAGE_AWS_ROLE_ARN ='arn:aws:iam::954976291800:role/retail_role' 
STORAGE_ALLOWED_LOCATIONS =('s3://retail-snowflake-aws/');

DESC integration s3_int;

-------------------------------------------------------------------File-Format----------------------------------------------------------

--- Create file format
CREATE FILE FORMAT IF NOT EXISTS CSV_FORMAT
TYPE = 'CSV'
COMPRESSION = 'AUTO'
FIELD_DELIMITER = ','
RECORD_DELIMITER = '\n'
SKIP_HEADER = 1
SKIP_BLANK_LINES = TRUE
ERROR_ON_COLUMN_COUNT_MISMATCH = TRUE;

----------------------------------------------------------------------Stage-------------------------------------------------------------

-- Create stage
CREATE STAGE IF NOT EXISTS RETAIL
URL ='s3://retail-snowflake-aws'
file_format = CSV_FORMAT
storage_integration = s3_int;

LIST @RETAIL;

SHOW STAGES;