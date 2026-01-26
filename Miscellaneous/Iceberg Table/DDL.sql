-----------------------------------------------Create DataBase and Schema-------------------------------------------------

CREATE OR REPLACE DATABASE DB_ICEBERG;
USE DATABASE DB_ICEBERG;

CREATE OR REPLACE SCHEMA SM_ICEBERG;
USE SCHEMA SM_ICEBERG;

-------------------------------------------------Create External Volume---------------------------------------------------

CREATE OR REPLACE EXTERNAL VOLUME ICEBERG_EXT_VOL ----IF NOT EXISTS DOES NOT WORK HERE
STORAGE_LOCATIONS =
(
  (
    NAME = 'iceberg_ext'
    STORAGE_PROVIDER = 'S3'
    STORAGE_BASE_URL = 's3://iceberg-ext/'
    STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::954976291800:role/ICEBERG_ROLE'
    STORAGE_AWS_EXTERNAL_ID = 'PPB32730_SFCRole=6_fL38xffKCg1WxkOHEXY/M8ySes4='
  )
)
ALLOW_WRITES = TRUE;

-----------------------------------------------Describe External Vloume---------------------------------------------------

DESCRIBE EXTERNAL VOLUME iceberg_ext_vol;

---------------------------------------------Check-Volumn-Successfull-Executed--------------------------------------------

SELECT SYSTEM$VERIFY_EXTERNAL_VOLUME('ICEBERG_EXT_VOL');

---------------------------------------------------Create-Sales-Table-----------------------------------------------------

CREATE OR REPLACE ICEBERG TABLE SALES
(
    ORDER_ID INT,
    CUSTOMER_ID INT,
    ORDER_DATE DATE,
    AMOUNT NUMBER(10,2)
)
CATALOG = 'SNOWFLAKE'
EXTERNAL_VOLUME = 'ICEBERG_EXT_VOL'
BASE_LOCATION = 'sales_iceberg/';

------------------------------------------------Enter-Data-Into-Sales-Table-----------------------------------------------

INSERT INTO SALES
VALUES
(1, 101, '2025-01-10', 500),
(2, 102, '2025-01-11', 1200);

------------------------------------------------------Check-Table-Data----------------------------------------------------

SELECT *
FROM SALES;

----------------------------------------------------Create-Customer-Table-------------------------------------------------

create or replace iceberg table customer_detail (
CUST_NUM varchar,
CUST_STAT varchar ,
CUST_BAL number(10,0),
INV_NO varchar ,
INV_AMT number(10,2),
CRID varchar ,
SSN varchar,
phone number(10,0),
Email varchar
)

CATALOG = 'SNOWFLAKE'
external_volume='iceberg_int'
BASE_LOCATION = 'customer_detail';


----------------------------------------------------Create Storage-Integration--------------------------------------------

CREATE OR REPLACE STORAGE INTEGRATION iceberg_s3_int
TYPE = EXTERNAL_STAGE
STORAGE_PROVIDER = S3
ENABLED = TRUE
STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::954976291800:role/ICEBERG_ROLE'
STORAGE_ALLOWED_LOCATIONS = ('s3://iceberg-ext/');

---------------------------------------------------Show-Storage-Integration-Data------------------------------------------

DESC STORAGE INTEGRATION iceberg_s3_int;

--------------------------------------------------------Create-File-Format------------------------------------------------

CREATE OR REPLACE FILE FORMAT csv_ff
TYPE = 'CSV'
FIELD_DELIMITER = ','
SKIP_HEADER = 1
NULL_IF = ('NULL','null');

-----------------------------------------------------------Create-Stage---------------------------------------------------

CREATE OR REPLACE STAGE iceberg_ext_s3_stage
URL = 's3://iceberg-ext'
STORAGE_INTEGRATION = iceberg_s3_int
FILE_FORMAT = csv_ff;

------------------------------------------------------------List-Stage----------------------------------------------------

LIST @iceberg_ext_s3_stage;

------------------------------------------------------------Load-Data----------------------------------------------------

COPY INTO customer_detail
FROM @iceberg_ext_s3_stage
FILE_FORMAT = csv_ff
ON_ERROR = 'CONTINUE';
