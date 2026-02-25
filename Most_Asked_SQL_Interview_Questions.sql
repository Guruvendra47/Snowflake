USE ROLE SYSADMIN; 
USE DATABASE DB_SQL_PRACTICE;
USE SCHEMA SM_SQL_PRACTICE;

--Question #1 (VERY COMMON, MIXED)
/*
You have a table:

ORDERS
-------
ORDER_ID
CUSTOMER_ID
ORDER_DATE
AMOUNT


👉 Find customers who have placed at least 2 orders on the same day.
*/

SELECT DISTINCT
  CUSTOMER_ID,
  ORDER_DATE,
  COUNT(ORDER_ID) AS Orders_same_Day
FROM ORDERS
GROUP BY CUSTOMER_ID, ORDER_DATE
HAVING
  COUNT(ORDER_ID) >= 2;


--QUESTION-2 (High Probability, Mixed Concepts)
/*
Table:

EMPLOYEE
---------
EMP_ID
NAME
DEPT
SALARY


👉 Find employees whose salary is higher than the average salary of their department.
*/

--mainquery

SELECT 
  EMP_ID,
  NAME,
  DEPT,
  SALARY
FROM EMPLOYEE E1
WHERE SALARY > (---Subquery
SELECT
  AVG(SALARY) AS AVG_SALARY
FROM EMPLOYEE E2
WHERE E1.DEPT = E2.DEPT);


--QUESTION 3 (Very High Probability, Mixed)
/*
Table:

EMPLOYEE
---------
EMP_ID
NAME
DEPT
SALARY


👉 Find the 2nd highest salary overall.
*/
--Mainquery
SELECT
  EMP_ID,
  NAME,
  DEPT,
  SALARY
FROM --Subquery--Remember what all column you mention in Select statement same column you mention in main query too
     (SELECT
        EMP_ID,
        NAME,
        DEPT,
        SALARY,
        RANK() OVER(ORDER BY COALESCE(SALARY, 0) DESC) AS RANKSALARY
       FROM EMPLOYEE)
WHERE RANKSALARY = 2;



--QUESTION-4-- (VERY HIGH PROBABILITY)
/*
Tables:

CUSTOMERS
---------
CUSTOMER_ID
NAME

ORDERS
------
ORDER_ID
CUSTOMER_ID
ORDER_DATE


👉 Find customers who placed orders in 2023 but did NOT place any order in 2024.
*/

SELECT DISTINCT 
  C.CUSTOMER_ID, 
  C.CUST_NAME
FROM CUSTOMERS C
LEFT JOIN ORDERS O
ON C.CUSTOMER_ID = O.CUSTOMER_ID
WHERE 
  YEAR(O.ORDER_DATE) = 2023 
  AND 
  NOT EXISTS (
    SELECT *
    FROM ORDERS O2
    WHERE 
     C.CUSTOMER_ID = O2.CUSTOMER_ID
     AND 
     YEAR(O2.ORDER_DATE) = 2024);



--QUESTION 5 (Very High Probability)
/*
Table:

EMPLOYEE
---------
EMP_ID
NAME
DEPT
SALARY


👉 Find the employee(s) with the highest salary in each department.
If multiple employees tie, return all of them.
*/

SELECT 
  EMP_ID,
  NAME,
  DEPT,
  SALARY
FROM EMPLOYEE E
WHERE SALARY = (
  SELECT MAX(SALARY)
  FROM EMPLOYEE D
  WHERE D.DEPT = E.DEPT
);

---QUESTION 6 (Very High Probability, Mixed Concepts)
/*
Table:

ORDERS
-------
ORDER_ID
CUSTOMER_ID
ORDER_DATE
AMOUNT


👉 Find customers who have placed orders on at least 3 different days.
*/

SELECT 
  ORDER_ID, 
  CUSTOMER_ID, 
  ORDER_DATE, 
  AMOUNT
FROM ORDERS O1
WHERE CUSTOMER_ID IN (
    -- This is your original 'Loyalty' logic
    SELECT 
      CUSTOMER_ID
    FROM ORDERS O2
    GROUP BY CUSTOMER_ID
    HAVING 
      COUNT(DISTINCT ORDER_DATE) >= 3
)
ORDER BY CUSTOMER_ID, ORDER_DATE;


