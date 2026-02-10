

CREATE DATABASE IF NOT EXISTS DB_SQL_PRACTICE;
USE DATABASE DB_SQL_PRACTICE;
CREATE OR REPLACE SCHEMA SM_SQL_PRACTICE;
USE SCHEMA SM_SQL_PRACTICE;

-----Question 1-----------------------------------------------------
/*
QUESTION 1 / 50 (REPEAT — ANSWER THIS)
Write an INSERT for:
EMP_ID = 1
NAME = NULL
EMAIL = 'test@gmail.com'
SALARY = 50000
DEPT = 'IT'
Then write:
SUCCESS or ERROR*/


CREATE TABLE IF NOT EXISTS EMPLOYEE
(
  EMP_ID    INT PRIMARY KEY,
  NAME      VARCHAR(50) NOT NULL,
  EMAIL     VARCHAR(100) UNIQUE, ---- onlY difference b/w primary key is UNIQUE key has Null Value
  SALARY    NUMBER(10,2),
  DEPT      VARCHAR(20),
  JOIN_DATE DATE DEFAULT CURRENT_DATE
);

INSERT INTO EMPLOYEE (EMP_ID,NAME,EMAIL,SALARY,DEPT,JOIN_DATE)
VALUES
(1,'NULL','test@gmail.com',50000,'IT',CURRENT_DATE());


SELECT *
FROM EMPLOYEE;

----Question 2-----------------------------------------------------

/*
QUESTION 2 / 50 — CONSTRAINTS (UNIQUE + NULL TRAP)
Situation
Table already contains:
----------------------------
| EMP_ID - EMAIL           |
| 1      - test@gmail.com  |
----------------------------
Task

Try to insert:

EMP_ID = 2
NAME = 'Amit'
EMAIL = NULL
SALARY = 40000
DEPT = 'HR'

Write:

The INSERT statement
Then write SUCCESS or ERROR

*/


INSERT INTO EMPLOYEE(EMP_ID,NAME,EMAIL,SALARY,DEPT) ---- I am not adding join date because it has default constraint which automatically take current date. or “I omitted JOIN_DATE to use the DEFAULT value.”
VALUES
(2,'Amit',NULL,40000,'HR');

/* Extra Data 

INSERT INTO EMPLOYEE (EMP_ID, NAME, EMAIL, SALARY, DEPT, JOIN_DATE) VALUES
(1,  'Anna',        'anna@gmail.com',        52000,  'IT',  '2022-03-10'),
(2,  ' Bob ',       'bob@yahoo.com',         48000,  'HR',  '2021-07-15'),
(3,  'AlA',         'ala@test.com',          60000,  'IT',  '2023-01-20'),
(4,  'David Richard', 'da@vid@gmail.com',      70000,  'FIN', '2020-11-05'),
(5,  'Eve',         NULL,                    45000,  'HR',  '2023-06-01'),
(6,  'Hannah',      'hannah@test.com',       80000,  'IT',  '2019-09-09'),
(7,  'Level',       'level@mail.com',        55000,  'OPS', '2022-02-02'),
(8,  'Radar',       'radar@gmail.com',       62000,  'IT',  '2021-12-12'),
(9,  'John Bento',  'john@gmail.com',        50000,  'IT',  '2023-04-04'),
(10, 'Mark',        'mark@test.com',         47000,  'HR',  '2022-08-18'),
(11, 'Malayalam',   'mal@test.com',          90000,  'IT',  '2018-05-05'),
(12, 'Noon',        'noon@@mail.com',        53000,  'OPS', '2020-10-10'),
(13, 'Refer',       'refer@test.com',        61000,  'FIN', '2021-03-03'),
(14, 'Sam Thomas', ' sam@gmail.com ',       48000,  'HR',  '2022-12-01'),
(15, 'Ada',         'ada@test.com',          75000,  'IT',  '2019-01-01'),
(16, 'Otto',        'otto@gmail.com',        68000,  'OPS', '2020-06-06'),
(17, 'Paul',        'paul@mail.com',         52000,  'IT',  '2023-07-07'),
(18, 'Civic',       'civic@test.com',        81000,  'FIN', '2017-04-04'),
(19, 'Kayak',       'kayak@gmail.com',       59000,  'IT',  '2022-09-09'),
(20, 'Mike',        'mike@test.com',         46000,  'HR',  '2021-01-11'),

(21, 'A',           ' a@test.com',            30000,  'IT',  '2023-01-01'),
(22, 'AB',          'ab@test.com',           32000,  'HR',  '2023-02-02'),
(23, 'Aa',          'aa@test.com',           34000,  'OPS', '2022-03-03'),
(24, 'aba',         'aba@mail.com',          36000,  'IT',  '2021-04-04'),
(25, 'xyzx',        'xyzx@test.com',         38000,  'FIN', '2020-05-05'),
(26, 'Test User',   'test.user@test.com',    40000,  'HR',  '2019-06-06'),
(27, 'rotor',       'rot@or@mail.com',        42000,  'OPS', '2018-07-07'),
(28, 'Snow',        'snow@test.com',         44000,  'IT',  '2022-08-08'),
(29, 'wow',         'wow@gmail.com',         46000,  'HR',  '2021-09-09'),
(30, 'Data',        'data@test.com',         48000,  'FIN', '2020-10-10'),

(31, 'Eclipse',     'ec@lipse@gmail.com',     50000,  'IT',  '2024-01-15'),
(32, 'Uma',         NULL,                    -1000,  'HR',  '2023-05-20'),
(33, 'Oscar',       'oscar@gmail.com',       62000.75,'IT', '2022-11-11'),
(34, 'Ivan',        ' ivan@test.com',         100000, 'FIN', '2016-02-02'),
(35, 'Anna Maria',  ' ann@a maria@mail.com',   55000,  'HR',  '2021-03-03'),
(36, 'Leo',         'leo@gmail.com',         0,      'OPS', '2023-08-08'),
(37, 'Nitin',       'nitin@gmail.com ',       75000,  'IT',  '2020-12-12'),
(38, 'Olivia',      'ol@ivia@test.com',       65000,  'FIN', '2022-06-06'),
(39, 'Peter',       'peter@@gmail.com ',      58000,  'HR',  '2021-07-07'),
(40, 'Queen',       'queen@test.com',        70000,  'IT',  '2019-09-09');

*/


