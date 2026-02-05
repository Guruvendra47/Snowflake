CREATE DATABASE IF NOT EXISTS DB_SQL_PRACTICE;
USE DATABASE DB_SQL_PRACTICE;
CREATE OR REPLACE SCHEMA SM_SQL_PRACTICE;
USE SCHEMA SM_SQL_PRACTICE;

--------------------Create-Table-Format--------------------------------------------------------------

CREATE TABLE IF NOT EXISTS EMPLOYEE
(
  EMP_ID    INT PRIMARY KEY,
  NAME      VARCHAR(50) NOT NULL,
  EMAIL     VARCHAR(100) UNIQUE, ---- onlY difference b/w primary key is UNIQUE key has Null Value
  SALARY    NUMBER(10,2),
  DEPT      VARCHAR(20),
  JOIN_DATE DATE DEFAULT CURRENT_DATE
);

-----------------------------Data--------------------------------------------------------------------

INSERT INTO EMPLOYEE (EMP_ID, NAME, EMAIL, SALARY, DEPT, JOIN_DATE) 
VALUES
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
