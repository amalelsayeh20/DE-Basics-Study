-----------------SQL Function-----------------
-- single row function             -- multi-row function
/* string                             agregate function
   numeric							  window function
   data& time 
   nulls
   */
   
   ------String function -------
   -- Manipulation         -- Calculation         -- String Extraction
   /* CONCAT			      LEN                    LEFT		
	  UPPER											 RIGHT
	  LOWER											 SUBSTRING
	  TRIM
	  REPLACE
	*/
	

	-- CONCAT (but every thing in one value)
	-- task: show a list of customers first names togethers with their country in one column

	SELECT 
		first_name,
		country,
	CONCAT(first_name ,'_', country) As name_country
	FROM customers


	-- UPPER (converts all characters to uppercase)
	-- LOWER (converts all characters to lowercase)

	SELECT
		first_name,
	UPPER(first_name ) As upper_name,
	LOWER(first_name) As lower_name
	FROM customers


-- TRIM(Remove leading and Trailing Spaces)
-- task: find customers whose first name contains leadind and trailing spaces 
SELECT 
	first_name,
	 LEN(first_name) As len_name,
	 LEN(TRIM(first_name)) As len_trim_name,
	 LEN( first_name) - LEN (TRIM(fist_name)) flag
FROM customers 
--WHERE first_name != TRIM(first_name)  -- or using this : to show only the values that have a trailing spaces


-- REPLACE (replace specific character with a new character )
-- task : remove dashes (-) from a phone number
SELECT
'123-456-7890' AS phone ,
REPLACE ('123-456-7890' , '-' , '/') AS clean_phone 

-- in data : replace file Extence from txt to csv
SELECT 
'report.txt' AS old_filename ,
REPLACE ('report.txt' , '.txt' , '.csv') AS new_filename


-- calculation function (LEN) --> (counts how many charactars in value) 
-- calculate the length of each customers first name 
SELECT
first_name,
LEN(first_name) AS len_name
FROM customers


-- LEFT--> (extracts specific number of characters from the start)
-- RIGHT--> ( extracts specific number of characters from the end )

SELECT
	first_name,
	LEFT(TRIM(first_name) , 2) AS first_2_char,
	RIGHT(first_name, 2) AS last_2_char
FROM customers


--SUBSTRING --> ( extracts a part of string at a specified postion)
-- task : frist_name after removing the first character

SELECT 
	first_name,
	SUBSTRING(TRIM(first_name) ,2,LEN(first_name)) AS sub_name
FROM customers


-- numirical functions 
SELECT 
3.1415,
ROUND(3.1415 , 2) As round_2,
ROUND(3.1415 , 1) As round_1,
ROUND(1.1415 , 0) As round_0

-- ABSELUTE
SELECT
-10,
ABS(-10) AS absolute_

/* TASK 1:
   Display OrderID, CreationTime, a hard-coded date, and the current system date.
*/
SELECT
    OrderID,
    CreationTime,
    '2025-08-20' AS HardCoded,
    GETDATE() AS Today
FROM Sales.Orders;

/* ==============================================================================
   DATE PART EXTRACTIONS
   (DATETRUNC, DATENAME, DATEPART, YEAR, MONTH, DAY)
===============================================================================*/

/* TASK 2:
   Extract various parts of CreationTime using DATETRUNC, DATENAME, DATEPART,
   YEAR, MONTH, and DAY.
*/
SELECT
    OrderID,
    CreationTime,
    -- DATETRUNC Examples
    DATETRUNC(year, CreationTime) AS Year_dt,
    DATETRUNC(day, CreationTime) AS Day_dt,
    DATETRUNC(minute, CreationTime) AS Minute_dt
    FROM Sales.Orders

    -- DATENAME Examples
SELECT
    OrderID,
    CreationTime,
    DATENAME(month, CreationTime) AS Month_dn,
    DATENAME(weekday, CreationTime) AS Weekday_dn,
    DATENAME(day, CreationTime) AS Day_dn,
    DATENAME(year, CreationTime) AS Year_dn
    From Sales.Orders

    -- DATEPART Examples
