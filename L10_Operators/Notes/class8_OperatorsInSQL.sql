-- Step 1: Assign the Account Role
USE ROLE ACCOUNTADMIN;

-- Step 2: Use the Warehouse
USE WAREHOUSE COMPUTE_WH;

-- Step 3: Create Database
CREATE DATABASE IF NOT EXISTS V3_BASIC_SQL_STATEMENTS_DB;

-- Step 4: Create Schema
CREATE SCHEMA IF NOT EXISTS V3_BASIC_SQL_STATEMENTS_DB_SCHEMA;

-- Step 5: Use the Database and Schema
USE DATABASE V3_BASIC_SQL_STATEMENTS_DB;
USE SCHEMA V3_BASIC_SQL_STATEMENTS_DB_SCHEMA;


-- Remove $ and commas, then convert to DECIMAL
UPDATE SALES_DATA
SET PROFIT = TO_DECIMAL(REPLACE(REPLACE(PROFIT, '$', ''), ',', ''));

UPDATE SALES_DATA
SET SALES = TO_DECIMAL(REPLACE(REPLACE(SALES, '$', ''), ',', ''));


-- Arithmetic Operators
-- Add PROFIT and SHIPPING_COST and filter by SALES
SELECT
    SALES, 
    PROFIT, 
    SHIPPING_COST, 
    PROFIT + SHIPPING_COST AS ADDITION_OF_PRO_AND_SHIP
FROM SALES_DATA
WHERE SALES > PROFIT + SHIPPING_COST;

-- View all records
SELECT * FROM SALES_DATA;

-- Full Arithmetic Operators Example
SELECT 
    ROW_ID, 
    ORDER_ID,
    ORDER_DATE, 
    SALES,
    PROFIT, 
    QUANTITY, 
    DISCOUNT,
    SALES * QUANTITY AS MUL, 
    SALES - PROFIT AS SUB,
    PROFIT / QUANTITY AS DIVI,
    DISCOUNT + QUANTITY AS ADDI,
    SALES % 7 AS MODU
FROM SALES_DATA;


-- Comparison Operators 
-- Get all data
SELECT * FROM SALES_DATA;

-- Filter Ship Modes (excluding 'Same Day')
SELECT 
    ROW_ID, 
    ORDER_ID, 
    SHIP_MODE
FROM SALES_DATA
WHERE SHIP_MODE <> 'Same Day';

-- PROFIT less than or equal to (SHIPPING_COST - 10) / 10
SELECT * 
FROM SALES_DATA
WHERE PROFIT <= ((SHIPPING_COST - 10) / 10);



-- Logical Operators 
-- Example with AND and OR
SELECT 
    SEGMENT, 
    SHIP_MODE, 
    COUNTRY, 
    QUANTITY
FROM SALES_DATA
WHERE 
    (SEGMENT = 'Corporate' AND SHIP_MODE = 'First Class' AND COUNTRY = 'United States')
    OR
    (QUANTITY >= 3);

-- Example with NOT
SELECT
    ORDER_ID, 
    COUNTRY
FROM SALES_DATA
WHERE NOT (QUANTITY <= 3);



-- Bitwise Operators
-- Bitwise AND of 6 and 3
SELECT BITAND(6, 3) AS BITWISE_AND;

-- Bitwise OR of 6 and 3
SELECT BITOR(6, 3) AS BIT_OR_OPERATION;

/*
    6 = 0110
    3 = 0011
    ------------
        0010 = 2
*/
