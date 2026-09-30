/* ==============================================================================
   SQL Subquery Functions
-------------------------------------------------------------------------------
   This script demonstrates various subquery techniques in SQL.
   It covers result types, subqueries in the FROM clause, in SELECT, in JOIN clauses,
   with comparison operators, IN, ANY, correlated subqueries, and EXISTS.
   
   Table of Contents:
     1. SUBQUERY - RESULT TYPES
     2. SUBQUERY - FROM CLAUSE
     3. SUBQUERY - SELECT
     4. SUBQUERY - JOIN CLAUSE
     5. SUBQUERY - COMPARISON OPERATORS 
     6. SUBQUERY - IN OPERATOR
     7. SUBQUERY - ANY OPERATOR
     8. SUBQUERY - CORRELATED 
     9. SUBQUERY - EXISTS OPERATOR
===============================================================================
*/

/* ==============================================================================
   SUBQUERY | RESULT TYPES
===============================================================================*/

/* Scalar Query */
SELECT
    AVG(Sales)
FROM Sales.Orders;

/* Row Query */
SELECT
    CustomerID
FROM Sales.Orders;

/* Table Query */
SELECT
    OrderID,
    OrderDate
FROM Sales.Orders;

/* ==============================================================================
   SUBQUERY | FROM CLAUSE
===============================================================================*/

/* TASK 1:
   Find the products that have a price higher than the average price of all products.
*/

-- Main Query
SELECT
*
FROM (
    -- Subquery
    SELECT
        ProductID,
        Price,
        AVG(Price) OVER () AS AvgPrice
    FROM Sales.Products
) AS t
WHERE Price > AvgPrice;

/* TASK 2:
   Rank Customers based on their total amount of sales.
*/
-- Main Query
SELECT
    *,
    RANK() OVER (ORDER BY TotalSales DESC) AS CustomerRank
FROM (
    -- Subquery
    SELECT
        CustomerID,
        SUM(Sales) AS TotalSales
    FROM Sales.Orders
    GROUP BY CustomerID
) AS t;

/* ==============================================================================
   SUBQUERY | SELECT
===============================================================================*/

/* TASK 3:
   Show the product IDs, product names, prices, and the total number of orders.
*/
-- Main Query
SELECT
    ProductID,
    Product,
    Price,
    (SELECT COUNT(*) FROM Sales.Orders) AS TotalOrders -- Subquery
FROM Sales.Products;

/* ==============================================================================
   SUBQUERY | JOIN CLAUSE
===============================================================================*/

/* TASK 4:
   Show customer details along with their total sales.
*/
-- Main Query
SELECT
    c.*,
    t.TotalSales
FROM Sales.Customers AS c
LEFT JOIN ( 
    -- Subquery
    SELECT
        CustomerID,
        SUM(Sales) AS TotalSales
    FROM Sales.Orders
    GROUP BY CustomerID
) AS t
    ON c.CustomerID = t.CustomerID;

/* TASK 5:
   Show all customer details and the total orders of each customer.
*/
-- Main Query
SELECT
    c.*,
    o.TotalOrders
FROM Sales.Customers AS c
LEFT JOIN (
    -- Subquery
    SELECT
        CustomerID,
        COUNT(*) AS TotalOrders
    FROM Sales.Orders
    GROUP BY CustomerID
) AS o
    ON c.CustomerID = o.CustomerID;

/* ==============================================================================
   SUBQUERY | COMPARISON OPERATORS
===============================================================================*/

/* TASK 6:
   Find the products that have a price higher than the average price of all products.
*/
-- Main Query
SELECT
    ProductID,
    Price,
    (SELECT AVG(Price) FROM Sales.Products) AS AvgPrice -- Subquery
FROM Sales.Products
WHERE Price > (SELECT AVG(Price) FROM Sales.Products); -- Subquery

/* ==============================================================================
   SUBQUERY | IN OPERATOR
===============================================================================*/

/* TASK 7:
   Show the details of orders made by customers in Germany.
*/
-- Main Query
SELECT
    *
FROM Sales.Orders
WHERE CustomerID IN (
    -- Subquery
    SELECT
        CustomerID
    FROM Sales.Customers
    WHERE Country = 'Germany'
);

/* TASK 8:
   Show the details of orders made by customers not in Germany.
*/
-- Main Query
SELECT
    *
FROM Sales.Orders
WHERE CustomerID NOT IN (
    -- Subquery
    SELECT
        CustomerID
    FROM Sales.Customers
    WHERE Country = 'Germany'
);

/* ==============================================================================
   SUBQUERY | ANY OPERATOR
===============================================================================*/

/* TASK 9:
   Find female employees whose salaries are greater than the salaries of any male employees.
*/
SELECT
    EmployeeID, 
    FirstName,
    Salary
FROM Sales.Employees
WHERE Gender = 'F'
  AND Salary > ANY (
      SELECT Salary
      FROM Sales.Employees
      WHERE Gender = 'M'
  );