SELECT
OrderID,
CreationTime,
    DATEPART(year, CreationTime) AS Year_dp,
    DATEPART(month, CreationTime) AS Month_dp,
    DATEPART(day, CreationTime) AS Day_dp,
    DATEPART(hour, CreationTime) AS Hour_dp,
    DATEPART(quarter, CreationTime) AS Quarter_dp,
    DATEPART(week, CreationTime) AS Week_dp,
    YEAR(CreationTime) AS Year,
    MONTH(CreationTime) AS Month,
    DAY(CreationTime) AS Day
FROM Sales.Orders;

/* ==============================================================================
   DATETRUNC() DATA AGGREGATION
===============================================================================*/

/* TASK 3:
   Aggregate orders by year using DATETRUNC on CreationTime.
*/
SELECT
    DATETRUNC(year, CreationTime) AS Creation,
    COUNT(*) AS OrderCount
FROM Sales.Orders
GROUP BY DATETRUNC(year, CreationTime);

/* ==============================================================================
   EOMONTH()
===============================================================================*/

/* TASK 4:
   Display OrderID, CreationTime, and the end-of-month date for CreationTime.
*/
SELECT
    OrderID,
    CreationTime,
    EOMONTH(CreationTime) AS EndOfMonth
FROM Sales.Orders;

/* ==============================================================================
   DATE PARTS | USE CASES
===============================================================================*/

/* TASK 5:
   How many orders were placed each year?
*/
SELECT 
    YEAR(OrderDate) AS OrderYear, 
    COUNT(*) AS TotalOrders
FROM Sales.Orders
GROUP BY YEAR(OrderDate);

/* TASK 6:
   How many orders were placed each month?
*/
SELECT 
    MONTH(OrderDate) AS OrderMonth, 
    COUNT(*) AS TotalOrders
FROM Sales.Orders
GROUP BY MONTH(OrderDate);

/* TASK 7:
   How many orders were placed each month (using friendly month names)?
*/
SELECT 
    DATENAME(month, OrderDate) AS OrderMonth, 
    COUNT(*) AS TotalOrders
FROM Sales.Orders
GROUP BY DATENAME(month, OrderDate);

/* TASK 8:
   Show all orders that were placed during the month of February.
*/

SELECT
*
FROM Sales.Orders
WHERE MONTH(OrderDate)= 2   -- avoid using datename for filtering data , instead use datepart(or number)


--- Data Formating---
-- (yyyy-MM-dd)   in time (HH:mm:ss)
SELECT
OrderID,
CreationTime,
FORMAT(CreationTime,'dd-MM-yyyy') USA_FORMAT
FROM Sales.Orders 

-- show creationtime using the following format:
-- Day wed jan Q1 2025 12:34:56 pm
SELECT
OrderID,
CreationTime,
'Day ' + FORMAT(CreationTime,'ddd MMM')
+'Q' + DATENAME(quarter,CreationTime)+' '+
FORMAT(CreationTime,'yyyy hh:mm:ss tt') AS CustomerFormat
FROM Sales.Orders

----- CONVERT----
SELECT
CONVERT(INT, '123') AS [String to Int CONVERT],
CONVERT(DATE , '2025-08-20') AS [String to Date CONVERT]
FROM Sales.Orders

--- cast-->Cnvert value to a specified data type -----
SELECT
CAST('123' AS INT) AS [String to int],
CAST(123 AS VARCHAR ) AS [INT to String],
CAST('2025-08-20' AS DATETIME) AS [String to Datetime],
CreationTime
From Sales.Orders

--you must known the difference between CAST-CONVERT-FORMAT

-- DATEADD --> it add month or day or year for original date --
-- task: add 3 months and 2 years and 10 days for original date
SELECT
OrderID,
OrderDate,
DATEADD(day,-10,OrderDate)AS TenDaysBefore,
DATEADD(month , 3, OrderDate) AS ThreeMonthslater,
DATEADD(year,2 , OrderDate) AS TwoYearsLater
FROM Sales.Orders

