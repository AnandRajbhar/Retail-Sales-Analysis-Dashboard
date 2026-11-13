USE Arrowstack_Sales_Analytics;
GO

-- Sales KPI Analysis

SELECT
    SUM(CAST(Total_Amount AS DECIMAL(18,2)))
        AS Total_Sales,

    COUNT(DISTINCT Order_ID)
        AS Total_Orders,

    CAST(
        SUM(CAST(Total_Amount AS DECIMAL(18,2)))
        / NULLIF(COUNT(DISTINCT Order_ID), 0)
        AS DECIMAL(18,2)
    ) AS Average_Order_Value

FROM dbo.Final_Sales_Data;

--Monthly Sales Analysis

SELECT
    YEAR(Order_Date) AS Sales_Year,
    MONTH(Order_Date) AS Month_Number,
    DATENAME(MONTH, Order_Date) AS Month_Name,
    SUM(CAST(Total_Amount AS DECIMAL(18,2)))
        AS Monthly_Sales,
    COUNT(DISTINCT Order_ID) AS Total_Orders
FROM dbo.Final_Sales_Data
GROUP BY
    YEAR(Order_Date),
    MONTH(Order_Date),
    DATENAME(MONTH, Order_Date)
ORDER BY
    Sales_Year,
    Month_Number;

    -- Month-over-Month (MoM) Growth

WITH MonthlySales AS
(
    SELECT
        YEAR(Order_Date) AS Sales_Year,
        MONTH(Order_Date) AS Month_Number,
        DATEFROMPARTS(
            YEAR(Order_Date),
            MONTH(Order_Date),
            1
        ) AS Sales_Month,

        SUM(CAST(Total_Amount AS DECIMAL(18,2)))
            AS Monthly_Sales

    FROM dbo.Final_Sales_Data

    GROUP BY
        YEAR(Order_Date),
        MONTH(Order_Date)
),
PreviousSales AS
(
    SELECT
        Sales_Year,
        Month_Number,
        Sales_Month,
        Monthly_Sales,

        LAG(Monthly_Sales) OVER
        (
            ORDER BY Sales_Month
        ) AS Previous_Month_Sales

    FROM MonthlySales
)
SELECT
    Sales_Year,
    Month_Number,
    DATENAME(MONTH, Sales_Month) AS Month_Name,
    Monthly_Sales,
    Previous_Month_Sales,

    Monthly_Sales - Previous_Month_Sales
        AS Sales_Growth,

    CAST(
        (Monthly_Sales - Previous_Month_Sales)
        * 100.0 / NULLIF(Previous_Month_Sales, 0)
        AS DECIMAL(10,2)
    ) AS MoM_Growth_Percentage

FROM PreviousSales
ORDER BY Sales_Month;

--Region-wise Sales Analysis

SELECT
    Region,

    SUM(CAST(Total_Amount AS DECIMAL(18,2)))
        AS Total_Sales,

    COUNT(DISTINCT Order_ID)
        AS Total_Orders,

    SUM(Quantity)
        AS Total_Quantity,

    CAST(
        SUM(CAST(Total_Amount AS DECIMAL(18,2))) * 100.0
        / NULLIF(
            SUM(SUM(CAST(Total_Amount AS DECIMAL(18,2))))
            OVER(),
            0
        )
        AS DECIMAL(10,2)
    ) AS Sales_Contribution_Percentage

FROM dbo.Final_Sales_Data

GROUP BY Region

ORDER BY Total_Sales DESC;
   
-- Category-wise Sales Results

SELECT 
    Category,

    SUM(CAST(Total_Amount AS DECIMAL(18,2)))
        AS Total_Sales,

    COUNT(DISTINCT Order_ID)
        AS Total_Orders,

    SUM(Quantity)
        AS Total_Quantity,

    CAST(
        SUM(CAST(Total_Amount AS DECIMAL(18,2))) * 100.0
        / NULLIF(
            SUM(SUM(CAST(Total_Amount AS DECIMAL(18,2))))
            OVER(),
            0
        )
        AS DECIMAL(10,2)
    ) AS Sales_Contribution_Percentage

FROM dbo.Final_Sales_Data

GROUP BY Category

ORDER BY Total_Sales DESC;

-- TOP 10 Product wise Analysis

SELECT TOP(10)
    Product, 
    SUM(CAST(Total_Amount AS DECIMAL(18,2))) AS Total_Sales,

    SUM(Quantity) AS Total_Quantity,

    COUNT(DISTINCT Order_ID) AS Total_Orders,

    CAST(
        SUM(CAST(Total_Amount AS DECIMAL(18,2))) / 
        NULLIF(COUNT(DISTINCT Order_ID), 0) AS DECIMAL(18,2)
    ) AS Average_Order_Value
