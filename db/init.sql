-- Create the database
CREATE DATABASE IF NOT EXISTS online_shop;

-- Use the existing database
USE online_shop;

-- Create the States table
CREATE TABLE IF NOT EXISTS States (
    StateID INT PRIMARY KEY AUTO_INCREMENT,
    StateName VARCHAR(50) NOT NULL UNIQUE
);

-- Create the Regions table
CREATE TABLE IF NOT EXISTS Regions (
    RegionID INT PRIMARY KEY AUTO_INCREMENT,
    RegionName VARCHAR(50) NOT NULL,
    StateID INT NOT NULL,
    FOREIGN KEY (StateID) REFERENCES States(StateID)
);

-- Create the Cities table
CREATE TABLE IF NOT EXISTS Cities (
    CityID INT PRIMARY KEY AUTO_INCREMENT,
    PostalCode VARCHAR(10) NOT NULL,
    CityName VARCHAR(50) NOT NULL,
    RegionID INT,
    FOREIGN KEY (RegionID) REFERENCES Regions(RegionID)
);

-- Create the Locations table
CREATE TABLE IF NOT EXISTS Locations (
    LocationID VARCHAR(50) PRIMARY KEY,
    CityID INT,
    FOREIGN KEY (CityID) REFERENCES Cities(CityID)
);

-- Create the Segments table
CREATE TABLE IF NOT EXISTS Segments (
    SegmentID INT PRIMARY KEY AUTO_INCREMENT,
    SegmentName VARCHAR(50) NOT NULL UNIQUE
);

-- Create the Customers table
CREATE TABLE IF NOT EXISTS Customers (
    CustomerID VARCHAR(20) PRIMARY KEY,
    CustomerName VARCHAR(100) NOT NULL,
    SegmentID INT,
    FOREIGN KEY (SegmentID) REFERENCES Segments(SegmentID)
);

-- Create the Categories table
CREATE TABLE IF NOT EXISTS Categories (
    CategoryID INT PRIMARY KEY AUTO_INCREMENT,
    CategoryName VARCHAR(50) NOT NULL UNIQUE
);

-- Create the SubCategories table
CREATE TABLE IF NOT EXISTS SubCategories (
    SubCategoryID INT PRIMARY KEY AUTO_INCREMENT,
    SubCategoryName VARCHAR(50) NOT NULL,
    CategoryID INT,
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);

-- Create the Products table
CREATE TABLE IF NOT EXISTS Products (
    ProductID VARCHAR(20) PRIMARY KEY,
    ProductName VARCHAR(255) NOT NULL,
    SubCategoryID INT,
    FOREIGN KEY (SubCategoryID) REFERENCES SubCategories(SubCategoryID)
);

-- Create the Teams table
CREATE TABLE IF NOT EXISTS Teams (
    TeamID INT PRIMARY KEY AUTO_INCREMENT,
    TeamName VARCHAR(50) NOT NULL UNIQUE,
    ManagerID INT
);

-- Create the Sales table
CREATE TABLE IF NOT EXISTS Sales (
    SaleID INT PRIMARY KEY AUTO_INCREMENT,
    SaleName VARCHAR(100) NOT NULL,
    TeamID INT,
    FOREIGN KEY (TeamID) REFERENCES Teams(TeamID)
);

-- Add foreign key to Teams table after Sales table is created
ALTER TABLE Teams
ADD CONSTRAINT FK_TeamManager
FOREIGN KEY (ManagerID) REFERENCES Sales(SaleID);

