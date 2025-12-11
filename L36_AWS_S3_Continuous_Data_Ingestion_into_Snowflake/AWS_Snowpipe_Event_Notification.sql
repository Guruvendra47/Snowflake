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

--------------------------------------------------------Snowpipe-Stauts-----------------------------------------------------------------

-- This very very important code p
-- Following are some snowpipe command which will help you to check snowpipe status 
-- count command count the no of rows but this command very very important which help to verify the count.

select SYSTEM$PIPE_STATUS('RETAIL_SNOWPIPE_TRANSACTION'); -- Enter the snowpipe full name  

select * from table(information_schema.copy_history(table_name=>'TRANSACTION_RAW', start_time=>
dateadd(hours, -1, current_timestamp())));
-- you enter snowfake folder name you created

-----------------------------------------------------To-Check-The-All-Data--------------------------------------------------------------

-- To check all table data we execute this code
SELECT * FROM demographic_RAW;
SELECT * FROM CAMPAIGN_DESC_RAW;
SELECT * FROM CAMPAIGN_RAW;
SELECT * FROM PRODUCT_RAW;
SELECT * FROM COUPON_RAW;
SELECT * FROM COUPON_REDEMPT_RAW;
SELECT * FROM TRANSACTION_RAW;