from Final_Sales_Data

GROUP BY Product

ORDER BY Total_Sales DESC


-- Sales Channel Analysis

SELECT
    Sales_Channel,

    SUM(CAST(Total_Amount AS DECIMAL(18,2)))
        AS Total_Sales,

    COUNT(DISTINCT Order_ID)
        AS Total_Orders,

    SUM(Quantity)
        AS Total_Quantity,

    CAST(
        SUM(CAST(Total_Amount AS DECIMAL(18,2)))
        / NULLIF(COUNT(DISTINCT Order_ID), 0)
        AS DECIMAL(18,2)
    ) AS Average_Order_Value,

    CAST(
        SUM(CAST(Total_Amount AS DECIMAL(18,2))) * 100.0
        / NULLIF(
            SUM(SUM(CAST(Total_Amount AS DECIMAL(18,2))))
            OVER(),
            0
        )
        AS DECIMAL(10,2)
    ) AS Sales_Contribution_Percentage

FROM dbo.Final_Sales_Data

GROUP BY Sales_Channel

ORDER BY Total_Sales DESC;


-- Year-wise Sales Analysis

SELECT
    YEAR(Order_Date) AS Sales_Year,

    SUM(CAST(Total_Amount AS DECIMAL(18,2)))
        AS Total_Sales,

    COUNT(DISTINCT Order_ID)
        AS Total_Orders,

    SUM(Quantity)
        AS Total_Quantity,

    CAST(
        SUM(CAST(Total_Amount AS DECIMAL(18,2)))
        / NULLIF(COUNT(DISTINCT Order_ID), 0)
        AS DECIMAL(18,2)
    ) AS Average_Order_Value

FROM dbo.Final_Sales_Data

GROUP BY YEAR(Order_Date)

ORDER BY Sales_Year;

-- Year-over-Year (YoY) Sales Growth

WITH YearlySales AS
(
    SELECT
        YEAR(Order_Date) AS Sales_Year,
        SUM(CAST(Total_Amount AS DECIMAL(18,2)))
            AS Total_Sales
    FROM dbo.Final_Sales_Data
    GROUP BY YEAR(Order_Date)
),
PreviousSales AS
(
    SELECT
        Sales_Year,
        Total_Sales,

        LAG(Total_Sales) OVER
        (
            ORDER BY Sales_Year
        ) AS Previous_Year_Sales

    FROM YearlySales
)
SELECT
    Sales_Year,
    Total_Sales,
    Previous_Year_Sales,

    CAST(
        Total_Sales - Previous_Year_Sales
        AS DECIMAL(18,2)
    ) AS Sales_Growth,

    CAST(
        (Total_Sales - Previous_Year_Sales)
        * 100.0
        / NULLIF(Previous_Year_Sales, 0)
        AS DECIMAL(10,2)
    ) AS YoY_Growth_Percentage

FROM PreviousSales
ORDER BY Sales_Year;

-- Monthly Sales Trend

WITH MonthlySales AS
(
    SELECT
        YEAR(Order_Date) AS Sales_Year,
        MONTH(Order_Date) AS Month_Number,
        DATENAME(MONTH, Order_Date) AS Month_Name,
        SUM(CAST(Total_Amount AS DECIMAL(18,2)))
            AS Monthly_Sales
    FROM dbo.Final_Sales_Data
    GROUP BY
        YEAR(Order_Date),
        MONTH(Order_Date),
        DATENAME(MONTH, Order_Date)
),
PreviousSales AS
(
    SELECT
        *,
        LAG(Monthly_Sales) OVER
        (
            ORDER BY Sales_Year, Month_Number
        ) AS Previous_Month_Sales
    FROM MonthlySales
)
SELECT
    Sales_Year,
    Month_Number,
    Month_Name,
    Monthly_Sales,
    Previous_Month_Sales,

    CAST(
        Monthly_Sales - Previous_Month_Sales
        AS DECIMAL(18,2)
    ) AS Sales_Growth,

    CAST(
        (Monthly_Sales - Previous_Month_Sales) * 100.0
        / NULLIF(Previous_Month_Sales, 0)
        AS DECIMAL(10,2)
    ) AS MoM_Growth_Percentage

FROM PreviousSales
ORDER BY Sales_Year, Month_Number;

-- Highest Sales Months

