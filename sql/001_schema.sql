SET QUOTED_IDENTIFIER ON;
GO
SET ANSI_NULLS ON;
GO
SET ANSI_PADDING ON;
GO
SET ANSI_WARNINGS ON;
GO
SET ARITHABORT ON;
GO
SET CONCAT_NULL_YIELDS_NULL ON;
GO
SET NUMERIC_ROUNDABORT OFF;
GO

IF DB_ID(N'LegacyEcommerceDb') IS NULL
BEGIN
    CREATE DATABASE LegacyEcommerceDb;
END
GO

USE LegacyEcommerceDb;
GO

IF OBJECT_ID(N'dbo.Categories', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Categories (
        Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        Name NVARCHAR(120) NOT NULL,
        Slug NVARCHAR(140) NOT NULL UNIQUE,
        IsActive BIT NOT NULL CONSTRAINT DF_Categories_IsActive DEFAULT (1)
    );
END
GO

IF OBJECT_ID(N'dbo.Products', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Products (
        Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        CategoryId INT NOT NULL,
        Name NVARCHAR(180) NOT NULL,
        Slug NVARCHAR(200) NOT NULL UNIQUE,
        Description NVARCHAR(MAX) NULL,
        Price DECIMAL(18,2) NOT NULL,
        ThumbnailUrl NVARCHAR(500) NULL,
        StockQuantity INT NOT NULL CONSTRAINT DF_Products_Stock DEFAULT (0),
        IsFeatured BIT NOT NULL CONSTRAINT DF_Products_Featured DEFAULT (0),
        IsActive BIT NOT NULL CONSTRAINT DF_Products_Active DEFAULT (1),
        CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_Products_Created DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT FK_Products_Categories
            FOREIGN KEY (CategoryId) REFERENCES dbo.Categories(Id)
    );
END
GO

IF OBJECT_ID(N'dbo.ProductImages', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.ProductImages (
        Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        ProductId INT NOT NULL,
        ImageUrl NVARCHAR(500) NOT NULL,
        SortOrder INT NOT NULL CONSTRAINT DF_ProductImages_Sort DEFAULT (0),
        CONSTRAINT FK_ProductImages_Products
            FOREIGN KEY (ProductId) REFERENCES dbo.Products(Id) ON DELETE CASCADE
    );
END
GO

IF OBJECT_ID(N'dbo.ProductVariants', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.ProductVariants (
        Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        ProductId INT NOT NULL,
        Name NVARCHAR(120) NOT NULL,
        Sku NVARCHAR(80) NOT NULL UNIQUE,
        PriceAdjustment DECIMAL(18,2) NOT NULL CONSTRAINT DF_Variants_Adjustment DEFAULT (0),
        StockQuantity INT NOT NULL CONSTRAINT DF_Variants_Stock DEFAULT (0),
        CONSTRAINT FK_ProductVariants_Products
            FOREIGN KEY (ProductId) REFERENCES dbo.Products(Id) ON DELETE CASCADE
    );
END
GO

IF OBJECT_ID(N'dbo.Customers', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Customers (
        Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        Email NVARCHAR(256) NOT NULL UNIQUE,
        FullName NVARCHAR(160) NOT NULL,
        Phone NVARCHAR(40) NULL,
        CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_Customers_Created DEFAULT (SYSUTCDATETIME()),
        IsActive BIT NOT NULL CONSTRAINT DF_Customers_Active DEFAULT (1)
    );
END
GO

IF OBJECT_ID(N'dbo.Addresses', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Addresses (
        Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        CustomerId INT NOT NULL,
        Label NVARCHAR(80) NULL,
        Line1 NVARCHAR(200) NOT NULL,
        Line2 NVARCHAR(200) NULL,
        City NVARCHAR(100) NOT NULL,
        State NVARCHAR(100) NOT NULL,
        PostalCode NVARCHAR(20) NOT NULL,
        Country NVARCHAR(100) NOT NULL,
        IsDefault BIT NOT NULL CONSTRAINT DF_Addresses_Default DEFAULT (0),
        CONSTRAINT FK_Addresses_Customers
            FOREIGN KEY (CustomerId) REFERENCES dbo.Customers(Id) ON DELETE CASCADE
    );
END
GO

IF OBJECT_ID(N'dbo.Orders', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Orders (
        Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        CustomerId INT NOT NULL,
        OrderNumber NVARCHAR(40) NOT NULL UNIQUE,
        Status NVARCHAR(40) NOT NULL,
        Subtotal DECIMAL(18,2) NOT NULL,
        ShippingAmount DECIMAL(18,2) NOT NULL,
        TotalAmount DECIMAL(18,2) NOT NULL,
        ShippingName NVARCHAR(160) NOT NULL,
        ShippingLine1 NVARCHAR(200) NOT NULL,
        ShippingLine2 NVARCHAR(200) NULL,
        ShippingCity NVARCHAR(100) NOT NULL,
        ShippingState NVARCHAR(100) NOT NULL,
        ShippingPostalCode NVARCHAR(20) NOT NULL,
        ShippingCountry NVARCHAR(100) NOT NULL,
        CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_Orders_Created DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT FK_Orders_Customers
            FOREIGN KEY (CustomerId) REFERENCES dbo.Customers(Id)
    );
END
GO

IF OBJECT_ID(N'dbo.OrderLines', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.OrderLines (
        Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        OrderId INT NOT NULL,
        ProductId INT NOT NULL,
        ProductName NVARCHAR(180) NOT NULL,
        UnitPrice DECIMAL(18,2) NOT NULL,
        Quantity INT NOT NULL,
        LineTotal AS (UnitPrice * Quantity) PERSISTED,
        CONSTRAINT FK_OrderLines_Orders
            FOREIGN KEY (OrderId) REFERENCES dbo.Orders(Id) ON DELETE CASCADE,
        CONSTRAINT FK_OrderLines_Products
            FOREIGN KEY (ProductId) REFERENCES dbo.Products(Id)
    );
END
GO