---Question 3 ---------------------------------------

/*
QUESTION 3 / 50 — OPERATORS (LOGICAL PRECEDENCE TRAP)
❓ Task
👉 Write a query to fetch employees who:

1. Are in IT department 
2. OR are in HR department with salary > 50,000
⚠️ Logical precedence matters.
*/


SELECT 
  EMP_ID,
  DEPT,
  SALARY
FROM EMPLOYEE
WHERE
  DEPT = 'IT'
  OR 
  (DEPT = 'HR' AND SALARY > 40000); --- I Cant use comparision Operator becuase Data Type is VARCHAR.



----Question-4-----------------------------------------------------------------------------------------

/*
QUESTION 4 / 50 — OPERATORS (BETWEEN vs AND)

👉 Write a query to fetch employees:

1. Salary between 30,000 and 60,000
2. Department not equal to HR
3. EMAIL is NULL
*/

SELECT
  EMP_ID,
  SALARY,
  DEPT,
  EMAIL
FROM EMPLOYEE
WHERE
  SALARY BETWEEN 30000 AND 60000
  AND
  DEPT != 'HR'
  AND
  EMAIL IS NULL;

----Question-5/50-------------------------------------------------------------
/*
❓ Task

👉 Write a query to display:

1. NAME in uppercase
2. First 4 characters of EMAIL
3. Length of NAME

*/

SELECT
  EMP_ID,
  NAME,
  UPPER(NAME) AS CAP,
  EMAIL,
  SUBSTR(EMAIL,1,4) AS First_4_chart, --- i can use LEFT also but substr is recommended in snowflakes.
  LENGTH(NAME) AS name_length
 FROM EMPLOYEE;


---Question-6--------------------------------------------------------------------------------------

/*
👉 Write a query to display:

1. SALARY
2. Salary increased by 12%, rounded to 2 decimal places
3. Salary divided by 3, rounded up

Use numeric functions only.
*/

SELECT
  EMP_ID,
  SALARY,
  SALARY * 0.12 AS SALARY_INCR,
  ROUND(SALARY_INCR, 2) AS Salary_Round,
  CEIL(Salary_round / 3) AS Salary_3 
  /*AS QUESTION State Round up so used CEIL() Function or i should have used Round.Function,
For exmaple Input,Result,Logic
CEIL(10.1)->(10.1)->11,Always goes UP
FLOOR(10.9)->(10.9)->10,Always goes DOWN
ROUND(10.4)->(10.4)->10,Goes to the NEAREST (.5 goes up)
*/
FROM EMPLOYEE;

---Question 7---------------------------------------------------------------------------------------------------------
/*
👉 Write a query to display:

1. JOIN_DATE
2. JOIN_DATE 30 days after
3. JOIN_DATE 1 month before
*/
/*
----Remember -------
1. plus 1 means one month from the date mentioned
2. minus 1 menas one month backward or less from the date mentioned
3. you can add how many months you required as per the requirments for example: 1,2,3,4,5, or -1,-2,-3,-4, etc
*/

SELECT
EMP_ID,
JOIN_DATE,
DATEADD(DAY, 30, TO_DATE(JOIN_DATE)) AS days_After,
DATEADD(MONTH, -1,TO_DATE(JOIN_DATE)) AS month_before 
FROM EMPLOYEE;



