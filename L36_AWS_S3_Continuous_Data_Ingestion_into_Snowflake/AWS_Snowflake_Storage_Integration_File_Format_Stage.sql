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

-- Create stage with storage integration
CREATE STAGE IF NOT EXISTS RETAIL -- Stage Name you can give anything
URL ='s3://retail-snowflake-aws'
-- credentials=(aws_key_id='****************'aws_secret_key='*******************')   -- (we Do not execute this if you are creating via storage Integration)
file_format = CSV_FORMAT
storage_integration = s3_int;

----(Or)----

-- Create stage with Credentials
CREATE STAGE IF NOT EXISTS RETAIL -- Stage Name you can give anything
URL ='s3://retail-snowflake-aws'
credentials = (aws_key_id='AKIA54WIFZPMH2WM2QNB'aws_secret_key='BOdiYxf63VzwzGiUOIstkyOV2Zqmfwxd8lHvNn')   -- Replace with your AWS Access Key
file_format = CSV_FORMAT
-- storage_integration = s3_int; -- (Do not execute this if you are creating via access key)

LIST @RETAIL;

SHOW STAGES;






