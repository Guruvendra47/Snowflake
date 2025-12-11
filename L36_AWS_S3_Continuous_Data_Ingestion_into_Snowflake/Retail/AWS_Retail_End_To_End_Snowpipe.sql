----------------------------------------------------------Database-Schema------------------------------------------------------------

-- Create the Database
CREATE DATABASE IF NOT EXISTS RETAILS_DATABASE;
USE RETAILS_DATABASE;

-- Create Schema
CREATE SCHEMA IF NOT EXISTS RETAILS_SCHEMA;
USE SCHEMA RETAILS_SCHEMA;

------------------------------------------------------------Create-Table----------------------------------------------------------------

-- Creat DEMOGRAPHIC Table
CREATE TABLE IF NOT EXISTS demographic_RAW (
AGE_DESC	CHAR(20),
MARITAL_STATUS_CODE	CHAR(5),
INCOME_DESC	VARCHAR(40),
HOMEOWNER_DESC	VARCHAR(40),
HH_COMP_DESC	VARCHAR(50),
HOUSEHOLD_SIZE_DESC	VARCHAR(50),
KID_CATEGORY_DESC	VARCHAR(40),
household_key INT PRIMARY KEY
);

-- Create CAMPAIGN_DESC Table
CREATE TABLE IF NOT EXISTS CAMPAIGN_DESC_RAW (
DESCRIPTION CHAR(10),	
CAMPAIGN	INT ,
START_DAY	INT,
END_DAY INT,
PRIMARY KEY (DESCRIPTION),
UNIQUE (CAMPAIGN));

-- Create CAMPAIGN Table
CREATE TABLE IF NOT EXISTS CAMPAIGN_RAW (
DESCRIPTION	CHAR(10) ,
household_key	INT,
CAMPAIGN INT,
FOREIGN KEY (DESCRIPTION) references CAMPAIGN_DESC_RAW(DESCRIPTION) ,
FOREIGN KEY (CAMPAIGN) references CAMPAIGN_DESC_RAW(CAMPAIGN),
FOREIGN KEY (household_key) references demographic_RAW(household_key)
);

-- Create PRODUCT Table
CREATE TABLE IF NOT EXISTS PRODUCT_RAW (
PRODUCT_ID	INT PRIMARY KEY,
MANUFACTURER 	INT,
DEPARTMENT	VARCHAR(50),
BRAND	VARCHAR(30),
COMMODITY_DESC	VARCHAR(65),
SUB_COMMODITY_DESC VARCHAR(65)	,
CURR_SIZE_OF_PRODUCT VARCHAR(15)
);

-- Create COUPON Table
CREATE TABLE IF NOT EXISTS COUPON_RAW (
COUPON_UPC	INT,
PRODUCT_ID	INT,
CAMPAIGN INT,
FOREIGN KEY (PRODUCT_ID) references PRODUCT_RAW(PRODUCT_ID),
FOREIGN KEY (CAMPAIGN) references CAMPAIGN_DESC_RAW(CAMPAIGN)
);

-- Create COUPON_REDEMPT Table
CREATE TABLE IF NOT EXISTS COUPON_REDEMPT_RAW (
household_key	INT,
DAY	INT,
COUPON_UPC	INT,
CAMPAIGN INT,
FOREIGN KEY (household_key) references demographic_RAW(household_key),
FOREIGN KEY (CAMPAIGN) references CAMPAIGN_DESC_RAW(CAMPAIGN)
);

-- Create TRANSACTION Table
CREATE TABLE IF NOT EXISTS TRANSACTION_RAW (
household_key	INT,
BASKET_ID	INT,
DAY	INT,
PRODUCT_ID	INT,
QUANTITY	INT,
SALES_VALUE	FLOAT,
STORE_ID	INT,
RETAIL_DISC	FLOAT,
TRANS_TIME	INT,
WEEK_NO	INT,
COUPON_DISC	INT,
COUPON_MATCH_DISC INT,
FOREIGN KEY (PRODUCT_ID) references PRODUCT_RAW(PRODUCT_ID),
FOREIGN KEY (household_key) references demographic_RAW(household_key)
);

----------------------------------------------------------------Storage-Integration-----------------------------------------------------

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

-------------------------------------------------------------Event-Notification-Pipe----------------------------------------------------

--CREATE SNOWPIPE THAT RECOGNISES CSV THAT ARE INGESTED FROM EXTERNAL STAGE AND COPIES THE DATA INTO EXISTING TABLE

--The AUTO_INGEST=true parameter specifies to read 
--- event notifications sent from an S3 bucket to an SQS queue when new data is ready to load.


CREATE PIPE IF NOT EXISTS RETAIL_SNOWPIPE_DEMOGRAPHIC AUTO_INGEST = TRUE AS
COPY INTO RETAILS_DATABASE.RETAILS_SCHEMA.DEMOGRAPHIC_RAW --yourdatabase.your schema.your table
FROM '@RETAIL/DEMOGRAPHIC/' --stage/s3 bucket folder name -- WE type @ in front of stage when bring file from stage
FILE_FORMAT =  CSV_FORMAT; -- Here you replace File format which you will create

