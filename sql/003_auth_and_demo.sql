SET QUOTED_IDENTIFIER ON;
GO
SET ANSI_NULLS ON;
GO

USE LegacyEcommerceDb;
GO

IF OBJECT_ID(N'dbo.AppUsers', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.AppUsers (
        Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        Email NVARCHAR(256) NOT NULL UNIQUE,
        PasswordHash CHAR(64) NOT NULL,
        Role NVARCHAR(20) NOT NULL,
        DisplayName NVARCHAR(160) NOT NULL,
        CustomerId INT NULL,
        IsActive BIT NOT NULL CONSTRAINT DF_AppUsers_Active DEFAULT (1),
        CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_AppUsers_Created DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT FK_AppUsers_Customers
            FOREIGN KEY (CustomerId) REFERENCES dbo.Customers(Id)
    );
END
GO

DECLARE @CustomerId INT;
SELECT @CustomerId = Id FROM dbo.Customers WHERE Email = N'customer@legacyshop.local';

IF @CustomerId IS NULL
BEGIN
    INSERT dbo.Customers (Email, FullName, Phone)
    VALUES (N'customer@legacyshop.local', N'Alex Morgan', N'+91 90000 00000');
    SET @CustomerId = SCOPE_IDENTITY();
END
GO

DECLARE @CustomerId2 INT = (SELECT Id FROM dbo.Customers WHERE Email = N'customer@legacyshop.local');

IF NOT EXISTS (SELECT 1 FROM dbo.AppUsers WHERE Email = N'customer@legacyshop.local')
BEGIN
    INSERT dbo.AppUsers (Email, PasswordHash, Role, DisplayName, CustomerId)
    VALUES (
        N'customer@legacyshop.local',
        'C0E1D44327F4FCD20BBA46A452FFA509E395280BE177C519FE704A5C606A1FCF',
        N'Customer',
        N'Alex Morgan',
        @CustomerId2
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.AppUsers WHERE Email = N'admin@legacyshop.local')
BEGIN
    INSERT dbo.AppUsers (Email, PasswordHash, Role, DisplayName, CustomerId)
    VALUES (
        N'admin@legacyshop.local',
        '2460B770490E888C1BABEAD1580BCCC3C0C63B3358ACE78ED3A788BB649BFE12',
        N'Admin',
        N'LegacyShop Admin',
        NULL
    );
END
GO

-- Seed one demo order so the customer dashboard is not empty.
DECLARE @DemoCustomerId INT = (SELECT Id FROM dbo.Customers WHERE Email = N'customer@legacyshop.local');

IF @DemoCustomerId IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM dbo.Orders WHERE OrderNumber = N'LS-DEMO-1001')
BEGIN
    INSERT dbo.Orders (
        CustomerId, OrderNumber, Status, Subtotal, ShippingAmount, TotalAmount,
        ShippingName, ShippingLine1, ShippingLine2, ShippingCity, ShippingState,
        ShippingPostalCode, ShippingCountry
    )
    VALUES (
        @DemoCustomerId, N'LS-DEMO-1001', N'Delivered',
        12999.00, 0.00, 12999.00,
        N'Alex Morgan', N'101 Demo Street', NULL, N'Mumbai', N'Maharashtra',
        N'400001', N'India'
    );

    DECLARE @OrderId INT = SCOPE_IDENTITY();
    DECLARE @ProductId INT = (SELECT TOP 1 Id FROM dbo.Products WHERE Slug = N'nordic-lounge-chair');

    IF @ProductId IS NOT NULL
    BEGIN
        INSERT dbo.OrderLines (OrderId, ProductId, ProductName, UnitPrice, Quantity)
        VALUES (@OrderId, @ProductId, N'Nordic Lounge Chair', 12999.00, 1);
    END
END
GO
