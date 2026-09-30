/*
================================================================================
SQL FUNDAMENTALS: DDL, QUERYING, AGGREGATION & DATA FILTERING
================================================================================

OVERVIEW & CORE CONCEPTS:
-------------------------
1. Data Definition Language (DDL):
   - CREATE TABLE : Define database tables, data types, and key constraints (PRIMARY KEY, NOT NULL).
   - ALTER TABLE  : Modify existing table structures (ADD or DROP columns).
   - DROP TABLE   : Permanently delete a table and all its associated data (High Risk).

2. Data Querying & Manipulation (DQL / SELECT):
   - Selection & Projection : Fetch all columns (SELECT *) or filter specific columns for better query performance.
   - Filtering Mechanism    : 
     * WHERE  --> Filters individual rows BEFORE aggregation.
     * HAVING --> Filters grouped records AFTER aggregation (used with GROUP BY).
   - Sorting & Limiting     : Order results (ASC/DESC) and limit row counts (TOP).
   - Aggregation & Distinct : Compute summaries via aggregate functions (SUM, AVG) and eliminate duplicates using DISTINCT.
================================================================================
*/

-- DDL Process to Exercise
USE MyDatabase;
GO


--==========================================================
-- 1. DATA DEFINITION LANGUAGE (DDL COMMANDS)
--==========================================================

----------------------------------------------------------
-- CREATE: Create a new table called persons 
-- Columns: id, person_name, birth_date, and phone
----------------------------------------------------------
CREATE TABLE persons (
    id          INT NOT NULL,
    person_name VARCHAR(50) NOT NULL,
    birth_date  DATE,
    phone       VARCHAR(15) NOT NULL,
    CONSTRAINT  pk_persons PRIMARY KEY (id)
);

-- View structure/data of persons table
SELECT * FROM persons;


----------------------------------------------------------
-- ALTER: Add a new column called email to persons table
----------------------------------------------------------
ALTER TABLE persons
ADD email VARCHAR(50) NOT NULL;

SELECT * FROM persons;


----------------------------------------------------------
-- ALTER (REMOVE): Remove the column phone from persons table
----------------------------------------------------------
ALTER TABLE persons
DROP COLUMN phone;

SELECT * FROM persons;


----------------------------------------------------------
-- DROP: Delete the entire persons table from database
-- WARNING: Very risky operation!
----------------------------------------------------------
DROP TABLE persons;


--==========================================================
-- 2. DATA QUERYING & FILTERING (DQL / SELECT)
--==========================================================

-- Show all columns
SELECT * 
FROM customers;

-- Show only columns that I need
SELECT 
    first_name,
    country,
    score
FROM customers;

-- Filtering Data
SELECT * FROM customers;
SELECT * FROM orders;


----------------------------------------------------------
-- FILTERING BEFORE AGGREGATION (WHERE Clause)
----------------------------------------------------------

-- Filter rows with a score not equal to 0
SELECT * 
FROM customers
WHERE score != 0;

-- Retrieve customers from Germany
SELECT * 
FROM customers
WHERE country = 'Germany';


----------------------------------------------------------
-- FILTERING AFTER AGGREGATION (HAVING Clause)
----------------------------------------------------------

/* 
Find the average score for each country considering only 
customers with a score not equal to 0, and return only those 
countries with an average score greater than 430
*/
SELECT
    country,
    AVG(score) AS avg_score
FROM customers
WHERE score != 0
GROUP BY country
HAVING AVG(score) > 430;


----------------------------------------------------------
-- SORTING DATA (ORDER BY Clause)
----------------------------------------------------------

-- Sort from lowest to highest (ASC)
SELECT * 
FROM customers
ORDER BY score ASC;

-- Sort from highest to lowest (DESC)
SELECT * 
FROM customers
ORDER BY score DESC;


----------------------------------------------------------
-- DATA AGGREGATION (GROUP BY Clause)
----------------------------------------------------------

-- Find a total score for each country and customer
SELECT 
    country,
    first_name,
    SUM(score) AS total_score
FROM customers
GROUP BY 
    country,
    first_name;

-- Unique values for each country
SELECT DISTINCT 
    country
FROM customers;


----------------------------------------------------------
-- LIMITING DATA (TOP Clause)
----------------------------------------------------------

-- Retrieve only 3 customers with the highest score
SELECT TOP 3 * 
FROM customers
ORDER BY score DESC;

-- Get the two most recent orders
SELECT TOP 2 * 
FROM orders 
ORDER BY order_date DESC;