/* ==============================================================================
   CORRELATED SUBQUERY
===============================================================================*/

/* TASK 10:
   Show all customer details and the total orders for each customer using a correlated subquery.
*/
SELECT
    *,
    (SELECT COUNT(*)
     FROM Sales.Orders o
     WHERE o.CustomerID = c.CustomerID) AS TotalSales
FROM Sales.Customers AS c;


/* ==============================================================================
   SUBQUERY | EXISTS OPERATOR
===============================================================================*/

/* TASK 11:
   Show the details of orders made by customers in Germany.
*/
SELECT
    *
FROM Sales.Orders AS o
WHERE EXISTS (
    SELECT 1
    FROM Sales.Customers AS c
    WHERE Country = 'Germany'
      AND o.CustomerID = c.CustomerID
);

/* TASK 12:
   Show the details of orders made by customers not in Germany.
*/
SELECT
    *
FROM Sales.Orders AS o
WHERE NOT EXISTS (
    SELECT 1
    FROM Sales.Customers AS c
    WHERE Country = 'Germany'
      AND o.CustomerID = c.CustomerID
);


/* ==============================================================================
   SQL Common Table Expressions (CTEs)
-------------------------------------------------------------------------------
   This script demonstrates the use of Common Table Expressions (CTEs) in SQL Server.
   It includes examples of non-recursive CTEs for data aggregation and segmentation,
   as well as recursive CTEs for generating sequences and building hierarchical data.

   Table of Contents:
     1. NON-RECURSIVE CTE
     2. RECURSIVE CTE | GENERATE SEQUENCE
     3. RECURSIVE CTE | BUILD HIERARCHY
===============================================================================

/* ==============================================================================
   NON-RECURSIVE CTE
===============================================================================*/

*/
SELECT *
FROM Sales.Orders
/* 
-- Step1: Find the total Sales Per Customer (Standalone CTE)
*/
;WITH CTE_TotalSalesPC AS(
    SELECT
    CustomerID,
    SUM(Sales)  AS TotalSales  -- OVER(PARTITION BY CustomerID) AS TotalSalesPerC
    FROM Sales.Orders
    GROUP BY CustomerID
),
-- multiple standealone cte
-- step 2: find the last order date for each customer
 CTE_LastOrder AS 
(
    SELECT 
        CustomerID,
        MAX(OrderDate) AS LastOrder
    FROM Sales.Orders
    GROUP BY CustomerID
)
-- Nasted CTE
-- step 3: Rank Customers based on Total Sales Per Customer
, CTE_CustomerRank AS 
(
SELECT
CustomerID,
TotalSales,
RANK() OVER(ORDER BY TotalSales DESC ) AS CustomerRank
FROM CTE_TotalSalesPC
)

-- step 4: segment customers based on their total sales (nasted cte)
, CTE_CustomerSegment AS 
(
SELECT
CustomerID,
CASE WHEN TotalSales > 100 THEN 'High'
     WHEN TotalSales > 70 THEN 'Medium'
     ELSE 'Low'
END CustomerSegments
FROM CTE_TotalSalesPC
)

-- main quary with join 
SELECT
c.CustomerID,
c.FirstName,
c.LastName,
cts.TotalSales,
clo.LastOrder,
ccr.CustomerRank,
ccs.CustomerSegments
FROM Sales.Customers c
LEFT JOIN CTE_TotalSalesPC cts
ON cts.CustomerID = c.CustomerID
LEFT JOIN CTE_LastOrder clo
ON clo.CustomerID = c.CustomerID
LEFT JOIN  CTE_CustomerRank ccr
ON ccr.CustomerID= c.CustomerID
LEFT JOIN CTE_CustomerSegment ccs
ON ccs.CustomerID= c.CustomerID

------------------------------
--> CTE Recursive
------------------------------
-- task : Generate a Sequence of Numbers from 1 to 20 
WITH Series AS (
    -- Anchor query
    SELECT 
    1 AS MyNumber
    UNION ALL 
    -- Recursive Query
    SELECT 
    MyNumber + 1
    FROM Series
    WHERE MyNumber < 20
)
-- Main Query
SELECT *
FROM Series

-- task : Show the employee hierarchy by displaying each employee's level within the organization
WITH CTE_Emp_Hierarchy AS (
    -- Anchor: المدير الكبير
    SELECT
        EmployeeID,
        FirstName,
        ManagerID,
        1 AS Level 
    FROM Sales.Employees
    WHERE ManagerID IS NULL 

    UNION ALL

    -- Recursive: باقي الموظفين
    SELECT
        e.EmployeeID,
        e.FirstName,
        e.ManagerID,
        ceh.Level + 1
    FROM Sales.Employees AS e
    INNER JOIN CTE_Emp_Hierarchy ceh
        ON e.ManagerID = ceh.EmployeeID
)
SELECT 
*
FROM CTE_Emp_Hierarchy;