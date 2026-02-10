----QUESTION-1----------------------
/*
You have the following table:

EMPLOYEE
---------
EMP_ID
NAME
SALARY

Question
Write a SQL query to find the second highest salary from the EMPLOYEE table.
*/

SELECT 
  MAX(SALARY) AS second_highest_salary
FROM EMPLOYEE
WHERE
  SALARY < (SELECT MAX(SALARY) FROM EMPLOYEE); ---used Sub-query.

----Question-2-----

/*
You have the table:

EMPLOYEE
---------
EMP_ID
NAME
DEPT
SALARY

Find the department-wise average salary, but include only departments that have more than 2 employees.
*/

SELECT
  DEPT,
  COUNT(DEPT) AS depart_count,
  AVG(SALARY) AS avg_salary
FROM EMPLOYEE
GROUP BY
  DEPT
HAVING
   COUNT(DEPT) > 2;


----Question-3-----
/*
You have two tables:

EMPLOYEE
---------
EMP_ID
NAME
DEPT_ID
SALARY

DEPARTMENT
-----------
DEEPARTMENT_ID
DEPT


👉 Find the department name and the number of employees in each department.
Include departments even if they have zero employees.
*/

SELECT
  COUNT(E.EMP_ID) AS no_employess,
  D.DEPT 
FROM DEPARTMENT AS D
LEFT JOIN EMPLOYEE AS E
ON D.DEPARTMENT_ID = E.DEPARTMENT_ID
GROUP BY 
  D.DEPT;

--Question-4----(Very Common, Real Trap)--

/*
Table:

ORDERS
-------
ORDER_ID
CUSTOMER_ID
ORDER_DATE
AMOUNT


👉 Find customers who have placed more than one order on the same day.
*/

SELECT
  CUSTOMER_ID,
  ORDER_DATE,
  COUNT(*) AS order_count
FROM ORDERS
GROUP BY
  CUSTOMER_ID,
  ORDER_DATE
HAVING
  COUNT(*) > 1;

----Question-5----(Frequently Asked)-
/*
Same ORDERS table.

👉 Find customers who have placed orders on at least 3 different days
*/

SELECT
  CUSTOMER_ID,
  COUNT(DISTINCT ORDER_DATE) AS unique_order_days
FROM ORDERS
GROUP BY
  CUSTOMER_ID
HAVING
  COUNT(DISTINCT ORDER_DATE) >= 3
ORDER BY
  CUSTOMER_ID;


--Question-6--(Very Common, Slightly Trickier)--
/*
You have the table:

EMPLOYEE
---------
EMP_ID
NAME
DEPT
SALARY


👉 Find the highest salary in each department.
*/

SELECT
  MAX(SALARY) AS highest_salary_dept,
  DEPT 
FROM EMPLOYEE
GROUP BY
  DEPT;


---Question-7---(Very Common Follow-Up)-
/*
Same table:

EMPLOYEE
---------
EMP_ID
NAME
DEPT
SALARY


👉 Find the employee(s) who earn the highest salary in each department.
*/


SELECT 
  DEPT,
  NAME,
  SALARY
FROM EMPLOYEE E1
WHERE SALARY = (
  SELECT MAX(SALARY)
  FROM EMPLOYEE E2
  WHERE E1.DEPT = E2.DEPT
)
ORDER BY DEPT;

----QUESTION 8 (Another Top-10 Favorite)
/*
Table:

EMPLOYEE
---------
EMP_ID
NAME
DEPT
SALARY


👉 Find employees whose salary is above the average salary of their department.
*/

SELECT
  DEPT,
  NAME,
  SALARY
FROM EMPLOYEE AS E1
WHERE SALARY > (SELECT AVG(SALARY) FROM EMPLOYEE AS E2 WHERE E1.DEPT = E2.DEPT);


👉 Find customers who have placed orders on at least 3 different days.


SELECT*
FROM ORDERS;

SELECT
COUNT(DISTINCT ORDER_DATE) AS DATE,
CUSTOMER_ID
FROM ORDERS
GROUP BY
  CUSTOMER_ID
HAVING
  COUNT(DISTINCT ORDER_DATE) > 3
