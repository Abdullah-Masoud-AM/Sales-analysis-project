use PRO
select * from [fact sales cleaned]
SELECT *FROM DBO.[fact sales cleaned]
SELECT* FROM DBO.[customer cleaned] 
select * from dbo.[product cleaned]
select * from dbo.[subcategory cleaned]


                       -- Top 10 customer by Total amount--

SELECT  Top(10) c.CustomerID ,c.Name, format(sum (Totalamount),'N2') as 'total amount'
from dbo.[fact sales cleaned] fa 
INNER join dbo.[customer cleaned] c 
on fa.CustomerID = c.CustomerID
group by c.CustomerID,c.Name
order by sum (Totalamount) desc

------------------------------------------------------------------------- 


                           -- (Total)Top 10 sold products --

select Top(10) p.ProductID,ProductName,format(sum(TotalAmount),'N2') as 'total amount'
from dbo.[fact sales cleaned] fa
inner join dbo.[product cleaned] p
on p.ProductID = fa.ProductID
group by ProductName,p.ProductID
order by sum(TotalAmount) desc

-------------------------------------------------------------------------

                               --(AVG)Top 10 sold products--

select Top(10) p.ProductID,ProductName,format(AVG(TotalAmount),'N2') as 'AVG amount'
from dbo.[fact sales cleaned] fa
inner join dbo.[product cleaned] p
on p.ProductID = fa.ProductID
group by ProductName,p.ProductID
order by AVG(TotalAmount) desc

-------------------------------------------------------------------------

                       -- Top 10 customer by Age >35--

SELECT  Top(10) c.CustomerID ,c.Age, format(sum (Totalamount),'N2') as 'total amount'
from dbo.[fact sales cleaned] fa 
INNER join dbo.[customer cleaned] c 
on fa.CustomerID = c.CustomerID
where c.age >35
group by c.CustomerID,c.Age
order by sum (Totalamount) desc

-------------------------------------------------------------------------

                       -- Top 10 customer by Age <35--

SELECT  Top(10) c.CustomerID ,c.Age, format(sum (Totalamount),'N2') as 'total amount'
from dbo.[fact sales cleaned] fa 
INNER join dbo.[customer cleaned] c 
on fa.CustomerID = c.CustomerID
where c.age <35
group by c.CustomerID,c.Age
order by sum (Totalamount) desc

-------------------------------------------------------------------------

                                      -- Top 10 sold products --

select Top(10) s.SubCategoryID,s.SubCategoryName,format(sum(TotalAmount),'N2') as 'total amount'
from dbo.[fact sales cleaned] fa
inner join dbo.[product cleaned] p
on p.ProductID = fa.ProductID
inner join dbo.[subcategory cleaned] s 
on p.SubCategoryID = s.SubCategoryID
group by s.SubCategoryID , s.SubCategoryName
order by format(sum(TotalAmount),'N2') desc

-------------------------------------------------------------------------
                        --Average Order Value (AOV)--
SELECT 
    c.CustomerID,
    c.Name,
    format(AVG(fs.TotalAmount),'N2') AS Avg_Order_Value
FROM [fact sales cleaned] fs
JOIN [customer cleaned] c ON fs.CustomerID = c.CustomerID
GROUP BY c.CustomerID, c.Name
ORDER BY Avg_Order_Value DESC
--------------------------------------------------------------------------------------------------------------------
                         --(Repeat Customers) Percentage of customers who purchased more than once--
SELECT 
    COUNT(DISTINCT CASE WHEN Purchase_Count > 1 THEN CustomerID END) * 100.0 / COUNT(DISTINCT CustomerID) AS Repeat_Customer_Rate
FROM (
    SELECT CustomerID, COUNT(DISTINCT InvoiceNo) AS Purchase_Count
    FROM [fact sales cleaned]
    GROUP BY CustomerID
) t; 
--------------------------------------------------------------------------------------------------------------------
                     --Sales per Age Group--
SELECT 
    CASE 
        WHEN c.Age < 25 THEN 'Under 25'
        WHEN c.Age BETWEEN 25 AND 40 THEN '25-40'
        WHEN c.Age BETWEEN 41 AND 60 THEN '41-60'
        ELSE '60+'
    END AS AgeGroup,
    format(SUM(fs.TotalAmount),'N2') AS Total_Sales
FROM [fact sales cleaned] fs
JOIN [customer cleaned] c ON fs.CustomerID = c.CustomerID
GROUP BY CASE 
        WHEN c.Age < 25 THEN 'Under 25'
        WHEN c.Age BETWEEN 25 AND 40 THEN '25-40'
        WHEN c.Age BETWEEN 41 AND 60 THEN '41-60'
        ELSE '60+'
    END
ORDER BY Total_Sales DESC
---------------------------------------------------------------------------------------------------------------------------
                                -- Top Locations--
SELECT 
    l.City,
    format(SUM(fs.TotalAmount),'N2') AS Total_Sales
FROM [fact sales cleaned] fs
JOIN [customer cleaned] c ON fs.CustomerID = c.CustomerID
JOIN [location cleaned] l ON c.LocationID = l.LocationID
GROUP BY l.City
ORDER BY Total_Sales DESC
------------------------------------------------------------------------------------------
                        --Do 20% of customers contribute 80% of revenue?--
WITH CustomerSales AS (
    SELECT 
        c.CustomerID,
        c.Name,
       SUM(fs.TotalAmount) AS TotalSales
    FROM [fact sales cleaned] fs
    JOIN [customer cleaned] c ON fs.CustomerID = c.CustomerID
    GROUP BY c.CustomerID, c.Name
),
Ranked AS (
    SELECT *,
       SUM(TotalSales) OVER (ORDER BY TotalSales DESC) * 1.0 / SUM(TotalSales) OVER () AS CumShare
    FROM CustomerSales
)
SELECT *
FROM Ranked
WHERE CumShare <= 0.8
---------------------------------------------------------------------------------------------------------------
                             --Segment customers by spending size (VIP, Medium, Low Value)--
SELECT top(10)
    c.CustomerID,
    c.Name,
    SUM(fs.TotalAmount) AS TotalSpent,
    CASE 
        WHEN SUM(fs.TotalAmount) >= 5000 THEN 'VIP'
        WHEN SUM(fs.TotalAmount) BETWEEN 1000 AND 4999 THEN 'Medium'
        ELSE 'Low Value'
    END AS CustomerTier
FROM [fact sales cleaned] fs
JOIN [customer cleaned] c ON fs.CustomerID = c.CustomerID
GROUP BY c.CustomerID, c.Name
ORDER BY TotalSpent DESC
-----------------------------------------------------------------------------------------------------------------
                              --(Price Effect) _ Does the cheapest one sell more?--
SELECT 
    fs.UnitPrice,
    SUM(fs.Quantity) AS Total_Quantity
FROM [fact sales cleaned] fs
GROUP BY fs.UnitPrice
ORDER BY fs.UnitPrice
---------------------------------------------------------------------------------------------------
                                -- Customer Lifetime Value (CLV)---
SELECT 
    c.CustomerID,
    c.Name,
    format(SUM(fs.TotalAmount),'N2') AS LifetimeValue
FROM [fact sales cleaned] fs
JOIN [customer cleaned] c ON fs.CustomerID = c.CustomerID
GROUP BY c.CustomerID, c.Name
ORDER BY LifetimeValue DESC