--QUESTION 7 (Very High Probability — Ranking Pattern)
/*
Table:

EMPLOYEE
---------
EMP_ID
NAME
SALARY


👉 Find the 3rd highest salary overall.

*/


SELECT
  NAME,
  SALARY
FROM (
SELECT
  NAME,
  SALARY,
  RANK() OVER(ORDER BY COALESCE(SALARY, 0)DESC) AS Rnk_Salary
FROM EMPLOYEE)
WHERE Rnk_Salary = 3;

--QUESTION 8 (Very High Probability — Anti-Join Pattern)
/*
Tables:

CUSTOMERS
---------
CUSTOMER_ID
NAME

ORDERS
------
ORDER_ID
CUSTOMER_ID


👉 Find customers who have never placed an order.
*/








SELECT
  CUSTOMER_ID
FROM CUSTOMERS
EXCEPT  -- Not supported in MySQL (uses MINUS in Oracle)
SELECT
  CUSTOMER_ID
FROM ORDERS;

--(OR)

SELECT 
 C.CUSTOMER_ID,
 C.CUST_NAME
FROM CUSTOMERS C
LEFT JOIN ORDERS O
ON C.CUSTOMER_ID = O.CUSTOMER_ID
WHERE O.CUSTOMER_ID IS NULL
ORDER BY C.CUSTOMER_ID;  ---order by is option data look clean


---QUESTION 9 (Very High Probability — Mixed Aggregation + Join)
/*
Tables:

ORDERS
-------
ORDER_ID
CUSTOMER_ID
AMOUNT

CUSTOMERS
----------
CUSTOMER_ID
NAME


👉 Find customers whose total order amount is greater than 1000.
*/




SELECT
  O.CUSTOMER_ID,
  C.CUST_NAME,
  SUM(O.AMOUNT)
FROM ORDERS O
INNER JOIN CUSTOMERS C
ON O.CUSTOMER_ID = C.CUSTOMER_ID
GROUP BY O.CUSTOMER_ID, C.CUST_NAME
 HAVING
  SUM(AMOUNT) > 1000;


--- QUESTION 10 (Very High Probability — Time Logic + Aggregation)
/*
Table:

ORDERS
-------
ORDER_ID
CUSTOMER_ID
ORDER_DATE
AMOUNT


👉 Find the total sales for each month in 2023.
*/

SELECT 
  DATE_TRUNC('MONTH', ORDER_DATE) AS MONTH,
  SUM(AMOUNT) AS TOTAL_SALES                     -- Use WHERE for row filtering and Use HAVING for aggregate filtering--
FROM DB_SQL_PRACTICE.SM_SQL_PRACTICE.ORDERS 
WHERE YEAR(ORDER_DATE) = 2023
GROUP BY DATE_TRUNC('MONTH', ORDER_DATE)
ORDER BY MONTH;


/*

Some interviewers prefer avoiding YEAR() because it can prevent index usage.

Safer pattern:

SELECT 
  DATE_TRUNC('MONTH', ORDER_DATE) AS MONTH,
  SUM(AMOUNT) AS TOTAL_SALES
FROM ORDERS
WHERE ORDER_DATE >= '2023-01-01'
  AND ORDER_DATE < '2024-01-01'
GROUP BY DATE_TRUNC('MONTH', ORDER_DATE)
ORDER BY MONTH;
*/

---QUESTION 11 (Very High Probability — Window + Business Logic)
/*
Table:

SALES
------
SALE_DATE
AMOUNT


👉 Find the running total of sales ordered by SALE_DATE.
*/

