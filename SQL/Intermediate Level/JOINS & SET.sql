/*
================================================================================
SQL JOINS & SET OPERATIONS: COMBINING & MANIPULATING RESULT SETS
================================================================================

OVERVIEW & CORE CONCEPTS:
-------------------------
1. SQL Joins:
   - INNER JOIN     : Returns only matching rows from both tables.
   - LEFT JOIN      : Returns all rows from the left table and matching rows from the right.
   - RIGHT JOIN     : Returns all rows from the right table and matching rows from the left.
   - FULL JOIN      : Returns all rows from both tables, filling NULLs for non-matches.
   - LEFT ANTI JOIN : Retrieves rows from the left table that have NO match in the right (using WHERE IS NULL).
   - FULL ANTI JOIN : Retrieves rows that do NOT match in either table.

2. SQL Set Operations:
   - Rules      : Column counts, order, and compatible data types must match across queries.
                  Column aliases in the result set are inherited from the FIRST SELECT statement.
   - UNION      : Combines results from multiple queries and eliminates duplicates.
   - UNION ALL  : Combines results from multiple queries including all duplicates (Faster execution).
   - EXCEPT     : Returns rows from the first query that are NOT present in the second query.
   - INTERSECT  : Returns only rows that exist in BOTH queries.
================================================================================
*/

USE MyDatabase;
GO


--==========================================================
-- 1. SQL JOINS (COMBINING DATA FROM MULTIPLE TABLES)
--==========================================================

-- Inspect tables before joining
SELECT * FROM customers;
SELECT * FROM orders;


----------------------------------------------------------
-- INNER JOIN
-- Returns only matching rows from both tables
----------------------------------------------------------
SELECT
    c.id,
    c.first_name,
    o.order_id,
    o.sales
FROM customers AS c
INNER JOIN orders AS o
    ON c.id = o.customer_id;


----------------------------------------------------------
-- LEFT JOIN
-- Returns all rows from left table and only matching from right
----------------------------------------------------------
SELECT *
FROM customers AS c
LEFT JOIN orders AS o
    ON c.id = o.customer_id;


----------------------------------------------------------
-- RIGHT JOIN
-- Returns all rows from right table and only matching from left
----------------------------------------------------------
SELECT *
FROM customers
RIGHT JOIN orders
    ON customers.id = orders.customer_id;


-- Task: Get all customers along with their orders, including orders without matching customers (Using left join)
SELECT *
FROM orders AS o
LEFT JOIN customers AS c
    ON o.customer_id = c.id;


----------------------------------------------------------
-- FULL JOIN
-- Returns all rows from both tables
----------------------------------------------------------
SELECT *
FROM customers
FULL JOIN orders 
    ON customers.id = orders.customer_id;


----------------------------------------------------------
-- ADVANCED JOIN TYPES (ANTI JOINS)
----------------------------------------------------------

-- Left Anti Join: Returns rows from left that have no match in right
-- Task: Get all customers who haven't placed any order
SELECT *
FROM customers AS c
LEFT JOIN orders AS o
    ON c.id = o.customer_id
WHERE o.customer_id IS NULL;

-- Full Anti Join: Returns only rows that don't match in either table
-- Task: Find customers without orders and orders without customers
SELECT *
FROM orders AS o 
FULL JOIN customers AS c
    ON c.id = o.order_id
WHERE c.id IS NULL OR o.customer_id IS NULL;


--==========================================================
-- 2. SQL SET OPERATIONS (RULES & EXAMPLES)
--==========================================================

----------------------------------------------------------
-- RULES OF SET OPERATIONS
----------------------------------------------------------

/* RULE: Column Count & Data Types Must Match */
-- Example showing mismatched column counts
SELECT
    FirstName,
    LastName,
    Country
FROM Sales.Customers
UNION
SELECT
    FirstName,
    LastName
FROM Sales.Employees;

/* RULE: Data Types Compatibility */
-- Example checking compatible data types
SELECT
    CustomerID,
    LastName
FROM Sales.Customers
UNION
SELECT
    FirstName,
    LastName
FROM Sales.Employees;

/* RULE: Column Order Must Be Identical */
SELECT
    LastName,
    CustomerID
FROM Sales.Customers
UNION
SELECT
    EmployeeID,
    LastName
FROM Sales.Employees;

/* RULE: Column Aliases Are Determined By The First SELECT Statement */
SELECT
    CustomerID AS ID,
    LastName AS Last_Name
FROM Sales.Customers
UNION
SELECT
    EmployeeID,
    LastName
FROM Sales.Employees;

/* RULE: Correct Column Mapping For Data Consistency */
SELECT
    FirstName,
    LastName
FROM Sales.Customers
UNION
SELECT
    LastName,
    FirstName
FROM Sales.Employees;


----------------------------------------------------------
-- SETS: UNION, UNION ALL, EXCEPT, INTERSECT
----------------------------------------------------------

-- TASK 1: Combine data from Employees and Customers into one table using UNION (Removes duplicates)
SELECT
    FirstName,
    LastName
FROM Sales.Customers
UNION
SELECT
    FirstName,
    LastName
FROM Sales.Employees;

-- TASK 2: Combine data from Employees and Customers into one table, including duplicates, using UNION ALL
SELECT
    FirstName,
    LastName
FROM Sales.Customers
UNION ALL
SELECT
    FirstName,
    LastName
FROM Sales.Employees;

-- TASK 3: Find employees who are NOT customers using EXCEPT
SELECT
    FirstName,
    LastName
FROM Sales.Employees
EXCEPT
SELECT
    FirstName,
    LastName
FROM Sales.Customers;

-- TASK 4: Find employees who are also customers using INTERSECT
SELECT
    FirstName,
    LastName
FROM Sales.Employees
INTERSECT
SELECT
    FirstName,
    LastName
FROM Sales.Customers;

-- TASK 5: Combine order data from Orders and OrdersArchive into one report without duplicates
SELECT
    'Orders' AS SourceTable,
    OrderID,
    ProductID,
    CustomerID,
    SalesPersonID,
    OrderDate,
    ShipDate,
    OrderStatus,
    ShipAddress,
    BillAddress,
    Quantity,
    Sales,
    CreationTime
FROM Sales.Orders
UNION
SELECT
    'OrdersArchive' AS SourceTable,
    OrderID,
    ProductID,
    CustomerID,
    SalesPersonID,
    OrderDate,
    ShipDate,
    OrderStatus,
    ShipAddress,
    BillAddress,
    Quantity,
    Sales,
    CreationTime
FROM Sales.OrdersArchive
ORDER BY OrderID;