ORDER BY CUSTOMER_ID;


---QUESTION 9 (Very Common – DISTINCT Trap)
/*
You have the table:

EMPLOYEE
---------
EMP_ID
NAME
DEPT
SALARY


👉 Find the number of distinct employees in each department.
*/

SELECT
  COUNT(DISTINCT NAME) AS employees,
  DEPT
FROM EMPLOYEE
GROUP BY 
  DEPT;

--QUESTION 10 (Set Operator Favorite)
/*
You have two tables:

TABLE_A
--------
ID

TABLE_B
--------
ID


👉 Find IDs that exist in TABLE_A but NOT in TABLE_B.
*/

SELECT
  TABLE_IDS
FROM TABLE_A
EXCEPT
SELECT
  TABLE_IDS
FROM TABLE_B;


--QUESTION 11 (Classic NULL Trap)
/*
Table:

EMPLOYEE
---------
EMP_ID
NAME
MANAGER_ID


👉 Find employees who do not have a manager.
*/

SELECT 
  EMP_ID,
  NAME,
  MANAGER_ID
FROM EMPLOYEE
WHERE 
  MANAGER_ID IS NULL;

--🧪 QUESTION 12 (High-Frequency, Slightly Tricky)
/*
Table:

EMPLOYEE
---------
EMP_ID
NAME
SALARY


👉 Find employees who earn more than the average salary of all employees.
*/

SELECT
  EMP_ID,
  NAME,
  SALARY
FROM EMPLOYEE
WHERE 
  SALARY > (SELECT AVG(SALARY) FROM EMPLOYEE);

--UESTION 13 (Duplicate Detection – VERY Common)
/*
Table:

EMPLOYEE
---------
EMP_ID
EMAIL


👉 Find duplicate email addresses in the EMPLOYEE table.
*/


SELECT
  COUNT(EMP_ID) AS DUPL_EMAIL,
  EMAIL
FROM EMPLOYEE
GROUP BY
  EMAIL
HAVING
   COUNT(EMP_ID) > 1;

--🧪 QUESTION 14 (Classic Follow-Up)
/*
Same table:

EMPLOYEE
---------
EMP_ID
EMAIL


👉 Delete duplicate email records, keeping only one record per email.
*/

DELETE FROM EMPLOYEE
WHERE EMP_ID NOT IN (
    SELECT MIN(EMP_ID)
    FROM EMPLOYEE 
    GROUP BY EMAIL
);


---QUESTION 15 (Top-N per Group — VERY COMMON)
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
  DEPT,
  NAME,
  SALARY
FROM (
  SELECT 
    DEPT,
    NAME,
    SALARY,
    RANK() OVER (PARTITION BY DEPT ORDER BY SALARY DESC) as salary_rank
  FROM EMPLOYEE
)
WHERE salary_rank <= 2
ORDER BY DEPT, SALARY DESC;


/*

🧠 Interview Rule (very important)

GROUP BY is for aggregation, not ranking.

The moment you hear:

“top N”
“highest per group”
“rank within department”

You should think:
👉 window functions OR correlated subquery
*/

--QUESTION 16----
/*
You have two tables:

CUSTOMERS
-----------
CUSTOMER_ID

ORDERS
--------
ORDER_ID
CUSTOMER_ID


👉 Find customers who have never placed an order.
*/

SELECT
  *
FROM CUSTOMERS AS C
LEFT JOIN ORDERS AS O
ON C.CUSTOMER_ID = O.CUSTOMER_ID
WHERE O.CUSTOMER_ID IS NULL;


--QUESTION 17 (Aggregation + Join — Very Common)
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


👉 Find total order amount for each customer.
Include customers who have not placed any orders.
*/
        

SELECT
  C.CUSTOMER_ID,
  COALESCE(SUM(O.AMOUNT),0) AS Total_order_Amount
FROM CUSTOMERS C
LEFT JOIN ORDERS O
ON C.CUSTOMER_ID = O.CUSTOMER_ID
GROUP BY C.CUSTOMER_ID;


-- QUESTION 18 (Window + Date Logic — Very Common)
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
  SUM(AMOUNT) OVER(ORDER BY SALES_DATE)
FROM SALES;