CREATE PIPE IF NOT EXISTS RETAIL_SNOWPIPE_CAMPAIGN_DESC AUTO_INGEST = TRUE AS
COPY INTO RETAILS_DATABASE.RETAILS_SCHEMA.CAMPAIGN_DESC_RAW
FROM '@RETAIL/CAMPAIGN_DESC/' 
FILE_FORMAT =  CSV_FORMAT;

CREATE PIPE IF NOT EXISTS RETAIL_SNOWPIPE_CAMPAIGN AUTO_INGEST = TRUE AS
COPY INTO RETAILS_DATABASE.RETAILS_SCHEMA.CAMPAIGN_RAW
FROM '@RETAIL/CAMPAIGN/' 
FILE_FORMAT =  CSV_FORMAT;

CREATE PIPE IF NOT EXISTS RETAIL_SNOWPIPE_PRODUCT AUTO_INGEST = TRUE AS
COPY INTO RETAILS_DATABASE.RETAILS_SCHEMA.PRODUCT_RAW
FROM '@RETAIL/PRODUCT/' 
FILE_FORMAT =  CSV_FORMAT;


CREATE PIPE IF NOT EXISTS RETAIL_SNOWPIPE_COUPON AUTO_INGEST = TRUE AS
COPY INTO RETAILS_DATABASE.RETAILS_SCHEMA.COUPON_RAW
FROM '@RETAIL/COUPON/' 
FILE_FORMAT =  CSV_FORMAT;

CREATE PIPE IF NOT EXISTS RETAIL_SNOWPIPE_COUPON_REDEMPT  AUTO_INGEST = TRUE AS
COPY INTO RETAILS_DATABASE.RETAILS_SCHEMA.COUPON_REDEMPT_RAW
FROM '@RETAIL/COUPON_REDEMPT/' 
FILE_FORMAT =  CSV_FORMAT;

CREATE PIPE IF NOT EXISTS RETAIL_SNOWPIPE_TRANSACTION  AUTO_INGEST = TRUE AS
COPY INTO RETAILS_DATABASE.RETAILS_SCHEMA.TRANSACTION_RAW
FROM '@RETAIL/TRANSACTION/' 
FILE_FORMAT =  CSV_FORMAT;

SHOW PIPES;

----------------------------------------------------------PIPEREFRESH-----------------------------------------------------------------

-- Client loaded data in AWS you need to execute following command to referesh the folder that data will be loaded automatically
ALTER PIPE RETAIL_SNOWPIPE_DEMOGRAPHIC refresh;
ALTER PIPE  RETAIL_SNOWPIPE_CAMPAIGN_DESC refresh;
ALTER PIPE  RETAIL_SNOWPIPE_CAMPAIGN refresh;
ALTER PIPE  RETAIL_SNOWPIPE_PRODUCT refresh;
ALTER PIPE  RETAIL_SNOWPIPE_COUPON refresh;
ALTER PIPE  RETAIL_SNOWPIPE_COUPON_REDEMPT refresh;
ALTER PIPE  RETAIL_SNOWPIPE_TRANSACTION refresh;

---------------------------------------------------------Count-Star(*)------------------------------------------------------------------

-- Execute the following command when you want to check number of transaction
-- when you want to check table number one by one.
SELECT COUNT(*) FROM demographic_RAW;
SELECT COUNT(*) FROM CAMPAIGN_DESC_RAW;
SELECT COUNT(*) FROM CAMPAIGN_RAW;
SELECT COUNT(*) FROM PRODUCT_RAW;
SELECT COUNT(*) FROM COUPON_RAW;
SELECT COUNT(*) FROM COUPON_REDEMPT_RAW;
SELECT COUNT(*) FROM TRANSACTION_RAW;

--(Or)--

-- When you want to count all the table together 
SELECT COUNT(*) FROM demographic_RAW
UNION ALL
SELECT COUNT(*) FROM CAMPAIGN_DESC_RAW
UNION ALL
SELECT COUNT(*) FROM CAMPAIGN_RAW
UNION ALL
SELECT COUNT(*) FROM PRODUCT_RAW
UNION ALL
SELECT COUNT(*) FROM COUPON_RAW
UNION ALL
SELECT COUNT(*) FROM COUPON_REDEMPT_RAW
UNION ALL
SELECT COUNT(*) FROM TRANSACTION_RAW;

--------------------------------------------------------Snowpipe-Status-----------------------------------------------------------------

-- This very very important code 

-- This will show the latest file which has been processed
-- Enter the snowpipe full name  
select SYSTEM$PIPE_STATUS('RETAIL_SNOWPIPE_TRANSACTION'); 

-- to check wether the files count in source(AWS S3) & target(Snowflake) are matching or not use below command
-- It will also help to answer question how many rows have been parsed in a particular table on any day or in last few days/hrs.
-- We can get the complete picture

-- you enter snowfake folder name you created
select * from table(information_schema.copy_history(table_name=>'TRANSACTION_RAW', start_time=>
dateadd(hours, -1, current_timestamp())));


-----------------------------------------------------To-Check-The-All-Data--------------------------------------------------------------

-- To check all data in Table
SELECT * FROM demographic_RAW;
SELECT * FROM CAMPAIGN_DESC_RAW;
SELECT * FROM CAMPAIGN_RAW;
SELECT * FROM PRODUCT_RAW;
SELECT * FROM COUPON_RAW;
SELECT * FROM COUPON_REDEMPT_RAW;
SELECT * FROM TRANSACTION_RAW;

