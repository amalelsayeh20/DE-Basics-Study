
/* ==============================================================================
   SQL Window Functions
-------------------------------------------------------------------------------
   SQL window functions enable advanced calculations across sets of rows 
   related to the current row without resorting to complex subqueries or joins.
   This script demonstrates the fundamentals and key clauses of window functions,
   including the OVER, PARTITION, ORDER, and FRAME clauses, as well as common rules 
   and a GROUP BY use case.


=================================================================================
*/

/* ==============================================================================
   SQL WINDOW FUNCTIONS | BASICS
===============================================================================*/

/* TASK 1: 
   Calculate the Total Sales Across All Orders 
*/
use SalesDB
SELECT
    SUM(Sales) AS Total_Sales
FROM Sales.Orders;

/* TASK 2: 
   Calculate the Total Sales for Each Product 
*/
SELECT 
    ProductID,
    SUM(Sales) AS Total_Sales
FROM Sales.Orders 
GROUP BY ProductID;

/* ==============================================================================
   SQL WINDOW FUNCTIONS | OVER CLAUSE
===============================================================================*/

/* TASK 3: 
   Find the total sales across all orders,
   additionally providing details such as OrderID and OrderDate 
*/
SELECT
    OrderID,
    OrderDate,
    ProductID,
    Sales,
    SUM(Sales) OVER () AS Total_Sales
FROM Sales.Orders;

/* ==============================================================================
   SQL WINDOW FUNCTIONS | PARTITION CLAUSE
===============================================================================*/

/* TASK 4: 
   Find the total sales across all orders and for each product,
   additionally providing details such as OrderID and OrderDate 
*/
SELECT
    OrderID,
    OrderDate,
    ProductID,
    Sales,
    SUM(Sales) OVER () AS Total_Sales,
    SUM(Sales) OVER (PARTITION BY ProductID) AS Sales_By_Product
FROM Sales.Orders;

/* TASK 5: 
   Find the total sales across all orders, for each product,
   and for each combination of product and order status,
   additionally providing details such as OrderID and OrderDate 
*/
SELECT
    OrderID,
    OrderDate,
    ProductID,
    OrderStatus,
    Sales,
    SUM(Sales) OVER () AS Total_Sales,
    SUM(Sales) OVER (PARTITION BY ProductID) AS Sales_By_Product,
    SUM(Sales) OVER (PARTITION BY ProductID, OrderStatus) AS Sales_By_Product_Status
FROM Sales.Orders;

/* ==============================================================================
   SQL WINDOW FUNCTIONS | ORDER CLAUSE
===============================================================================*/

/* TASK 6: 
   Rank each order by Sales from highest to lowest */
SELECT
    OrderID,
    OrderDate,
    Sales,
    RANK() OVER (ORDER BY Sales DESC) AS Rank_Sales
FROM Sales.Orders;

/* ==============================================================================
   SQL WINDOW FUNCTIONS | FRAME CLAUSE
===============================================================================*/

/* TASK 7: 
   Calculate Total Sales by Order Status for current and next two orders 
*/
SELECT
    OrderID,
    OrderDate,
    ProductID,
    OrderStatus,
    Sales,
    SUM(Sales) OVER (
        PARTITION BY OrderStatus 
        ORDER BY OrderDate 
        ROWS BETWEEN CURRENT ROW AND 2 FOLLOWING
    ) AS Total_Sales
FROM Sales.Orders;

