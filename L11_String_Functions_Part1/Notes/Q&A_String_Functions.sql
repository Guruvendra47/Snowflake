-- Starting with the String Functions

-- QUERY 1
/*
    Write a sql query to retrieve the sales_id, customer_name, order_state from the sales table. 
    The client has notified us that the column customer_name has an issue, it contains unwanted space in the beginning
    The client wants to see the names of the customer only.
    Also the client wants to have the data of only state 'CA', and the data needs to be displayed based on sales id from highest to lowest 
*/
SELECT
    SALE_ID,
    CUSTOMER_NAME AS ORIGINAL_CUSTOMER_NAME,
    LTRIM(CUSTOMER_NAME) AS SOLVED_CUSTOMER_NAME,
    ORDER_CITY
FROM SALES
WHERE order_state = 'CA'
ORDER BY SALE_ID DESC;

-- QUERY 2
/*
    Write a sql query to retrieve the sales_id, product_category from the sales table. 
    The client has notified us that the column product_category has an issue, it contains unwanted space in the end
    The client wants to see the names of the product_category only.
    Also the client wants to have the data of only state ('CA', 'TX', 'WA') and the payment must be done by credit card. 
    The data needs to be displayed based on sales id from highest to lowest 
*/
SELECT
    SALE_ID,
    PRODUCT_CATEGORY AS ORIGINAL_PRODUCT_CAT,
    LENGTH(PRODUCT_CATEGORY) AS LENGTH_OF_PRODUCT,
    RTRIM(PRODUCT_CATEGORY) AS SOLVED_PRODUCT_CATEGORY,
    LENGTH(RTRIM(PRODUCT_CATEGORY)) AS LENGTH_OF_SOLVED,
    ORDER_CITY
FROM SALES;



-- QUERY 3
/*
    Write a sql query to retrieve the sales_id, customer name, and feedback column from the sales table. 
    The client has notified us that the column feedback has an issue, it contains unwanted characters like *, -, # both in the start and end.
    The client wants to see the names of the Feedback category only. 
*/
SELECT 
    SALE_ID,
    CUSTOMER_NAME,
    FEEDBACK AS ORIGINAL_FEEDBACK,
    TRIM(FEEDBACK, ('*#-'))
FROM SALES;

-- UPDATING THE COLUMNS 
UPDATE SALES
SET FEEDBACK = TRIM(FEEDBACK, ('*#-'));

UPDATE SALES
SET PRODUCT_CATEGORY = RTRIM(PRODUCT_CATEGORY);

UPDATE SALES
SET CUSTOMER_NAME = LTRIM(CUSTOMER_NAME);



-- QUERY 4 -- (SPLIT())
/*
    Retrieve the following columns from the sales table. Columns: - Sale_ID, Order_id, Customer_name, Order_State, Sales_Channel, Payment_Method.
    There is a issue in the sales table, we were supposed to get the first name, and the last name. 
    So, create a column which can separate the first name and last name.
    Expected Output: - 
    Alice Brown -> ["Alice", "Brown"]
    Solution: - 
*/
SELECT 
    SALE_ID,
    ORDER_ID,
    CUSTOMER_NAME,
    ORDER_STATE,
    SALES_CHANNEL,
    PAYMENT_METHOD,
    SPLIT(CUSTOMER_NAME, ' ') AS FIRST_NAME
FROM sales;


-- QUERY 5 (SPLIT_PART())
/*
    Display the following columns (sale_id, customer_name, order_state, sales_channel) from the sales table.
    But there was a mistake done by the database designing team. We wanted columns customer_name, first name, last name.
    But we only got customer_name. Display the other two columns as well.
    Note that we want to see the data only from the Online channel.
    
*/
SELECT
    SALE_ID,
    CUSTOMER_NAME,
    ORDER_STATE,
    SALES_CHANNEL,
    SPLIT_PART(CUSTOMER_NAME, ' ', 1) AS FIRST_NAME,
    SPLIT_PART(CUSTOMER_NAME, ' ', 2) AS LAST_NAME
FROM SALES
WHERE SALES_CHANNEL = 'Online';


-- QUERY 6 (CONCAT())
/*
    Display the following queries from the sales table. 
    1. Sales_id, 
    2. Order_id, 
    3. Customer_name, 
    4. Product_name, 
    5. Payment_Method
    6. Sales_Channel
    7. Order_state,
    8. Order_country
    We need to also display another column which must be the ORDER_STATE - ORDER_COUNTRY and name the column as (State_and_country)
    We need to filter the select query such that we only get the data of Credit Card payment, and the channel must be online.
    Also, we need to sort the displayed data based on the sales_id as DESC order.
    
*/

SELECT
    SALE_ID,
    ORDER_ID,
    CUSTOMER_NAME,
    PRODUCT_NAME,
    PAYMENT_METHOD,
    SALES_CHANNEL,
    ORDER_STATE,
    ORDER_COUNTRY,
    CONCAT(ORDER_STATE, '-', ORDER_COUNTRY) AS STATE_AND_COUNTRY
FROM SALES
WHERE PAYMENT_METHOD = 'Credit Card' AND SALES_CHANNEL = 'Online'
ORDER BY SALE_ID DESC;


-- QUERY 7
/*
    There is a requirement of the client to analyse the data based on the location. 
    The client has provided you the sales data of their company. 
    Based on the first talks with the client we came to know that client wants the following columns
    1. SALE_ID
    2. ORDER_ID, 
    3. PRODUCT_NAME, 
    4. ORDER_CITY, 
    5. ORDER_STATE, 
    6. ORDER_COUNTRY, 
    7. SALES_AMOUNT,
    8. Feedback
    The client has requested that he does not want to see three different columns for city, state,and country.
    Intead he gave a solution to display only one column where the values will be "city, state, country".
    Also the client wants to see only the data of customers which were 'Very Satisfied' and also 'Neutral'
*/
SELECT
    SALE_ID,
    ORDER_ID,
    PRODUCT_NAME,
    ORDER_CITY,
    ORDER_STATE,
    ORDER_COUNTRY,
    SALE_AMOUNT,
    FEEDBACK,
    CONCAT_WS(',', ORDER_CITY, ORDER_STATE, ORDER_COUNTRY) AS LOCATION_COL
FROM SALES
WHERE FEEDBACK IN ('Very Satisfied', 'Neutral');


-- QUERY 8
/*
    Write a sql query to print the customer names from the sales table. 
    Also we need to print the length of the customer_name, as we want to identify the longest name in the data
    Return the result ordered by the length of the customer_name
*/

SELECT
    CUSTOMER_NAME,
    LENGTH(CUSTOMER_NAME) AS CUSTOMER_NAME_SIZE
FROM SALES
ORDER BY LENGTH(CUSTOMER_NAME) DESC;



-- QUERY 9
/*
    Write a SQL query to check if the customer name starts with letter 'B' or not.
    Retrieve only the columns Customer_name, and the checker column.
*/
select
    customer_name,
    startswith(customer_name, 'B') AS ALLB
from sales;


-- QUERY 10
/*
    Write a SQL query to convert all the CITY names into the upper case.
    For example, NEW YORK. 
    Note that we only need to see the city column and the uppercase column.
*/
SELECT
    ORDER_CITY,
    UPPER(ORDER_CITY) AS CITY_IN_CAPS
FROM SALES;



-- QUERY 11
/*
    Write a SQL query to display the columns as lower case column, We need to display the country column as lower case column.
*/
SELECT
    ORDER_COUNTRY,
    LOWER(ORDER_COUNTRY) AS COUNTRY_AS_LOWER
FROM SALES;