----Question-8----------------------------------------------------------------------------------------------------
/*
👉 Write a query to fetch employees who:

1. EMAIL is NULL
   OR
2. EMAIL contains '@gmail.com'
*/

SELECT
  EMP_ID,
  EMAIL
FROM EMPLOYEE
WHERE
  EMAIL IS NULL
  OR
  EMAIL LIKE '%@gmail.com';



----Question-9----------------------------------------------------------------------------------------------

/*
Write a query to fetch employees who:
1. NAME starts with letter 'A'
2. Length of NAME is greater than 5
*/

/*
---REMEMBER--Interview Rules You Must Remember

1. Aliases cannot be used in WHERE Because “WHERE is evaluated before SELECT, so aliases are not available”
2. 'A%' → starts with A
3. '%A%' → contains A
*/

SELECT
  EMP_ID,
  NAME,
  LENGTH(NAME) AS LENGTH_NAME
FROM EMPLOYEE
WHERE
  NAME LIKE 'A%' 
  AND
  LENGTH(NAME) > 5 ; 

------Question 10-----------------------------------------------------------------------------------

/*
👉 Write a query to fetch employees:

1. Whose NAME has leading or trailing spaces
2. AND department is IT
*/

SELECT
  EMP_ID,
  NAME,
  DEPT
FROM EMPLOYEE
WHERE
  DEPT = 'IT'
  AND
  NAME <> TRIM(NAME);




---Question-11----------------------------------------------------------------------------------------------
/*
👉 Write a query to fetch employees:
1. Whose salary is not a multiple of 1,000
2. AND salary is greater than 35,000
*/

SELECT
  EMP_ID,
  SALARY
FROM EMPLOYEE
WHERE
  MOD(SALARY, 1000) <> 0
  AND 
  SALARY > 35000;

----Question-12------------------------------------------------------------------------------------
/*
👉 Write a query to fetch employees:
1. Who joined in the year 2023
2. AND joined after June 30, 2023
*/

SELECT
  EMP_ID,
  NAME,
  JOIN_DATE
FROM EMPLOYEE
WHERE
  DATE_PART('YEAR', JOIN_DATE) = 2023
  AND
  JOIN_DATE > DATE '2023-06-30';


----Question 13-----------------------------------------------------------------------------------------

/*
👉 Write a query to fetch employees:
1. Who did NOT join in 2023
2. AND joined before 2022-01-01
*/

SELECT
 EMP_ID,
 NAME,
 JOIN_DATE
FROM EMPLOYEE
WHERE
  DATE_PART('YEAR', JOIN_DATE) <> 2023
  AND
  JOIN_DATE < DATE '2022-01-01';


----Question 14-----------------------------------------------------------------------------------------------------

/*
👉 Write a query to fetch employees:
1. Whose EMAIL does NOT end with '@gmail.com'
2. AND EMAIL is NOT NULL
*/

SELECT
  EMP_ID,
  NAME,
  EMAIL
FROM EMPLOYEE
WHERE
  EMAIL NOT LIKE '%@gmail.com'
  AND
  EMAIL IS NOT NULL;

----Question-15---------------------------------------------------------------------------------------------

/*
👉 Write a query to fetch employees:

1. Whose salary is exactly divisible by 5,000
2. AND salary is less than or equal to 75,000
*/

SELECT
  EMP_ID,
  NAME,
  SALARY
FROM EMPLOYEE
WHERE
  MOD(SALARY, 5000) = 0
  AND
  SALARY <= 75000;

  ----Question 16-------------------------------------------------------------------
  /*
  👉 Write a query to fetch employees:

1. Whose NAME ends with 'a' (case-insensitive)
2. AND who joined in the last 90 days from today
*/
/*
-----Remmber-----
The Components
1. <date_or_time_part>: This is the unit you want the result in.
   Common units: year, month, day, week, hour, minute, second.
2. <start_date>: The earlier date (usually).
3. <end_date>: The later date.
4. In Snowflake, the only difference between LIKE and ILIKE is Case Sensitivity.
   The "I" in ILIKE stands for Insensitive (meaning it ignores whether letters are capital or lowercase).
5. “Using DATEADD is safer than DATEDIFF because it avoids future-date edge cases.”
*/

SELECT
  EMP_ID,
  NAME,
  JOIN_DATE
FROM EMPLOYEE
WHERE
 NAME ILIKE '%a'
 AND
 JOIN_DATE >= DATEADD(DAY,-90, CURRENT_DATE()); 

------Question-17-------------------------------------------------------------------------------------------------
/*
👉 Write a query to fetch employees who:
1. Are in IT or HR
2. AND have salary greater than 60,000
3. OR joined before 2021-01-01
*/

SELECT
  EMP_ID,
  NAME,
  DEPT,
  SALARY,
  JOIN_DATE
FROM EMPLOYEE
WHERE
  ((DEPT ILIKE 'IT' OR DEPT ILIKE 'HR')
  AND
  SALARY > 60000)
  OR 
  JOIN_DATE < DATE '2021-01-01';
  