/* TASK 8: 
   Calculate Total Sales by Order Status for current and previous two orders 
*/
SELECT
    OrderID,
    OrderDate,
    ProductID,
    OrderStatus,
    Sales,
    SUM(Sales) OVER (
        PARTITION BY OrderStatus 
        ORDER BY OrderDate 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS Total_Sales
FROM Sales.Orders;

/* TASK 9: 
   Calculate Total Sales by Order Status from previous two orders only 
*/
SELECT
    OrderID,
    OrderDate,
    ProductID,
    OrderStatus,
    Sales,
    SUM(Sales) OVER (
        PARTITION BY OrderStatus 
        ORDER BY OrderDate 
        ROWS 2 PRECEDING
    ) AS Total_Sales
FROM Sales.Orders;

/* TASK 10: 
   Calculate cumulative Total Sales by Order Status up to the current order 
*/
SELECT
    OrderID,
    OrderDate,
    ProductID,
    OrderStatus,
    Sales,
    SUM(Sales) OVER (
        PARTITION BY OrderStatus 
        ORDER BY OrderDate 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS Total_Sales
FROM Sales.Orders;

/* TASK 11: 
   Calculate cumulative Total Sales by Order Status from the start to the current row 
*/
SELECT
    OrderID,
    OrderDate,
    ProductID,
    OrderStatus,
    Sales,
    SUM(Sales) OVER (
        PARTITION BY OrderStatus 
        ORDER BY OrderDate 
        ROWS UNBOUNDED PRECEDING
    ) AS Total_Sales
FROM Sales.Orders;

/* ==============================================================================
   SQL WINDOW FUNCTIONS | RULES
===============================================================================*/

/* RULE 1: 
   Window functions can only be used in SELECT or ORDER BY clauses 
*/
SELECT
    OrderID,
    OrderDate,
    ProductID,
    OrderStatus,
    Sales,
    SUM(Sales) OVER (PARTITION BY OrderStatus) AS Total_Sales
FROM Sales.Orders
WHERE SUM(Sales) OVER (PARTITION BY OrderStatus) > 100;  -- Invalid: window function in WHERE clause

/* RULE 2: 
   Window functions cannot be nested 
*/
SELECT
    OrderID,
    OrderDate,
    ProductID,
    OrderStatus,
    Sales,
    SUM(SUM(Sales) OVER (PARTITION BY OrderStatus)) OVER (PARTITION BY OrderStatus) AS Total_Sales  -- Invalid nesting
FROM Sales.Orders;

/* ==============================================================================
   SQL WINDOW FUNCTIONS | GROUP BY
===============================================================================*/

/* TASK 12: 
   Rank customers by their total sales 
*/
SELECT
    CustomerID,
    SUM(Sales) AS Total_Sales,
    RANK() OVER (ORDER BY SUM(Sales) DESC) AS Rank_Customers
FROM Sales.Orders
GROUP BY CustomerID;

-- TASK : Find the total number of customers providing all customers details

SELECT
*,
COUNT(*) OVER() Tot
FROM Sales.Customers

-- TASK : Find the total number of scores for customers
--> using for data qultiy check : detecting number of nulls by comparing to total number of rows
SELECT
*,
COUNT(*) OVER () TotalCustomers,
COUNT(Score) OVER () TotalScores
FROM Sales.Customers 

-- TASK : check whether the table 'orders' contains any duplicate rows
-- spichally to check if the column can be primary key or not --> returns 1
-- check NULLS AND Dublicated

SELECT
OrderID,
COUNT(*) OVER (PARTITION BY OrderID ) CheckPK
from Sales.Orders 

-- TASK : find the total sales across all orders
-- TASK : Find the total sales for each prodcut 
SELECT
OrderID,
OrderDate,
Sales,
ProductID,
SUM(Sales) OVER() TotalSales,
SUM(Sales) OVER(PARTITION BY ProductID) totalSalesPrduct 
FROM Sales.Orders

SELECT *
FROM Sales.Orders

-- TASK:find the percentage contribution of each products sales to the total sales
SELECT
OrderID,
Sales,
ProductID,
SUM(Sales) OVER()TotalSales,
ROUND (CAST (Sales AS Float)/ SUM(Sales) OVER () * 100,2) PercentgeTotal
FROM Sales.Orders

-- TASK : Find the average sales across all orders
-- and find the average sales for each product
-- additionally provide details such order id , order date

SELECT
OrderID,
Sales,
ProductID,
AVG(Sales) OVER () AS AvgSales,
AVG(Sales) OVER( PARTITION BY ProductID ) avgByProduct
FROM Sales.Orders

-- TASK : Find the average scores of customers 
-- Additionally provide details such customerID and LastName
SELECT 
CustomerID,
LastName,
Score,
AVG(COALESCE(Score,0)) OVER () AS avgScore --HANDLING NULLS
FROM Sales.Customers

-- Find all orders where sales are higher than the average sales across all orders
-- we can not using where function with window function due to sort of logic
-- we have two different wayes the same :

-- (Subquery)
SELECT
*
FROM(
    SELECT
        OrderID,
        ProductID,
        Sales,
        AVG(Sales) OVER() AS AvgSales
        FROM Sales.Orders
)t
WHERE Sales > AvgSales

-- CTE(Common Table Expression ) 
WITH OrdersWithAvg AS (
    SELECT
        OrderID,
        ProductID,
        Sales,
        AVG(Sales) OVER() AS AvgSales
    FROM Sales.Orders
)
SELECT *
FROM OrdersWithAvg
WHERE Sales > AvgSales;

-- Find the highest and lowest sales of all orders
-- find the lowest sales for each product add provide details such order id, order date
-- find the deviation of each sales from min and max sales
SELECT
OrderID,
Sales,
ProductID,
MAX(Sales) OVER () MaxValue,
MIN(Sales) OVER () MinValue,
MIN(Sales) OVER(PARTITION BY ProductID) MINSalesByProduct,
Sales - MIN( Sales) OVER() DeciationFromMin
FROM Sales.Orders

-- show the employees with the highest salaries
SELECT
*
FROM (
    SELECT*,
    MAX(Salary) OVER() HighestSalary
    FROM Sales.Employees
)t
WHERE Salary = HighestSalary

-- TASK : Calcuate the moving average of sales for each product over time
SELECT            -- running total
    OrderID,
    ProductID,
    Sales,
    OrderDate,
    AVG(Sales) OVER (PARTITION BY ProductID
        ORDER BY OrderDate) AvgAllProducts 
FROM Sales.Orders

-- TASK : Calculate the moving average of sales for each product over time , including only the next ordeer
SELECT            
    OrderID,
    ProductID,
    Sales,
    OrderDate,
    AVG(Sales) OVER (PARTITION BY ProductID
        ORDER BY OrderDate ) AvgRunningTotal, -- running total
    
    AVG(Sales) OVER (PARTITION BY ProductID
        ORDER BY OrderDate     --rolling Total
        ROWS BETWEEN CURRENT ROW AND 1 FOLLOWING) AvgRollingTotal
FROM Sales.Orders


-- ==============================
        -- Rank window function
-- ==============================
-- ROW_NUMBER() --> Assign a unique number to each in a window
-- RANK() --> Assign a rank to each row in a window , with gaps
-- DENSE_RANK() --> Assign a rank to each row in a window , without gaps
-- CUME_DIST() --> caluclate the cumulative distributon of a value within a set of values
-- PERCENT_RANK() --> Return the percentile ranking number of a row
-- NTILE() --> divides the rows into a specifiled number of approximately equal groups 

-- task : Rank the orders based on their sales from highest to lowest
SELECT
    OrderID,
    Sales,
    ROW_NUMBER() OVER( ORDER BY Sales DESC) SalesRank_row,
    RANK() OVER (ORDER BY Sales DESC) SalesRank_Rank,
    DENSE_RANK() OVER(ORDER BY Sales DESC) SalesRank_Dense,
    NTILE(2) OVER( ORDER BY Sales DESC) TwoBucket

FROM Sales.Orders

-- TASK: find the top highest sales for each product
-- top & bottom -n analysis
SELECT*
FROM(
SELECT  
    OrderID,
    ProductID,
    Sales,
    ROW_NUMBER() OVER (PARTITION BY ProductID ORDER BY Sales DESC) RankByProduct
from Sales.Orders
)t
WHERE RankByProduct =1

--** ASSIGN UNIQUE IDS TO THE ROWS OF THE 'Order Achive'
-- set as a primary key
SELECT
ROW_NUMBER() OVER (ORDER BY OrderID , OrderDate) UniqueID,
*
FROM Sales.OrdersArchive

-- identify duplicate rows in the table 'orders archive' and return a clean result without duplicates
SELECT *FROM(
SELECT
ROW_NUMBER() OVER (PARTITION BY OrderID ORDER BY CreationTime DESC ) rn,
*
FROM Sales.OrdersArchive
)T WHERE rn>1 -- to chek bad data 

-- segmentation  by ntile
-- segment all orders into 3 categories : high , medium and low sales
SELECT *,
CASE WHEN buckets =1 then 'high'
     WHEN buckets =2 then 'medium'
     WHEN buckets =3 then 'low'
END SalesSegmentation
FROM(
SELECT
    OrderID,
    ProductID,
    Sales,
    NTILE(3) OVER(ORDER BY Sales DESC) buckets
FROM Sales.Orders
)t


-- CUME_DIST() --> Cumulative Distribution calculate the distribution of data points 
-- task :find the products that fall within the highest 40 % of price


--value function
-- LEAD() --> Return the next value of rows
-- LAG() --> Return the previous value of rows

-- TASK : Analyze the month over month performance by finding the percentage cahnge in sales
-- between the current and the previous month
SELECT
*,
current_month_sales-pre_month_sales as monthOverMonth,
ROUND(CAST((current_month_sales-pre_month_sales) AS FLOAT ) / pre_month_sales*100,1)
FROM(
SELECT 
MONTH(OrderDate) orderMonth,
SUM(Sales) current_month_sales,
LAG(SUM(Sales)) OVER( ORDER BY MONTH(OrderDate)) pre_month_sales
FROM Sales.Orders
GROUP BY MONTH(OrderDate)
)t

-- TASK : Rank customers based on average number of days between orders
-- يعنى بجيب الفرق (اللى هبا الايام اللى بين الاوردر و اللى قبله ) )
SELECT
CustomerID,
AVG(DayUntilNextOrder) avgDays,
RANK() OVER(ORDER BY COALESCE (AVG(DayUntilNextOrder),999999)) RankAvg
FROM(
SELECT 
    OrderID,
    CustomerID,
    OrderDate CurrentOrder,
    LEAD(OrderDate) OVER(PARTITION BY CustomerID ORDER BY OrderDate) NextOrder,
    DATEDIFF(DAY, OrderDate,LEAD(OrderDate) OVER(PARTITION BY CustomerID ORDER BY OrderDate) DayUntilNextOrder
FROM Sales.Orders
ORDER BY CustomerID,OrderDate
)t
GROUP BY CustomerID

-- FIRST_VALUE() --> access a value from the first row within a window
-- LAST_VALUE() --> access a value from the last row 

-- TASK : find the lowest and highest sales for each product
-- we can use MIN() MAX() also
SELECT
OrderID,
ProductID,
Sales,
FIRST_VALUE(Sales) OVER(PARTITION BY ProductID ORDER BY Sales DESC) LowestSales,  -- another sloution for just using first_value
LAST_VALUE(Sales) OVER(PARTITION BY ProductID ORDER BY Sales) HighestSales
FROM Sales.Orders
