-- ================================
-- CREATE DATABASE AND USE IT
-- ================================
CREATE DATABASE IF NOT EXISTS ONLINE_INVENTORY_STORE;
USE ONLINE_INVENTORY_STORE;

-- ================================
-- DROP TABLES IN CORRECT ORDER
-- ================================
DROP TABLE IF EXISTS ProductSupplier;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Suppliers;
DROP TABLE IF EXISTS Categories;

-- ================================
-- Table: Categories
-- ================================
CREATE TABLE Categories (
    CategoryID INT AUTO_INCREMENT PRIMARY KEY,
    CategoryName VARCHAR(50) NOT NULL
);

-- ================================
-- Table: Suppliers
-- ================================
CREATE TABLE Suppliers (
    SupplierID INT AUTO_INCREMENT PRIMARY KEY,
    SupplierName VARCHAR(50) NOT NULL
);

-- ================================
-- Table: Products
-- ================================
CREATE TABLE Products (
    ProductID INT AUTO_INCREMENT PRIMARY KEY,
    ProductName VARCHAR(50) NOT NULL,
    Price DECIMAL(10,2) CHECK (Price > 0),
    QuantityInStock INT CHECK (QuantityInStock >= 0),
    CategoryID INT,
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);

-- ================================
-- Table: ProductSupplier (Many-to-Many)
-- ================================
CREATE TABLE ProductSupplier (
    ProductID INT,
    SupplierID INT,
    PRIMARY KEY (ProductID, SupplierID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID) ON DELETE CASCADE,
    FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID) ON DELETE CASCADE
);


-- ================================
-- INSERT INTO Categories
-- ================================
INSERT INTO Categories (CategoryName) VALUES
('Electronics'),
('Clothing'),
('Books');

-- ================================
-- INSERT INTO Suppliers
-- ================================
INSERT INTO Suppliers (SupplierName) VALUES
('Tech Supplier Inc.'),
('Fashion Hub'),
('Book World');

-- ================================
-- INSERT INTO Products
-- ================================
INSERT INTO Products (ProductName, Price, QuantityInStock, CategoryID) VALUES
('Laptop', 1000.00, 10, 1),
('Smartphone', 700.00, 15, 1),
('T-Shirt', 20.00, 50, 2),
('Jeans', 40.00, 30, 2),
('Novel', 15.00, 100, 3),
('Tablet', 350.00, 5, 1),
('Sweater', 60.00, 20, 2),
('Notebook', 10.00, 80, 3);

-- ================================
-- INSERT INTO ProductSupplier
-- ================================
-- (Based on existing inserted data - assumed IDs start at 1)
INSERT INTO ProductSupplier VALUES
(1, 1), -- Laptop -> Tech Supplier
(2, 1), -- Smartphone -> Tech Supplier
(3, 2), -- T-Shirt -> Fashion Hub
(4, 2), -- Jeans -> Fashion Hub
(5, 3), -- Novel -> Book World
(6, 1), -- Tablet -> Tech Supplier
(7, 2), -- Sweater -> Fashion Hub
(8, 3); -- Notebook -> Book World


-- ========================================
-- 15 MEANINGFUL QUERIES START HERE
-- ========================================

-- 1. List all products with their category names
SELECT 
    p.ProductName, 
    p.Price, 
    p.QuantityInStock, 
    c.CategoryName
FROM Products p
JOIN Categories c ON p.CategoryID = c.CategoryID;

-- 2. List suppliers for each product
SELECT 
    p.ProductName, 
    s.SupplierName
FROM Products p
JOIN ProductSupplier ps ON p.ProductID = ps.ProductID
JOIN Suppliers s ON s.SupplierID = ps.SupplierID;

-- 3. Find all products with no supplier linked
SELECT 
    ProductName 
FROM Products 
WHERE ProductID NOT IN (
    SELECT ProductID FROM ProductSupplier
);

-- 4. Count number of products per category
SELECT 
    c.CategoryName, 
    COUNT(p.ProductID) AS ProductCount
FROM Categories c
LEFT JOIN Products p ON c.CategoryID = p.CategoryID
GROUP BY c.CategoryName;

-- 5. Show the category with the highest total stock
SELECT 
    c.CategoryName, 
    SUM(p.QuantityInStock) AS TotalStock
FROM Categories c
JOIN Products p ON c.CategoryID = p.CategoryID
GROUP BY c.CategoryName
ORDER BY TotalStock DESC
LIMIT 1;

-- 6. Find the most expensive product in each category
SELECT 
    c.CategoryName,
    p.ProductName,
    p.Price
FROM Products p
JOIN Categories c ON p.CategoryID = c.CategoryID
WHERE p.Price = (
    SELECT MAX(p2.Price)
    FROM Products p2
    WHERE p2.CategoryID = p.CategoryID
);

-- 7. List products and their total number of suppliers
SELECT 
    p.ProductName,
    COUNT(ps.SupplierID) AS SupplierCount
FROM Products p
LEFT JOIN ProductSupplier ps ON p.ProductID = ps.ProductID
GROUP BY p.ProductID, p.ProductName;

-- 8. Get all suppliers who supply more than 1 product
SELECT 
    s.SupplierName, 
    COUNT(ps.ProductID) AS ProductSupplied
FROM Suppliers s
JOIN ProductSupplier ps ON s.SupplierID = ps.SupplierID
GROUP BY s.SupplierID, s.SupplierName
HAVING COUNT(ps.ProductID) > 1;

-- 9. Find all categories that currently have no products
SELECT 
    CategoryName 
FROM Categories 
WHERE CategoryID NOT IN (
    SELECT DISTINCT CategoryID FROM Products
);

-- 10. List products priced above average price
SELECT 
    ProductName, Price
FROM Products
WHERE Price > (SELECT AVG(Price) FROM Products);

-- 11. Update stock level when a product is restocked
UPDATE Products
SET QuantityInStock = QuantityInStock + 25
WHERE ProductID = 5;

-- 12. Delete a supplier and check cascading effects
DELETE FROM Suppliers
WHERE SupplierID = 3;

-- 13. Retrieve all suppliers who supply electronics products
SELECT DISTINCT s.SupplierName
FROM Suppliers s
JOIN ProductSupplier ps ON s.SupplierID = ps.SupplierID
JOIN Products p ON p.ProductID = ps.ProductID
JOIN Categories c ON c.CategoryID = p.CategoryID
WHERE c.CategoryName = 'Electronics';

-- 14. Check total inventory value (price * quantity)
SELECT 
    SUM(Price * QuantityInStock) AS TotalInventoryValue
FROM Products;

-- 15. List products with price constraints (between 20 and 500)
SELECT 
    ProductName, Price 
FROM Products 
WHERE Price BETWEEN 20 AND 500;