---Question-18--------------------------------------------------------------------------------------------

/*
👉 Write a query to fetch employees:

1. Whose EMAIL has leading or trailing spaces
2. AND whose email is not NULL
*/

SELECT
  EMP_ID,
  NAME,
  EMAIL
FROM EMPLOYEE
WHERE
  (EMAIL <> LTRIM(EMAIL))
  OR 
  (EMAIL <> RTRIM(EMAIL))
  AND 
  EMAIL IS NOT NULL;

 ---Question-19----------------------------------------------------------------------------------------
 /*
 👉 Write a query to fetch employees:

1. Whose EMAIL contains more than one @ symbol
2. AND email is not NULL
 */
 
SELECT
  EMP_ID,
  NAME,
  EMAIL
FROM EMPLOYEE
WHERE
  REGEXP_LIKE(EMAIL, '.*@.*@.*')
  AND
  EMAIL IS NOT NULL;

----Question-20------
/*
👉 Write a query to fetch employees:

1. Whose NAME contains only alphabets (no numbers, no special characters)
2. AND NAME is not NULL
*/

SELECT
  EMP_ID,
  NAME
FROM EMPLOYEE
WHERE
  REGEXP_LIKE(NAME, '^[A-Za-z]+$','i' )
  AND
  NAME IS NOT NULL;

  /*
 Snowflake REGEXP_LIKE – Regex Symbols Cheat Sheet 🧠

Below is a well-organized reference table for the most commonly used symbols in Snowflake REGEXP_LIKE (and most regex engines).
I’ve grouped them by what job they do, so memorization feels natural instead of overwhelming.

1️⃣ Anchors — “Where to Look”

Anchors don’t match characters.
They tell Snowflake where the match must occur in the string.

Symbol	Name	What it does	Example	Matches
1. ^	Caret	Start of the string	'^A'	Apple (not Pan)
2. $	Dollar	End of the string	't$'	Bat (not Tap)

2️⃣ Quantifiers — “How Many Times”
Quantifiers control how often the previous character or group can repeat.

Symbol	Name	Meaning	Example	Matches
1. *	Asterisk	0 or more times	'ab*'	a, ab, abbb
2. +	Plus	1 or more times	'ab+'	ab, abbb
3. ?	Question	0 or 1 time (optional)	'abc?'	ab, abc
4. {n}	Exact	Exactly n times	'a{3}'	aaa
5. {n,m}	Range	Between n and m times	'a{2,4}'	aa, aaa, aaaa

3️⃣ Character Classes — “What Is Allowed”
Character classes define which characters are valid at a position.

Symbol	Name	Description	Example	Matches
1. .	Dot	Any single character	'a.c'	abc, a1c, a!c
2. [ ]	Set	Any character in the list	'[abc]'	a or b or c
3. [^ ]	Negated set	Anything NOT in the list	'[^0-9]'	Any non-digit
4. [a-z]	Range	Characters within range	'[0-9]'	Any digit 0–9
5. `	`	Pipe	OR condition	`'cat

4️⃣ Shorthand Character Classes (Snowflake-Friendly)

Snowflake supports regex shortcuts — but you usually need double backslashes (\\).

Shortcut	Expands to	Meaning
1. \\d	[0-9]	Any digit
2. \\D	[^0-9]	Any non-digit
3. \\w	[a-zA-Z0-9_]	Word character
4. \\s	[ \t\n\r\f\v]	Whitespace

5️⃣ Escaping Special Characters — “Treat It Literally”

Some characters have special meaning in regex.
To match them as plain text, you must escape them.

Pattern	Matches
1. \\.	Literal dot .
2. \\?	Literal question mark ?
3. \\$	Literal dollar sign $


🧪 Quick Practice — Decode This Pattern
Pattern
'^[0-9]{2,5}$'

Step-by-step meaning

1. ^ → Start of string
2. [0-9] → Digits only
3. {2,5} → Length must be between 2 and 5 digits
4. $ → End of string

✅ Matches

123
4522

❌ Does NOT match

1 (too short)
123456 (too long)
  */

  ---Question-21---
  /*
👉 Write a query to fetch employees:

1. Whose NAME contains internal spaces
(example: 'Amit Kumar')
2. AND name is not NULL
  */

  SELECT
    EMP_ID,
    NAME
  FROM EMPLOYEE
  WHERE
    NAME LIKE '% %'
    AND 
    NAME IS NOT NULL;
    
/*
---Delete Rows in Table you can put anyting instead of Emp_ID.
DELETE FROM EMPLOYEE
WHERE EMP_ID IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16);
*/

--Question-22--
/*
Write a query to fetch employees:
1. Whose SALARY is zero or negative
2. AND department is not IT
*/

SELECT
  EMP_ID,
  NAME,
  SALARY