SELECT TOP 5
    YEAR(Order_Date) AS Sales_Year,
    MONTH(Order_Date) AS Month_Number,
    DATENAME(MONTH, Order_Date) AS Month_Name,

    SUM(CAST(Total_Amount AS DECIMAL(18,2)))
        AS Monthly_Sales,

    COUNT(DISTINCT Order_ID) AS Total_Orders

FROM dbo.Final_Sales_Data

GROUP BY
    YEAR(Order_Date),
    MONTH(Order_Date),
    DATENAME(MONTH, Order_Date)

ORDER BY Monthly_Sales DESC;

--Top 10 Customers Analysis 

SELECT TOP 10
    Customer_ID,

    SUM(CAST(Total_Amount AS DECIMAL(18,2)))
        AS Total_Sales,

    COUNT(DISTINCT Order_ID)
        AS Total_Orders,

    SUM(Quantity)
        AS Total_Quantity,

    CAST(
        SUM(CAST(Total_Amount AS DECIMAL(18,2)))
        / NULLIF(COUNT(DISTINCT Order_ID), 0)
        AS DECIMAL(18,2)
    ) AS Average_Order_Value

FROM dbo.Final_Sales_Data

WHERE Customer_ID IS NOT NULL

GROUP BY Customer_ID

ORDER BY Total_Sales DESC;

-- Customer Sales Contribution %

WITH CustomerSales AS
(
    SELECT
        Customer_ID,

        SUM(CAST(Total_Amount AS DECIMAL(18,2)))
            AS Total_Sales,

        COUNT(DISTINCT Order_ID)
            AS Total_Orders

    FROM dbo.Final_Sales_Data
    WHERE Customer_ID IS NOT NULL
    GROUP BY Customer_ID
)
SELECT TOP 10
    Customer_ID,
    Total_Sales,
    Total_Orders,

    CAST(
        Total_Sales * 100.0 /
        NULLIF(
            SUM(Total_Sales) OVER(), 0
        )
        AS DECIMAL(10,2)
    ) AS Sales_Contribution_Percentage,

    RANK() OVER(
        ORDER BY Total_Sales DESC
    ) AS Customer_Rank

FROM CustomerSales
ORDER BY Total_Sales DESC;

-- Repeat vs One-Time Customers

WITH CustomerOrders AS
(
    SELECT
        Customer_ID,
        COUNT(DISTINCT Order_ID) AS Total_Orders
    FROM dbo.Final_Sales_Data
    WHERE Customer_ID IS NOT NULL
    GROUP BY Customer_ID
)
SELECT
    CASE
        WHEN Total_Orders = 1
            THEN 'One-Time Customer'
        ELSE 'Repeat Customer'
    END AS Customer_Type,

    COUNT(*) AS Total_Customers,

    CAST(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER()
        AS DECIMAL(10,2)
    ) AS Customer_Percentage

FROM CustomerOrders
GROUP BY
    CASE
        WHEN Total_Orders = 1
            THEN 'One-Time Customer'
        ELSE 'Repeat Customer'
    END;

-- Region-wise Customer Analysis

SELECT
    Region,

    COUNT(DISTINCT Customer_ID)
        AS Total_Customers,

    COUNT(DISTINCT Order_ID)
        AS Total_Orders,

    SUM(CAST(Total_Amount AS DECIMAL(18,2)))
        AS Total_Sales,

    CAST(
        SUM(CAST(Total_Amount AS DECIMAL(18,2))) * 100.0
        / NULLIF(
            SUM(SUM(CAST(Total_Amount AS DECIMAL(18,2))))
            OVER(), 0
        )
        AS DECIMAL(10,2)
    ) AS Sales_Contribution_Percentage

FROM dbo.Final_Sales_Data

WHERE Customer_ID IS NOT NULL

GROUP BY Region

ORDER BY Total_Sales DESC;

-- Sales Channel Analysis

SELECT
    Sales_Channel,

    COUNT(DISTINCT Order_ID)
        AS Total_Orders,

    SUM(Quantity)
        AS Total_Quantity,

    SUM(CAST(Total_Amount AS DECIMAL(18,2)))
        AS Total_Sales,

    CAST(
        SUM(CAST(Total_Amount AS DECIMAL(18,2))) * 100.0
        / NULLIF(
            SUM(SUM(CAST(Total_Amount AS DECIMAL(18,2))))
            OVER(), 0
        )
        AS DECIMAL(10,2)
    ) AS Sales_Contribution_Percentage

FROM dbo.Final_Sales_Data

GROUP BY Sales_Channel

ORDER BY Total_Sales DESC;

-- Category-wise Sales and Profitability Preparation

