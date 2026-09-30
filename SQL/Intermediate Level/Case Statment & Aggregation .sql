----- CASE STATEMENT -----
-- Evaluates a list of conditions and rerurns a value when the first conditions is met

/* TASK : Generate a report showing the total sales for each ctegory :
       - high : if sales higher than 50
       - medium : if the sales between 20 and 50
       - Low : if the sales equal or lower than 20 */
SELECT 
Category,
SUM(Sales) AS TotalSales
From (
    SELECT
    OrderID,
    Sales,
    CASE
    
        WHEN Sales > 50 THEN 'HIGH'
        WHEN Sales > 20 THEN 'MEDIUM'
        ELSE 'LOW'
    END Category
    FROM Sales.Orders
)t
GROUP BY Category
ORDER BY TotalSales DESC

-- TASK : retrive employee details with gender displayed as full text
SELECT
EmployeeID,
Gender,
CASE 
    WHEN Gender = 'M' THEN 'Male'
    WHEN Gender = 'F' THEN 'Female'
    ELSE 'Not Available'
    
END GenderFullText
FROM Sales.Employees

-- TASK : Retrieve customer details with abbreciated country code 
SELECT 
    CustomerID,
    Country,
    CASE 
        WHEN Country='Germany' THEN 'DE'
        WHEN Country='USA' THEN 'US'
        ELSE 'Country not exist'
    END AbbCountry,

    -- just anoter form to summaries
    CASE Country
        WHEN 'Germany' THEN 'DE'
        WHEN 'USA' THEN 'US'
        ELSE 'Country not exist'
    END AbbCountry2
FROM Sales.Customers
SELECT DISTINCT Country ---> so important function to retrive only the types of the coloum
From Sales.Customers

-- Hadiling nulls using case--
-- TASK : Find the average score of customers and treat nulls as o and additional provide details such CustomerID & LastName treat nulls as 0
SELECT
CustomerID,
LastName,
-- COALESCE(Score,0)
AVG(Score) Over() AvgScore,
AVG(
CASE 
    WHEN Score IS NULL THEN 0
    ELSE Score
END) over() AvgCustomerClean
FROM Sales.Customers

-- CONDITIONAL AGGREGATION --
---> Apply aggregate functions only on subsets of data that fulfill certain conditions 

-- TASK : count how many times each customer has made an order with sales greater than 30
SELECT 
    CustomerID,
    Sales,
    SUM(
    CASE 
        WHEN Sales > 30 THEN 1
        ELSE 0
    END ) TotalOrders,
    COUNT(*) TOTALORDERS
FROM Sales.Orders
GROUP BY CustomerID

-- DATA AGGREGATION --

-- TASK :  Find the total number of orders
SELECT 
COUNT(*) AS TotalNr
FROM orders

-- TASK : find the total sales for all orders
SELECT 
-- customer_id
COUNT(*) AS totalOrders,
SUM(Sales) AS totalNumber,
AVG(Sales) AS AvgSales,
MAX(Sales) AS HighestSales,
MIN(Sales) AS LowestSales

FROM Orders
-- GROUP BY Customer_id