FROM EMPLOYEE
WHERE
  SALARY <= 0
  AND
  DEPT <> 'IT';

--Question-23-----
/*
Write a query to fetch employees:
1. Who joined between 2021-01-01 and 2023-12-31 (inclusive)
2. AND department is IT or HR
*/

SELECT
  EMP_ID,
  NAME,
  JOIN_DATE,
  DEPT
FROM EMPLOYEE
WHERE
  JOIN_DATE BETWEEN DATE '2021-01-01' AND DATE '2023-12-31'
  AND 
  DEPT IN ('IT', 'HR');

  ---TO_CHAR IN SELECT statment inorder to change the date format for example:DD-MM-YYYY etc.

  ----Question-24-----
/*
  Write a query to fetch employees:

1. Whose department is exactly it (lowercase only)
2. AND department is not NULL

⚠️ This is about case sensitivity, not business logic.
*/

SELECT
  EMP_ID,
  NAME,
  DEPT
FROM EMPLOYEE
WHERE
  DEPT = 'it' ---- i can use like also but like search 'it' in whole character if there is 'it' at the end then it going to show that enter to 
  AND
  DEPT IS NOT NULL;
  
----Question-25-------
/*
Write a query to fetch employees:

1. Whose NAME does NOT contain any spaces
2. AND name is not NULL
*/

SELECT
  EMP_ID,
  NAME
FROM EMPLOYEE
WHERE
  NAME NOT LIKE '% %'
  AND
  NAME IS NOT NULL;


-------------------Advanced level starts now. Questions get sharper. Reading matters more than typing.---------

--Question-26-----
/*
👉 Write a query to fetch employees:

1. Whose SALARY is stored as a whole number (no decimals)
2. AND SALARY is greater than 40,000
*/

SELECT
  EMP_ID,
  NAME,
  SALARY
FROM EMPLOYEE
WHERE
  MOD(SALARY, 1) = 0
  AND
  SALARY > 40000;

--Question-27-----
/*
👉 Write a query to fetch employees:

1. Whose JOIN_DATE is in March (any year)
2. AND whose NAME starts with exactly two characters (no more, no less)
*/

SELECT
  EMP_ID,
  NAME,
  JOIN_DATE
FROM EMPLOYEE
WHERE
  DATE_PART(MONTH, JOIN_DATE) = 3
  AND 
  LENGTH(NAME) = 2;

--Question-28---

/*
Write a query to fetch employees:

1. Whose NAME starts with a vowel (A, E, I, O, U)
2. AND name length is greater than 4
3. AND NAME is not NULL

Rules:
1. No regex
2. Use string functions/operators only
3. Case-insensitive
*/

SELECT
  EMP_ID,
  NAME
FROM EMPLOYEE
WHERE
  SUBSTR(NAME, 1, 1) IN ('A','E','I','O','U')
  AND 
  LENGTH(NAME) > 4
  AND
  NAME IS NOT NULL;

---Question-29-----

/*
👉 Write a query to fetch employees:

1. Who joined more than 2 years ago from today
2. AND whose SALARY is greater than 50,000

Rules:
1. No aggregates
2. No hardcoded dates
3. Use date arithmetic properly
*/

SELECT
  EMP_ID,
  NAME,
  JOIN_DATE,
  SALARY
FROM EMPLOYEE
WHERE
  DATEADD(YEAR, -2, CURRENT_DATE()) > JOIN_DATE
  AND 
  SALARY > 50000;

/*
  DATE_PART (The "Extractor")
Use this when you have a full date (like 2025-05-15) but you only want to know the year, the month, or the day of the week.
 DATEADD (The "Calculator")
Use this when you want to move a date forward or backward in time. You are adding (or subtracting) a specific interval.
*/

---Question-30----
/*
Write a query to fetch employees:
1. Whose NAME length is an even number
2. AND whose SALARY ends with exactly two zeros
   (example: 45000, 62000)

Rules:
1. ❌ No regex
2. ❌ No casting salary to string
3. Use numeric + string logic you already know
*/

SELECT
  EMP_ID,
  NAME,
  SALARY
FROM EMPLOYEE
WHERE
  MOD(LENGTH(TRIM(NAME)), 2) = 0
  AND 
  MOD(SALARY, 100) = 0
  AND 
  MOD(SALARY, 1000) <> 0;

  /* Following code remove the spaces and update the table
UPDATE EMPLOYEE
SET EMP_NAME = TRIM(EMP_NAME);
  */


-----------------------------Pro level starts now------------------------------------

--Question-31------------------

/*
Write a query to fetch employees:
1. Whose NAME starts and ends with the same character
   Example: Anna, Bob, AlA
2. Comparison must be case-insensitive
3. NAME must be at least 2 characters long
4. NAME is not NULL

Rules:
1. ❌ No regex
2. ❌ No aggregates
3. Use string functions only

⚠️ This is a classic logic + string-function test.
*/