SELECT
    Category,

    SUM(CAST(Total_Amount AS DECIMAL(18,2)))
        AS Total_Sales,

    COUNT(DISTINCT Order_ID)
        AS Total_Orders,

    SUM(Quantity)
        AS Total_Quantity,

    CAST(
        SUM(CAST(Total_Amount AS DECIMAL(18,2)))
        / NULLIF(COUNT(DISTINCT Order_ID), 0)
        AS DECIMAL(18,2)
    ) AS Average_Order_Value,

    CAST(
        SUM(CAST(Total_Amount AS DECIMAL(18,2))) * 100.0
        / NULLIF(
            SUM(SUM(CAST(Total_Amount AS DECIMAL(18,2))))
            OVER(), 0
        )
        AS DECIMAL(10,2)
    ) AS Sales_Contribution_Percentage

FROM dbo.Final_Sales_Data

GROUP BY Category

ORDER BY Total_Sales DESC;

-- Product-wise Analysis

SELECT
    Product,

    SUM(CAST(Total_Amount AS DECIMAL(18,2)))
        AS Total_Sales,

    SUM(Quantity)
        AS Total_Quantity,

    COUNT(DISTINCT Order_ID)
        AS Total_Orders,

    CAST(
        SUM(CAST(Total_Amount AS DECIMAL(18,2)))
        / NULLIF(COUNT(DISTINCT Order_ID), 0)
        AS DECIMAL(18,2)
    ) AS Average_Order_Value

FROM dbo.Final_Sales_Data

GROUP BY Product

ORDER BY Total_Sales DESC;

-- Product Sales Contribution % 

SELECT
    Product,

    SUM(CAST(Total_Amount AS DECIMAL(18,2)))
        AS Total_Sales,

    CAST(
        SUM(CAST(Total_Amount AS DECIMAL(18,2))) * 100.0
        / NULLIF(
            (SELECT SUM(CAST(Total_Amount AS DECIMAL(18,2)))
             FROM dbo.Final_Sales_Data), 0
        )
        AS DECIMAL(10,2)
    ) AS Sales_Contribution_Percentage

FROM dbo.Final_Sales_Data

GROUP BY Product

ORDER BY Total_Sales DESC;

-- Region-wise Product Performance 

SELECT
    Region,
    Product,

    SUM(CAST(Total_Amount AS DECIMAL(18,2)))
        AS Total_Sales,

    SUM(Quantity)
        AS Total_Quantity,

    COUNT(DISTINCT Order_ID)
        AS Total_Orders

FROM dbo.Final_Sales_Data

GROUP BY
    Region,
    Product

ORDER BY
    Region,
    Total_Sales DESC;

    -- All Region of Top 1 Product

    WITH ProductRanking AS
(
    SELECT
        Region,
        Product,

        SUM(CAST(Total_Amount AS DECIMAL(18,2)))
            AS Total_Sales,

        ROW_NUMBER() OVER
        (
            PARTITION BY Region
            ORDER BY SUM(CAST(Total_Amount AS DECIMAL(18,2))) DESC
        ) AS Product_Rank

    FROM dbo.Final_Sales_Data

    GROUP BY Region, Product
)

SELECT
    Region,
    Product,
    Total_Sales,
    Product_Rank

FROM ProductRanking

WHERE Product_Rank = 1

ORDER BY Total_Sales DESC;

-- Top 3 Products in Each Region

WITH ProductRanking AS
(
    SELECT
        Region,
        Product,

        SUM(CAST(Total_Amount AS DECIMAL(18,2)))
            AS Total_Sales,

        ROW_NUMBER() OVER
        (
            PARTITION BY Region
            ORDER BY SUM(CAST(Total_Amount AS DECIMAL(18,2))) DESC
        ) AS Product_Rank

    FROM dbo.Final_Sales_Data

    WHERE Region <> 'Unknown'

    GROUP BY Region, Product
)

SELECT
    Region,
    Product,
    Total_Sales,
    Product_Rank

FROM ProductRanking

WHERE Product_Rank <= 3

ORDER BY Region, Product_Rank;

-- Region-wise Sales Contribution %

SELECT
    Region,

    SUM(CAST(Total_Amount AS DECIMAL(18,2)))
        AS Total_Sales,

    CAST(
        SUM(CAST(Total_Amount AS DECIMAL(18,2))) * 100.0
        /
        NULLIF(
            SUM(SUM(CAST(Total_Amount AS DECIMAL(18,2)))) OVER(),
            0
        )
        AS DECIMAL(10,2)
    ) AS Sales_Contribution_Percentage

FROM dbo.Final_Sales_Data

WHERE Region <> 'Unknown'

GROUP BY Region

ORDER BY Total_Sales DESC;