SELECT
  SALES_DATE,
  SUM(AMOUNT) OVER(ORDER BY SALES_DATE ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
FROM SALES;


--QUESTION 12 (Very High Probability — Ranking + Filtering)
/*
Table:

EMPLOYEE
---------
EMP_ID
NAME
DEPT
SALARY


👉 Find the top 2 highest-paid employees in each department.
*/


SELECT 
  EMP_ID,
  NAME,
  DEPT,
  SALARY
FROM (
  SELECT 
    EMP_ID,
    NAME,
    DEPT,
    SALARY,
    DENSE_RANK() OVER (PARTITION BY DEPT ORDER BY COALESCE(SALARY,0) DESC) as rank
  FROM EMPLOYEE
)
WHERE rank <= 2;

--QUESTION 13 (Very High Probability — NULL Trap + Aggregation
/*
Table:

EMPLOYEE
---------
EMP_ID
NAME
DEPT
SALARY


👉 Find departments where the average salary is greater than 50,000.
*/

SELECT
  DEPT,
  AVG(SALARY) AS avg_salary
FROM EMPLOYEE
GROUP BY DEPT
HAVING 
  AVG(SALARY) > 50000;


  /*
QUESTION 14 (Very High Probability — Subquery vs Join Logic)

Table:

ORDERS
-------
ORDER_ID
CUSTOMER_ID
AMOUNT


👉 Find customers whose total order amount is greater than the overall average order amount.
  */

  SELECT 
    CUSTOMER_ID,
    SUM(AMOUNT) AS total_order_amt
  FROM ORDERS
  GROUP BY CUSTOMER_ID
   HAVING
      SUM(AMOUNT) > (SELECT   ----here i should have used avg(amount) in select statment instead i used sub query bec that provide individual avg but i need overll avg so we used subquery seperately
    AVG(AMOUNT) AS avg_order_amt
  FROM ORDERS);


  /*
  QUESTION 15 (Very High Probability — Anti-Join + Date Logic)

Table:

ORDERS
-------
ORDER_ID
CUSTOMER_ID
ORDER_DATE


👉 Find customers who placed an order in 2024 but NOT in 2023.
  */

SELECT DISTINCT 
  C.CUSTOMER_ID,
  C.CUST_NAME
FROM CUSTOMERS C
JOIN ORDERS O
ON C.CUSTOMER_ID = O.CUSTOMER_ID
WHERE 
  YEAR(O.ORDER_DATE) = 2024 
  AND
  NOT EXISTS (
  SELECT *
  FROM ORDERS O2
  WHERE 
    C.CUSTOMER_ID = O2.CUSTOMER_ID 
    AND
    YEAR(O2.ORDER_DATE) = 2023
  );


/*
QUESTION 16 (Very High Probability — Window + Gap Logic)

Table:

LOGS
------
USER_ID
EVENT_TIME


👉 For each user, find the number of sessions.
New session starts when gap > 30 minutes.

*/

SELECT
  USER_ID,
  SUM(session_start) AS number_of_sessions
FROM (
  SELECT
    USER_ID,
    EVENT_TIME,
    CASE 
      WHEN LAG(EVENT_TIME) OVER (
             PARTITION BY USER_ID 
             ORDER BY EVENT_TIME
           ) IS NULL THEN 1
      WHEN DATEDIFF('MINUTE', LAG(EVENT_TIME) OVER (
             PARTITION BY USER_ID 
             ORDER BY EVENT_TIME
           ), EVENT_TIME) > 30 THEN 1
      ELSE 0
    END AS session_start
  FROM LOGS
) t
GROUP BY USER_ID;


/*
QUESTION 17 (Related, Slightly Simpler)

Same LOGS table.

👉 For each user, show the previous event time alongside the current event time.

No session logic. Just previous value.
*/

SELECT
  USER_ID,
  EVENT_TIME as current_event_time,
  LAG(EVENT_TIME) OVER(PARTITION BY USER_ID ORDER BY EVENT_TIME) AS Previous_event_time
FROM LOGS;

/*
QUESTION 18 (Back to Session Logic — Retry)

Now use what you just did.

Same LOGS table.

👉 For each user, calculate the time difference (in minutes) between current event and previous event.
*/

SELECT
  USER_ID,
  EVENT_TIME as current_event_time,
  LAG(EVENT_TIME) OVER(PARTITION BY USER_ID ORDER BY EVENT_TIME) AS Previous_event_time,
  DATEDIFF(MINUTE, LAG(EVENT_TIME) OVER(PARTITION BY USER_ID ORDER BY EVENT_TIME),EVENT_TIME) AS minutes_difference
FROM USER_LOGS;

/*
QUESTION 19 (Different — Very High Probability)

Table:

ORDERS
-------
ORDER_ID
CUSTOMER_ID
ORDER_DATE
AMOUNT


👉 Find the top 3 customers by total order amount.
*/

SELECT TOP 3
  CUSTOMER_ID,
  SUM(AMOUNT) AS total_order_amount 
FROM ORDERS
GROUP BY CUSTOMER_ID
ORDER BY total_order_amount DESC;

/*
QUESTION 20 (Very High Probability — Duplicate Pattern)

Table:

EMPLOYEE
---------
EMP_ID
EMAIL


👉 Delete duplicate email records, keeping the row with the smallest EMP_ID.
*/

DELETE FROM EMPLOYEE E1
WHERE EXISTS (
    SELECT 1 -- people use "1" just as a simple way to say "Yes, I found it"?
    FROM EMPLOYEE E2 
    WHERE E1.EMAIL = E2.EMAIL 
    AND E1.EMP_ID > E2.EMP_ID
);

/*
QUESTION 21 (Very High Probability — Conditional Aggregation)

Table:

ORDERS
-------
ORDER_ID
CUSTOMER_ID
ORDER_DATE
AMOUNT


👉 Find customers who placed more than 3 orders AND whose total order amount is greater than 200.
*/

SELECT 
  CUSTOMER_ID
FROM ORDERS
GROUP BY CUSTOMER_ID
HAVING 
  COUNT(ORDER_ID) > 3 
  AND SUM(AMOUNT) > 200;

/*
QUESTION 22 (Very High Probability — Self Join Pattern)

Table:

EMPLOYEE
---------
EMP_ID
NAME
MANAGER_ID


👉 Find employees who have the same manager as employee with EMP_ID = 102.
*/


SELECT 
  EMP_ID,
  NAME,
  MANAGER_ID
FROM EMPLOYEE
WHERE MANAGER_ID = (
    SELECT MANAGER_ID
    FROM EMPLOYEE
    WHERE EMP_ID = 102
)
AND EMP_ID <> 102;

(or)

SELECT DISTINCT 
  e.EMP_ID, 
  e.NAME, 
  e.MANAGER_ID
FROM EMPLOYEE e
JOIN EMPLOYEE e2 
ON e2.EMP_ID = 102
WHERE e.MANAGER_ID = e2.MANAGER_ID
AND e.EMP_ID != 102;

/*
Remember:

We use a join on one table when:
1. The table has a Hierarchy (like Bosses and Employees).
2. The table has Relationships between rows (like Brothers, or Teammates).
3. You need to compare a specific row to other rows in the same list.
*/

/*
QUESTION 23 (Very High Probability — Window + Ranking)

Table:

EMPLOYEE
---------
EMP_ID
NAME
DEPT
SALARY


👉 Find the employee(s) with the 2nd highest salary in each department.
*/

SELECT
  EMP_ID,
  NAME,
  DEPT,
  SALARY
FROM (
   SELECT
     EMP_ID,
     NAME,
     DEPT,
     RANK() OVER(PARTITION BY DEPT ORDER BY COALESCE(SALARY,0) DESC) AS rnk_salary,  ---I used coalesce inorder to remove null replace with zero.
     SALARY
   FROM EMPLOYEE)
WHERE rnk_salary = 2;


/*

QUESTION 24 (Very High Probability — Correlated Subquery Pattern)

Table:

ORDERS
-------
ORDER_ID
CUSTOMER_ID
ORDER_DATE
AMOUNT


👉 Find the latest order (most recent ORDER_DATE) for each customer.
Return ORDER_ID, CUSTOMER_ID, ORDER_DATE.
*/

SELECT 
  ORDER_ID,
  CUSTOMER_ID,
  ORDER_DATE
FROM (SELECT 
  ORDER_ID,
  CUSTOMER_ID,
  ORDER_DATE,
  RANK() OVER(PARTITION BY CUSTOMER_ID ORDER BY ORDER_DATE DESC) AS latest_order
FROM ORDERS)
WHERE latest_order = 1;

-- With out using RANK function 

SELECT 
  ORDER_ID,
  CUSTOMER_ID,
  ORDER_DATE
FROM ORDERS O1
WHERE ORDER_DATE = 
( SELECT 
    MAX(ORDER_DATE) as latest_order
  FROM ORDERS O2
  WHERE O1.CUSTOMER_ID = O2.CUSTOMER_ID
);


/*
QUESTION 25 (Very High Probability — Conditional Aggregation)

Table:

ORDERS
-------
ORDER_ID
CUSTOMER_ID
AMOUNT

👉 For each customer, show:
1. Total number of orders
2. Total amount
3. Number of orders where AMOUNT > 500
*/

SELECT
  CUSTOMER_ID,
  COUNT(ORDER_ID) AS total_no_of_orders, 
  SUM(AMOUNT) AS total_amount,
  SUM(CASE WHEN AMOUNT > 500 THEN 1 ELSE 0 END) AS above_500,
FROM ORDERS
GROUP BY CUSTOMER_ID;



/*
QUESTION 26 (Very High Probability — DISTINCT + Aggregation Trap)

Table:

ORDERS
-------
ORDER_ID
CUSTOMER_ID
ORDER_DATE

👉 Find customers who placed orders on consecutive days.
*/


SELECT DISTINCT 
    CUSTOMER_ID,
    ORDER_DATE as FIRST_ORDER_DATE,
    LEAD(ORDER_DATE) OVER (PARTITION BY CUSTOMER_ID ORDER BY ORDER_DATE) as SECOND_ORDER_DATE
FROM ORDERS
WHERE DATEDIFF(day, ORDER_DATE, LEAD(ORDER_DATE) OVER (PARTITION BY CUSTOMER_ID ORDER BY ORDER_DATE)) = 1;

SELECT DISTINCT 
  CUSTOMER_ID,
  ORDER_DATE
FROM (
    SELECT
        CUSTOMER_ID,
        ORDER_DATE,
        LEAD(ORDER_DATE) OVER (PARTITION BY CUSTOMER_ID ORDER BY ORDER_DATE) AS next_order_date
    FROM ORDERS
) t
WHERE DATEDIFF(day, ORDER_DATE, next_order_date) = 1;

/*
QUESTION 27 (Very High Probability — NULL + NOT IN Trap)

Tables:

CUSTOMERS
---------
CUSTOMER_ID

ORDERS
------
ORDER_ID
CUSTOMER_ID

👉 Find customers who have not placed any orders.
   Use NOT IN.
*/
--NOT IN requires a subquery or list, not a column reference.


SELECT CUSTOMER_ID
FROM CUSTOMERS
WHERE CUSTOMER_ID NOT IN (
    SELECT CUSTOMER_ID
    FROM ORDERS
);

/*
QUESTION 28 (Very High Probability — Rolling Window)

Table:

SALES
------
SALE_DATE
AMOUNT

👉 Find the 7-day rolling average of sales.
*/

SELECT
  SALES_DATE,
  AVG(AMOUNT) OVER(ORDER BY SALES_DATE ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS day_rollling_avg_sales
FROM SALES;

/*
QUESTION 29 (Very High Probability — Gaps & Islands Pattern)

Table:

ORDERS
-------
CUSTOMER_ID
ORDER_DATE

👉 Find customers who placed orders on 3 consecutive days.
*/


SELECT CUSTOMER_ID
FROM (
    SELECT
        CUSTOMER_ID,
        ORDER_DATE,
        DATEADD(DAY, -ROW_NUMBER() OVER (PARTITION BY CUSTOMER_ID ORDER BY ORDER_DATE), ORDER_DATE) AS grp
    FROM ORDERS
) t
GROUP BY CUSTOMER_ID, grp
HAVING COUNT(*) >= 3;

(or)

SELECT
  CUSTOMER_ID,
  ORDER_DATE
FROM (
    SELECT
        CUSTOMER_ID,
        ORDER_DATE,
        LEAD(ORDER_DATE, 1) OVER (PARTITION BY CUSTOMER_ID ORDER BY ORDER_DATE) AS next_day,
        LEAD(ORDER_DATE, 2) OVER (PARTITION BY CUSTOMER_ID ORDER BY ORDER_DATE) AS next_next_day
    FROM ORDERS
) t
WHERE DATEDIFF(DAY, ORDER_DATE, next_day) = 1
  AND DATEDIFF(DAY, next_day, next_next_day) = 1;