SELECT
  EMP_ID,
  NAME  
FROM EMPLOYEE
WHERE
  UPPER(LEFT(NAME,1)) = UPPER(RIGHT(NAME,1))
  AND
  LENGTH(NAME) >= 2
  AND
  NAME IS NOT NULL;


/*
Remember--
1. we use STARTWITH() and ENDWITH() when we know the starting and ending words.
2. we use LIKE to find specific word or group of words in Name.
*/



----Question-32------

/*
👉 Write a query to fetch employees:

1. Whose JOIN_DATE is on a weekend (Saturday or Sunday)
2. AND whose NAME does not start with a vowel (A, E, I, O, U)
3. Comparison must be case-insensitive
4. NAME is not NULL

Rules:
1. ❌ No aggregates
2. ❌ No regex
3. Use date + string functions

Be careful with Snowflake date behavior
*/

SELECT
  EMP_ID,
  NAME,
  EMAIL,
  SALARY
FROM EMPLOYEE
WHERE
  (EMAIL LIKE '%0%' OR EMAIL LIKE '%1%' OR EMAIL LIKE '%2%' OR EMAIL LIKE '%3%' 
   OR EMAIL LIKE '%4%' OR EMAIL LIKE '%5%' OR EMAIL LIKE '%6%' OR EMAIL LIKE '%7%' 
   OR EMAIL LIKE '%8%' OR EMAIL LIKE '%9%')
  AND MOD(SALARY, 1) > 0
  AND EMAIL IS NOT NULL;

/*
1. The REPLACE Function

REPLACE is used for Substring Substitution. It looks for a specific sequence of characters (a "chunk" or a "word") and swaps it for something else. If the exact sequence isn't found, nothing changes.

SyntaxSQL
REPLACE( <input_string>, <search_string>, <replacement_string> )

Example in WHERE Clause 
Use this when you want to filter for a specific domain but need to ignore a common prefix.SQL
SELECT 
  EMP_NAME, 
  EMAIL
FROM EMPLOYEES
-- Find employees who would be at 'outlook.com' if we switched their gmail domain
WHERE 
  REPLACE(EMAIL, 'gmail.com', 'outlook.com') = 'rahul_2024@outlook.com';

2. The TRANSLATE Function

TRANSLATE is used for Character-to-Character Mapping. It replaces multiple individual characters at once based on their position in a list. It is much more efficient than nesting multiple REPLACE functions.

SyntaxSQL
TRANSLATE( <input_string>, <characters_to_find>, <characters_to_replace> )

Example in WHERE Clause
Use this when you want to find a record regardless of how it was "punctuated" (with dots, underscores, or dashes).SQL

SELECT 
  EMP_NAME, 
  EMAIL
FROM EMPLOYEES
-- Find the email by removing all possible separators (@, ., _) 
-- and checking against a clean string
WHERE 
  TRANSLATE(EMAIL, '@._', '   ') = 'rahul 2024 gmail com';
  
Why use them in the WHERE clause?
As you correctly noted, using them in SELECT just changes how the data looks on your screen. Using them in WHERE allows you to search through "dirty" data.
*/

----Question-33----------------
/*
Write a query to fetch employees:
1. Whose NAME starts with a consonant (not A, E, I, O, U)
2. AND whose JOIN_DATE is in the first half of the year
   (January–June)
3. Comparison must be case-insensitive
4. NAME is not NULL

Rules:
1. ❌ No regex
2. ❌ No aggregates
*/

SELECT
  EMP_ID,
  NAME,
  JOIN_DATE  
FROM EMPLOYEE
WHERE
  SUBSTR(UPPER(NAME),1,1) NOT IN ('A','E','I','O','U')
  AND
  MONTH(JOIN_DATE) <= 6
  AND
  NAME IS NOT NULL;

---Question-34------
/*
👉 Write a query to fetch employees:
1. Whose SALARY is between 45,000 and 80,000 (inclusive)
2. AND who joined in the last 18 months
3. AND department is not HR

Rules:
1. ❌ No aggregates
2. ❌ No hard-coded dates
*/

SELECT
  EMP_ID,
  NAME,
  SALARY,
  JOIN_DATE,
  DEPT
FROM EMPLOYEE
WHERE
  SALARY BETWEEN 45000 AND 80000
  AND 
  DATEADD(MONTH, -18, CURRENT_DATE()) <= JOIN_DATE
  AND
  DEPT <> 'HR';

---Question-35------------
/*
👉 Write a query to fetch employees:
1. Whose EMAIL starts with a letter (A–Z only)
2. AND EMAIL contains exactly one @ symbol
3. AND EMAIL is not NULL

Rules:
1. ❌ No regex
2. ❌ No aggregates
3. ❌ No casting
*/

SELECT
  EMP_ID,
  NAME,
  EMAIL