-- DAATEDIFF --> calculate the value from(end date - start date )
-- CETDATE() --> use to the current year
-- Calculate the age of employees
SELECT
EmployeeID,
BirthDate,
DATEDIFF(year,BirthDate,GETDATE()) AS AGE
FROM Sales.Employees


/* TASK 16:
   Find the average shipping duration in days for each month.
*/
SELECT 
    
   MONTH(OrderDate) AS OrderDate,
   AVG(DATEDIFF(Day,OrderDate,ShipDate)) AS avg_duration
FROM Sales.Orders
GROUP BY MONTH(OrderDate)

/* TASK 17:
   Time Gap Analysis: Find the number of days between each order and the previous order.
*/
-- LAG --> using for giving the previous date
SELECT
OrderID,
OrderDate As currentorderdate,
LAG(OrderDate) OVER(ORDER BY OrderDate) PreviousOrderDate,
DATEDIFF(DAY,LAG(OrderDate) OVER (ORDER BY OrderDate), OrderDate) AS NuOfDayes
FROM Sales.Orders



/* TASK 18:
   Validate OrderDate using ISDATE and convert valid dates.
*/

-- ISDATE --> check if a value is a date
SELECT 
ISDATE ('123') DateCheck1,
ISDATE('2025-08-20') DateCheck2,
ISDATE('20-08-2025') DateCheck3,
ISDATE('2025') DateCheck4

SELECT
    -- CAST(OrderDate),
    OrderDate,
    ISDATE(OrderDate),
    CASE WHEN ISDATE (OrderDate) = 1 THEN CAST (OrderDate AS DATE)
        ELSE '9999-01-01'
    END NewOrderDate
FROM
(   
    SELECT '2025-08-20' AS OrderDate UNION
    SELECT '2025-08-21' UNION
    SELECT '2025-08-23' UNION
    SELECT '2025-08'
)t


-------- NULL FUNCTIONS --------

-- ISNULL() --> Replaces NULL with a specified value
-- COALESCE() --> returns the first non_null value from a list (it check the values from many coloums then using the defult values)

/* find the average score of the customers */
SELECT 
    CustomerID,
    Score,
    AVG(Score) OVER () AvgScoreWnull,
    AVG(COALESCE(Score,0)) OVER() AvgScore2
From Sales.Customers
  


-- Task: display the full name of customers in single field by merging their first and last names,
-- and add 10 bonus points to each customers score.

SELECT
    FirstName,
    LastName,
    Score,
    FirstName+ ' ' + COALESCE(LastName,'') AS FullName,
    COALESCE(Score,0 ) + 10 AS ScoreWithBouns
FROM Sales.Customers

-- TASK : Sort the customers from lowest to highest scores,wirh NULLs appearing last.
SELECT
    CustomerID,
    Score,
    CASE WHEN Score IS NULL THEN 1 ELSE 0 END flag
FROM Sales.Customers
ORDER BY Score DESC;

-- NULLIF()--> Compare two expressions 
    -- returns
    -- NULL : if they are equal
    -- First Value : it they are not equall

--TASK : Find the sales price for each order by dividing sales by quantity

SELECT 
OrderID,
Sales,
Quantity,
Sales / NULLIF (Quantity,0) AS Price

-- ISNULL() --> Returns TRUE if the value is NULL, otherwise it returns False.

-- TASK : identify the customers who have no scores
SELECT
*
From Sales.Customers
WHERE Score IS NULL

-- task : list all customers who have scores
SELECT * 
FROM Sales.Customers
WHERE Score IS NOT NULL

/* left anti goin = (left join + is null )
   right anti gion = ( right join + is null) */

-- TASK : list all details from customers who have not placed any orders
SELECT 
C.*,
O.OrderID
FROM Sales.Customers C
LEFT JOIN Sales.Orders O
ON c.CustomerID=o.CustomerID
WHERE O.CustomerID IS NULL

-- IMPORTANT DEFFRENCE --
/* NULL : means nothing , unknown
   EMPTY STRING : String value has zero characters
   BLANCK SPACE : String value has one or more space characters



   