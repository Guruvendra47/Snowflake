-- 01_create_roles_warehouse_db_schema_stage.sql
-- Step 1: create role, warehouse, database, schema, and internal stage
-- Run this as an admin user (or a user with CREATE privileges)

CREATE ROLE IF NOT EXISTS DEMO_ROLE;
-- grant role to your user after creating (example):
-- GRANT ROLE DEMO_ROLE TO USER <your_user>;

CREATE WAREHOUSE IF NOT EXISTS DEMO_WAREHOUSE
  WITH WAREHOUSE_SIZE = 'XSMALL'
  WAREHOUSE_TYPE = 'STANDARD'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  INITIALLY_SUSPENDED = TRUE;

USE ROLE ACCOUNTADMIN; -- or SECURITYADMIN depending on your rights
-- Note: switching role might be required to run following creates, adjust as needed.

CREATE DATABASE IF NOT EXISTS DEMO_DATABASE;
USE DATABASE DEMO_DATABASE;

CREATE SCHEMA IF NOT EXISTS DEMO_SCHEMA;
USE SCHEMA DEMO_SCHEMA;

-- Internal named stage (no URL required) 
CREATE STAGE IF NOT EXISTS DEMO_STAGE;
-- you can also create stage with FILE_FORMAT param, e.g.:
-- CREATE STAGE IF NOT EXISTS DEMO_STAGE FILE_FORMAT = (FORMAT_NAME = DEMO_DATABASE.DEMO_SCHEMA.CUSTOMER_CSV_FF);