FROM EMPLOYEE
WHERE
  SUBSTR(UPPER(EMAIL),1,1) BETWEEN 'A' AND 'B'
  AND
  EMAIL LIKE '%@%'
  AND
  EMAIL NOT LIKE '%@%@%'
  AND 
  EMAIL IS NOT NULL;


---Question-36------------

/*
👉 Write a query to find:
1. Department-wise
2. Total salary
3. Average salary
Include only those departments that:
4. Have more than 3 employees
5. And have average salary greater than 50,000
*/

SELECT
  DEPT,
  SUM(SALARY) AS Total_Salary,
  AVG(SALARY) AS Average_Salary
FROM employee 
GROUP BY 
  DEPT
HAVING
  COUNT(*) > 3
  AND
  AVG(SALARY) > 50000;


---Question-37---------
/*
Task

👉 Write a query to find:
1. Department-wise average salary

Only for employees:
2. Whose JOIN_DATE is after 2021-01-01

Include only departments where:
3. Average salary > 60,000
*/


SELECT
  DEPT,
  AVG(SALARY) AS Avg_salary 
FROM EMPLOYEE
WHERE 
  JOIN_DATE > DATE '2021-01-01'
GROUP BY
  DEPT
HAVING
  AVG(SALARY) > 60000;



-----Question-38----

/*
Task

👉 Write one SQL query to find:
1. Department-wise
2. Number of distinct employees (EMP_ID)
3. Average salary
Consider only employees:
1. Who joined in the last 3 years
2. AND have a non-null EMAIL
Return only departments:
1. With at least 4 employees
2. AND average salary > 55,000
3. Sort the result by average salary descending
*/

SELECT
  COUNT(DISTINCT EMP_ID) AS Employee_ID,
  DEPT,
  AVG(SALARY) AS Avg_Salary
FROM EMPLOYEE
WHERE
  DATEADD(YEAR, -3, CURRENT_DATE()) <= JOIN_DATE
  AND
  EMAIL IS NOT NULL
GROUP BY
  DEPT
HAVING
  COUNT(DISTINCT EMP_ID) >= 4
  AND
  AVG(SALARY) > 55000
ORDER BY Avg_Salary DESC;



----Question-39-----

/*
Your manager says:

“I want to identify problematic departments based on hiring quality and salary distribution.”

Task

👉 Write ONE SQL query to find departments that meet ALL conditions below:

1. Department-wise
2. Consider only employees who joined in the last 5 years

Calculate:
1. Total employees
2. Employees with invalid emails
3. Invalid email =
    a. EMAIL is NULL OR
    b. does not contain exactly one @

Return only departments where:
1. Total employees ≥ 6
2. Invalid-email employees ≥ 40% of total employees
3. Sort result by invalid-email percentage descending
*/

SELECT
  DEPT,
  COUNT(EMP_ID) AS Total_Employees,
  SUM(CASE 
    WHEN EMAIL IS NULL 
    OR EMAIL NOT LIKE '%@%' 
    OR EMAIL LIKE '%@%@%' 
    THEN 1 
    ELSE 0
  END ) AS INVAILD_EMAIL,
  SUM(CASE 
    WHEN EMAIL IS NULL 
    OR EMAIL NOT LIKE '%@%' 
    OR EMAIL LIKE '%@%@%' 
    THEN 1 
    ELSE 0
  END)*100/COUNT(*) AS INVAILD_EMAIL_PERCENTAGE
FROM EMPLOYEE
WHERE
  DATEADD(YEAR, -5, CURRENT_DATE()) <= JOIN_DATE
GROUP BY
  DEPT
HAVING
  COUNT(EMP_ID) >= 6
  AND
  SUM(CASE 
    WHEN EMAIL IS NULL 
    OR EMAIL NOT LIKE '%@%' 
    OR EMAIL LIKE '%@%@%' 
    THEN 1 
    ELSE 0
  END)*100/COUNT(*) >= 40
ORDER BY INVAILD_EMAIL_PERCENTAGE DESC;

/*
CASE
  WHEN condition THEN value
  WHEN condition THEN value
  ELSE value
END
*/

----Question-41--------
/*
Write one SQL query to find:

1. Department-wise
2. Total number of employees

Number of employees in each department who:
1. Have salary < 50,000
2. OR EMAIL is NULL

Return only departments where:
1. Total employees ≥ 5
2. And the above “problematic employees” count ≥ 2
*/

SELECT
  DEPT,
  COUNT(EMP_ID) AS Total_Employee,
  COUNT(CASE WHEN SALARY < 50000 OR EMAIL IS NULL THEN 1 ELSE 0 END) AS PROBLEMATIC_EMPLOYEE
FROM EMPLOYEE
GROUP BY
  DEPT
HAVING
  COUNT(EMP_ID) >= 5
  AND
  COUNT(CASE WHEN SALARY < 50000 OR EMAIL IS NULL THEN 1 ELSE 0 END) >= 2;