-- Create the Orders table
CREATE TABLE IF NOT EXISTS Orders (
    OrderID VARCHAR(20) PRIMARY KEY,
    OrderDate DATE,
    ShipDate DATE,
    ShipMode VARCHAR(20) NOT NULL,
    Sales DECIMAL(10, 2),
    Quantity INT,
    Discount DECIMAL(4, 2),
    Profit DECIMAL(10, 2),
    SaleID INT,
    LocationID VARCHAR(50),
    CustomerID VARCHAR(20),
    ProductID VARCHAR(20),
    FOREIGN KEY (SaleID) REFERENCES Sales(SaleID),
    FOREIGN KEY (LocationID) REFERENCES Locations(LocationID),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- Create a temporary table to match the CSV structure
CREATE TEMPORARY TABLE temp_csv_import (
    order_id VARCHAR(50),
    order_date DATE,
    ship_date DATE,
    ship_mode VARCHAR(50),
    customer_id VARCHAR(50),
    sales_rep VARCHAR(100),
    location_id VARCHAR(50),
    product_id VARCHAR(50),
    sales DECIMAL(10, 2),
    quantity INT,
    discount DECIMAL(4, 2),
    profit DECIMAL(10, 2),
    customer_name VARCHAR(100),
    segment VARCHAR(50),
    product_name VARCHAR(200),
    category VARCHAR(50),
    sub_category VARCHAR(50),
    sales_team VARCHAR(50),
    sales_team_manager VARCHAR(100),
    city VARCHAR(50),
    state VARCHAR(50),
    postal_code VARCHAR(20),
    region VARCHAR(50)
);

-- Load data from CSV file into the temporary table
LOAD DATA INFILE '/var/lib/mysql-files/preprocessed_output.csv'
INTO TABLE temp_csv_import
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- Insert into States table
INSERT IGNORE INTO States (StateName)
SELECT DISTINCT state FROM temp_csv_import WHERE state IS NOT NULL AND state != '';

-- Insert into Regions table
INSERT IGNORE INTO Regions (RegionName, StateID)
SELECT DISTINCT t.region, s.StateID
FROM temp_csv_import t
JOIN States s ON t.state = s.StateName
WHERE t.region IS NOT NULL AND t.region != '';

-- Insert into Cities table
INSERT IGNORE INTO Cities (PostalCode, CityName, RegionID)
SELECT DISTINCT t.postal_code, t.city, r.RegionID
FROM temp_csv_import t
JOIN Regions r ON t.region = r.RegionName
WHERE t.postal_code IS NOT NULL AND t.city IS NOT NULL;

-- Insert into Locations table
INSERT IGNORE INTO Locations (LocationID, CityID)
SELECT DISTINCT t.location_id, c.CityID
FROM temp_csv_import t
JOIN Cities c ON t.city = c.CityName AND t.postal_code = c.PostalCode
WHERE t.location_id IS NOT NULL;

-- Insert into Segments table
INSERT IGNORE INTO Segments (SegmentName)
SELECT DISTINCT segment FROM temp_csv_import WHERE segment IS NOT NULL AND segment != '';

-- Insert into Customers table
INSERT IGNORE INTO Customers (CustomerID, CustomerName, SegmentID)
SELECT DISTINCT t.customer_id, t.customer_name, s.SegmentID
FROM temp_csv_import t
JOIN Segments s ON t.segment = s.SegmentName
WHERE t.customer_id IS NOT NULL AND t.customer_name IS NOT NULL;

-- Insert into Categories table
INSERT IGNORE INTO Categories (CategoryName)
SELECT DISTINCT category FROM temp_csv_import WHERE category IS NOT NULL AND category != '';

-- Insert into SubCategories table
INSERT IGNORE INTO SubCategories (SubCategoryName, CategoryID)
SELECT DISTINCT t.sub_category, c.CategoryID
FROM temp_csv_import t
JOIN Categories c ON t.category = c.CategoryName
WHERE t.sub_category IS NOT NULL AND t.sub_category != '';

-- Insert into Products table
INSERT IGNORE INTO Products (ProductID, ProductName, SubCategoryID)
SELECT DISTINCT t.product_id, t.product_name, sc.SubCategoryID
FROM temp_csv_import t
JOIN SubCategories sc ON t.sub_category = sc.SubCategoryName
WHERE t.product_id IS NOT NULL AND t.product_name IS NOT NULL;

-- Insert into Teams table
INSERT IGNORE INTO Teams (TeamName)
SELECT DISTINCT sales_team FROM temp_csv_import WHERE sales_team IS NOT NULL AND sales_team != '';

-- Insert into Sales table
INSERT IGNORE INTO Sales (SaleName, TeamID)
SELECT DISTINCT t.sales_rep, tm.TeamID
FROM temp_csv_import t
JOIN Teams tm ON t.sales_team = tm.TeamName
WHERE t.sales_rep IS NOT NULL AND t.sales_rep != '';

-- Update Teams table with ManagerID
UPDATE Teams t
JOIN (
    SELECT DISTINCT sales_team, sales_team_manager
    FROM temp_csv_import
    WHERE sales_team IS NOT NULL AND sales_team != ''
      AND sales_team_manager IS NOT NULL AND sales_team_manager != ''
) m ON t.TeamName = m.sales_team
JOIN Sales s ON m.sales_team_manager = s.SaleName
SET t.ManagerID = s.SaleID;

-- Insert into Orders table
INSERT IGNORE INTO Orders (OrderID, OrderDate, ShipDate, ShipMode, Sales, Quantity, Discount, Profit, SaleID, LocationID, CustomerID, ProductID)
SELECT DISTINCT
    t.order_id,
    t.order_date,
    t.ship_date,
    t.ship_mode,
    t.sales,
    t.quantity,
    t.discount,
    t.profit,
    s.SaleID,
    l.LocationID,
    c.CustomerID,
    p.ProductID
FROM temp_csv_import t
JOIN Sales s ON t.sales_rep = s.SaleName
JOIN Locations l ON t.location_id = l.LocationID
JOIN Customers c ON t.customer_id = c.CustomerID
JOIN Products p ON t.product_id = p.ProductID
WHERE t.order_id IS NOT NULL;


-- Clean up
DROP TEMPORARY TABLE temp_csv_import;

-- Verify data
SELECT 'States' AS TableName, COUNT(*) AS RowCount FROM States
UNION ALL
SELECT 'Regions', COUNT(*) FROM Regions
UNION ALL
SELECT 'Cities', COUNT(*) FROM Cities
UNION ALL
SELECT 'Locations', COUNT(*) FROM Locations
UNION ALL
SELECT 'Segments', COUNT(*) FROM Segments
UNION ALL
SELECT 'Customers', COUNT(*) FROM Customers
UNION ALL
SELECT 'Categories', COUNT(*) FROM Categories
UNION ALL
SELECT 'SubCategories', COUNT(*) FROM SubCategories
UNION ALL
SELECT 'Products', COUNT(*) FROM Products
UNION ALL
SELECT 'Teams', COUNT(*) FROM Teams
UNION ALL
SELECT 'Sales', COUNT(*) FROM Sales
UNION ALL
SELECT 'Orders', COUNT(*) FROM Orders;