---Question-42-----
/*
Write one SQL query to find:

1. Department-wise
2. Total number of distinct employees
3. Number of distinct employees with invalid email
4. Definition — invalid email

An email is invalid if any of the following is true:

1. EMAIL is NULL
2. Email does not contain @
3. Email contains more than one @

Return only departments where:

1. Total distinct employees ≥ 5
2. Invalid-email employees ≥ 2
*/


SELECT
   DEPT,
   COUNT(DISTINCT(EMP_ID)),
   COUNT(DISTINCT CASE WHEN EMAIL IS NULL OR EMAIL NOT LIKE '%@%' OR EMAIL LIKE '%@%@%' THEN EMP_ID END) AS INVAILD_EMAIL
FROM EMPLOYEE
GROUP BY
  DEPT
HAVING
  COUNT(DISTINCT(EMP_ID)) >= 5
  AND
 COUNT(DISTINCT CASE WHEN EMAIL IS NULL OR EMAIL NOT LIKE '%@%' OR EMAIL LIKE '%@%@%' THEN EMP_ID END) >= 2;

-- Question-43----------

/*
Scenario

HR wants to understand recent hiring quality by department.

Task

Write ONE SQL query to find:
1. Department-wise
2. Total number of employees
3. Number of employees who joined in the last 1 year
4. Number of employees who joined in the last 3 years
5. Number of employees who joined more than 3 years ago

👉 All three counts must be calculated in the same query.

Return only departments where:
1. Total employees ≥ 6
2. Employees joined in the last 1 year ≥ 2
*/

SELECT
  DEPT,
  COUNT(*) AS TOTAL_EMP,
  SUM( CASE WHEN JOIN_DATE >= DATEADD(YEAR, -1, CURRENT_DATE()) THEN 1 ELSE 0 END) AS JOINED_LAST_1_YR,
  SUM( CASE WHEN JOIN_DATE < DATEADD(YEAR, -1, CURRENT_DATE()) AND JOIN_DATE >= DATEADD(YEAR, -3, CURRENT_DATE()) THEN 1 ELSE 0 END) AS JOINED_LAST_3_YRS,
  SUM( CASE WHEN JOIN_DATE < DATEADD(YEAR, -3, CURRENT_DATE()) THEN 1 ELSE 0 END) AS JOINED_BEFORE_3_YRS
FROM EMPLOYEE
GROUP BY
  DEPT
HAVING
  COUNT(*) >= 6
  AND 
  SUM( CASE WHEN JOIN_DATE >= DATEADD(YEAR, -1, CURRENT_DATE()) THEN 1 ELSE 0 END) >= 2;

---Question-44------
/*
Scenario

Management wants to identify top-paying departments, but the system you’re using does NOT allow window functions.

Task

Write ONE SQL query to find:

1. Department-wise
2. Average salary
3. Return only the TOP 2 departments by average salary
*/

SELECT TOP 2
  DEPT,
  AVG(SALARY) AS avg_salary
FROM EMPLOYEE
GROUP BY
  DEPT
ORDER BY AVG(SALARY) DESC;


/*
(OR) BELOW SQL QUERY 

SELECT
  DEPT,
  AVG(SALARY) AS avg_salary
FROM EMPLOYEE
GROUP BY
  DEPT
ORDER BY AVG(SALARY) DESC
FETCH 2 ROW ONLY; ----YOU CAN USE "LIMIT 2;"
*/

--Question-45---

/*
Scenario

Finance wants to review salary risk by department.

Task

Write one SQL query to find:

1. Department-wise
2. Total number of employees
3. Number of employees who are considered high risk
4. Definition — high risk employee

An employee is high risk if any of the following is true:

1. SALARY is NULL
2. SALARY < 40,000
3. SALARY > 120,000

Return only departments where:

1. Total employees ≥ 5
2. High-risk employees ≥ 30% of total employees
*/

SELECT
  DEPT,
  COUNT(EMP_ID) AS TOTAL_EMPLOYEE,
  SUM(
    CASE 
      WHEN SALARY IS NULL 
        OR SALARY < 40000 
        OR SALARY > 120000 
      THEN 1 ELSE 0 
    END
  ) AS HIGH_RISK_EMP,
  (
    SUM(
      CASE 
        WHEN SALARY IS NULL 
          OR SALARY < 40000 
          OR SALARY > 120000 
        THEN 1 ELSE 0 
      END
    ) * 100.0 / COUNT(EMP_ID)
  ) AS HIGH_RISK_PCT
FROM EMPLOYEE
GROUP BY
  DEPT
HAVING
  COUNT(EMP_ID) >= 5
  AND
  (
    SUM(
      CASE 
        WHEN SALARY IS NULL 
          OR SALARY < 40000 
          OR SALARY > 120000 
        THEN 1 ELSE 0 
      END
    ) * 100.0 / COUNT(EMP_ID)
  ) >= 30;
