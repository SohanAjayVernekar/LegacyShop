SET QUOTED_IDENTIFIER ON;
GO
SET ANSI_NULLS ON;
GO

USE LegacyEcommerceDb;
GO

/* ---------------------------------------------------------
   1) ENSURE MARKETPLACE CATEGORIES EXIST
   --------------------------------------------------------- */

IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE Slug=N'electronics')
    INSERT dbo.Categories(Name,Slug,IsActive) VALUES(N'Electronics',N'electronics',1);

IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE Slug=N'mobiles-tablets')
    INSERT dbo.Categories(Name,Slug,IsActive) VALUES(N'Mobiles & Tablets',N'mobiles-tablets',1);

IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE Slug=N'computers-accessories')
    INSERT dbo.Categories(Name,Slug,IsActive) VALUES(N'Computers & Accessories',N'computers-accessories',1);

IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE Slug=N'tv-audio')
    INSERT dbo.Categories(Name,Slug,IsActive) VALUES(N'TV & Audio',N'tv-audio',1);

IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE Slug=N'cameras')
    INSERT dbo.Categories(Name,Slug,IsActive) VALUES(N'Cameras',N'cameras',1);

IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE Slug=N'gaming')
    INSERT dbo.Categories(Name,Slug,IsActive) VALUES(N'Gaming',N'gaming',1);

IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE Slug=N'home-kitchen')
    INSERT dbo.Categories(Name,Slug,IsActive) VALUES(N'Home & Kitchen',N'home-kitchen',1);

IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE Slug=N'furniture')
    INSERT dbo.Categories(Name,Slug,IsActive) VALUES(N'Furniture',N'furniture',1);

IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE Slug=N'lighting')
    INSERT dbo.Categories(Name,Slug,IsActive) VALUES(N'Lighting',N'lighting',1);

IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE Slug=N'decor')
    INSERT dbo.Categories(Name,Slug,IsActive) VALUES(N'Decor',N'decor',1);

IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE Slug=N'appliances')
    INSERT dbo.Categories(Name,Slug,IsActive) VALUES(N'Appliances',N'appliances',1);

IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE Slug=N'mens-fashion')
    INSERT dbo.Categories(Name,Slug,IsActive) VALUES(N'Men''s Fashion',N'mens-fashion',1);

IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE Slug=N'womens-fashion')
    INSERT dbo.Categories(Name,Slug,IsActive) VALUES(N'Women''s Fashion',N'womens-fashion',1);

IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE Slug=N'shoes')
    INSERT dbo.Categories(Name,Slug,IsActive) VALUES(N'Shoes',N'shoes',1);

IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE Slug=N'bags-luggage')
    INSERT dbo.Categories(Name,Slug,IsActive) VALUES(N'Bags & Luggage',N'bags-luggage',1);

IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE Slug=N'jewelry')
    INSERT dbo.Categories(Name,Slug,IsActive) VALUES(N'Jewelry',N'jewelry',1);

IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE Slug=N'watches')
    INSERT dbo.Categories(Name,Slug,IsActive) VALUES(N'Watches',N'watches',1);

IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE Slug=N'beauty-personal-care')
    INSERT dbo.Categories(Name,Slug,IsActive) VALUES(N'Beauty & Personal Care',N'beauty-personal-care',1);

IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE Slug=N'health-wellness')
    INSERT dbo.Categories(Name,Slug,IsActive) VALUES(N'Health & Wellness',N'health-wellness',1);

IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE Slug=N'grocery')
    INSERT dbo.Categories(Name,Slug,IsActive) VALUES(N'Grocery',N'grocery',1);

IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE Slug=N'books')
    INSERT dbo.Categories(Name,Slug,IsActive) VALUES(N'Books',N'books',1);

IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE Slug=N'sports-fitness')
    INSERT dbo.Categories(Name,Slug,IsActive) VALUES(N'Sports & Fitness',N'sports-fitness',1);

IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE Slug=N'toys-games')
    INSERT dbo.Categories(Name,Slug,IsActive) VALUES(N'Toys & Games',N'toys-games',1);

IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE Slug=N'baby')
    INSERT dbo.Categories(Name,Slug,IsActive) VALUES(N'Baby',N'baby',1);

IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE Slug=N'automotive')
    INSERT dbo.Categories(Name,Slug,IsActive) VALUES(N'Automotive',N'automotive',1);

IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE Slug=N'pet-supplies')
    INSERT dbo.Categories(Name,Slug,IsActive) VALUES(N'Pet Supplies',N'pet-supplies',1);

IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE Slug=N'office-stationery')
    INSERT dbo.Categories(Name,Slug,IsActive) VALUES(N'Office & Stationery',N'office-stationery',1);

IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE Slug=N'garden-outdoor')
    INSERT dbo.Categories(Name,Slug,IsActive) VALUES(N'Garden & Outdoor',N'garden-outdoor',1);

IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE Slug=N'tools-home-improvement')
    INSERT dbo.Categories(Name,Slug,IsActive) VALUES(N'Tools & Home Improvement',N'tools-home-improvement',1);

IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE Slug=N'musical-instruments')
    INSERT dbo.Categories(Name,Slug,IsActive) VALUES(N'Musical Instruments',N'musical-instruments',1);

IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE Slug=N'gifts')
    INSERT dbo.Categories(Name,Slug,IsActive) VALUES(N'Gifts',N'gifts',1);

IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE Slug=N'travel-accessories')
    INSERT dbo.Categories(Name,Slug,IsActive) VALUES(N'Travel Accessories',N'travel-accessories',1);

GO

/* ---------------------------------------------------------
   2) USE A TEMP TABLE INSTEAD OF @Templates
      #Templates survives GO batches in the same sqlcmd session.
   --------------------------------------------------------- */

IF OBJECT_ID('tempdb..#Templates') IS NOT NULL
    DROP TABLE #Templates;

CREATE TABLE #Templates
(
    TemplateId INT IDENTITY(1,1) PRIMARY KEY,
    CategorySlug NVARCHAR(140) NOT NULL,
    BaseName NVARCHAR(180) NOT NULL,
    BasePrice DECIMAL(18,2) NOT NULL
);

INSERT #Templates(CategorySlug,BaseName,BasePrice) VALUES
(N'electronics',N'Wireless Earbuds',2499.00),
(N'electronics',N'Bluetooth Speaker',2999.00),
(N'electronics',N'Power Bank',1799.00),

(N'mobiles-tablets',N'5G Smartphone',18999.00),
(N'mobiles-tablets',N'Android Tablet',22999.00),
(N'mobiles-tablets',N'Fast Charger',1499.00),

(N'computers-accessories',N'Ultrabook Laptop',64999.00),
(N'computers-accessories',N'Mechanical Keyboard',4999.00),
(N'computers-accessories',N'27-inch Monitor',18999.00),

(N'tv-audio',N'4K Smart TV',42999.00),
(N'tv-audio',N'Soundbar',11999.00),
(N'tv-audio',N'Over-Ear Headphones',6999.00),

(N'cameras',N'Mirrorless Camera',58999.00),
(N'cameras',N'Action Camera',21999.00),
(N'cameras',N'Camera Tripod',3499.00),

(N'gaming',N'Gaming Console',44999.00),
(N'gaming',N'Gaming Mouse',2999.00),
(N'gaming',N'Gaming Headset',5999.00),

(N'home-kitchen',N'Cookware Set',6999.00),
(N'home-kitchen',N'Chef Knife Set',3499.00),
(N'home-kitchen',N'Coffee Maker',6499.00),

(N'furniture',N'Nordic Lounge Chair',12999.00),
(N'furniture',N'Oak Coffee Table',10999.00),
(N'furniture',N'Study Desk',11999.00),

(N'lighting',N'Ceramic Table Lamp',3499.00),
(N'lighting',N'Arc Floor Lamp',6999.00),
(N'lighting',N'Pendant Light',5299.00),

(N'decor',N'Stoneware Vase',1899.00),
(N'decor',N'Round Wall Mirror',4999.00),
(N'decor',N'Abstract Wall Art',2499.00),

(N'appliances',N'Air Fryer',8999.00),
(N'appliances',N'Microwave Oven',12999.00),
(N'appliances',N'Vacuum Cleaner',10999.00),

(N'mens-fashion',N'Oxford Shirt',1799.00),
(N'mens-fashion',N'Slim Fit Jeans',2499.00),
(N'mens-fashion',N'Casual Jacket',3999.00),

(N'womens-fashion',N'Printed Kurta',1999.00),
(N'womens-fashion',N'Midi Dress',2999.00),
(N'womens-fashion',N'Denim Jacket',3499.00),

(N'shoes',N'Running Shoes',3999.00),
(N'shoes',N'Leather Sneakers',4499.00),
(N'shoes',N'Formal Loafers',4999.00),

(N'bags-luggage',N'Travel Backpack',3499.00),
(N'bags-luggage',N'Cabin Trolley',5999.00),
(N'bags-luggage',N'Crossbody Bag',2199.00),

(N'jewelry',N'Minimal Pendant',1999.00),
(N'jewelry',N'Stud Earring Set',1499.00),
(N'jewelry',N'Pearl Necklace',2999.00),

(N'watches',N'Classic Analog Watch',4999.00),
(N'watches',N'Smart Fitness Watch',6999.00),
(N'watches',N'Sports Chronograph',7499.00),

(N'beauty-personal-care',N'Hydrating Face Serum',1299.00),
(N'beauty-personal-care',N'Hair Dryer',2499.00),
(N'beauty-personal-care',N'Skincare Gift Kit',2299.00),

(N'health-wellness',N'Yoga Mat',1299.00),
(N'health-wellness',N'Massage Gun',5999.00),
(N'health-wellness',N'Digital Weighing Scale',1499.00),

(N'grocery',N'Premium Coffee Beans',899.00),
(N'grocery',N'Dry Fruit Mix',1199.00),
(N'grocery',N'Organic Honey',649.00),

(N'books',N'Modern Fiction Book',799.00),
(N'books',N'Business Essentials Book',699.00),
(N'books',N'Design Coffee Table Book',1499.00),

(N'sports-fitness',N'Adjustable Dumbbell Set',6999.00),
(N'sports-fitness',N'Football',1199.00),
(N'sports-fitness',N'Badminton Racket',2499.00),

(N'toys-games',N'Building Blocks Set',1799.00),
(N'toys-games',N'Strategy Board Game',1499.00),
(N'toys-games',N'Remote Control Toy Car',2499.00),

(N'baby',N'Baby Stroller',8999.00),
(N'baby',N'Baby Blanket',1499.00),
(N'baby',N'Soft Activity Toy',1199.00),

(N'automotive',N'Car Vacuum Cleaner',2999.00),
(N'automotive',N'Phone Car Mount',999.00),
(N'automotive',N'Dash Camera',7999.00),

(N'pet-supplies',N'Pet Bed',2499.00),
(N'pet-supplies',N'Pet Grooming Kit',1599.00),
(N'pet-supplies',N'Interactive Pet Toy',1199.00),

(N'office-stationery',N'Premium Notebook Set',899.00),
(N'office-stationery',N'Desk Organizer',1299.00),
(N'office-stationery',N'Planner Journal',799.00),

(N'garden-outdoor',N'Garden Tool Set',2499.00),
(N'garden-outdoor',N'Solar Garden Light',1299.00),
(N'garden-outdoor',N'Outdoor Planter',1599.00),

(N'tools-home-improvement',N'Cordless Drill',6999.00),
(N'tools-home-improvement',N'Tool Kit',3999.00),
(N'tools-home-improvement',N'Screwdriver Set',999.00),

(N'musical-instruments',N'Acoustic Guitar',11999.00),
(N'musical-instruments',N'Portable Keyboard',14999.00),
(N'musical-instruments',N'Studio Microphone',6999.00),

(N'gifts',N'Luxury Gift Hamper',3499.00),
(N'gifts',N'Personalized Mug',899.00),
(N'gifts',N'Celebration Gift Box',2499.00),

(N'travel-accessories',N'Travel Neck Pillow',1199.00),
(N'travel-accessories',N'Universal Travel Adapter',1999.00),
(N'travel-accessories',N'Packing Cube Set',1499.00);

GO

/* ---------------------------------------------------------
   3) REDISTRIBUTE EXISTING GENERATED PRODUCTS
   --------------------------------------------------------- */

DECLARE @TemplateCount INT = (SELECT COUNT(*) FROM #Templates);

;WITH BulkRows AS
(
    SELECT
        Id,
        ROW_NUMBER() OVER (ORDER BY Id) AS rn
    FROM dbo.Products
    WHERE Slug LIKE N'legacy-bulk-%'
)
UPDATE p
SET
    p.CategoryId = c.Id,
    p.Name = t.BaseName + N' ' + RIGHT(N'0000' + CONVERT(NVARCHAR(10), b.rn), 4),
    p.Description = N'LegacyShop marketplace item in ' + c.Name + N'.',
    p.Price = t.BasePrice + CONVERT(DECIMAL(18,2), ((b.rn * 73) % 2200)),
    p.StockQuantity = 5 + ((b.rn * 11) % 70),
    p.IsFeatured = CASE WHEN b.rn % 37 = 0 THEN 1 ELSE 0 END,
    p.IsActive = 1
FROM dbo.Products p
JOIN BulkRows b
    ON b.Id = p.Id
JOIN #Templates t
    ON t.TemplateId = ((b.rn - 1) % @TemplateCount) + 1
JOIN dbo.Categories c
    ON c.Slug = t.CategorySlug;

GO

/* ---------------------------------------------------------
   4) TOP UP TO 2000 PRODUCTS IF NEEDED
   --------------------------------------------------------- */

DECLARE @CurrentCount INT = (SELECT COUNT(*) FROM dbo.Products);
DECLARE @Need INT = CASE WHEN @CurrentCount < 2000 THEN 2000 - @CurrentCount ELSE 0 END;
DECLARE @TemplateCount2 INT = (SELECT COUNT(*) FROM #Templates);

IF @Need > 0
BEGIN
    ;WITH N AS
    (
        SELECT 1 AS n
        UNION ALL
        SELECT n + 1
        FROM N
        WHERE n < @Need
    )
    INSERT dbo.Products
    (
        CategoryId,
        Name,
        Slug,
        Description,
        Price,
        ThumbnailUrl,
        StockQuantity,
        IsFeatured,
        IsActive,
        CreatedAt
    )
    SELECT
        c.Id,
        t.BaseName + N' ' + RIGHT(N'0000' + CONVERT(NVARCHAR(10), 5000 + n), 4),
        N'legacy-bulk-' + RIGHT(N'0000' + CONVERT(NVARCHAR(10), 5000 + n), 4),
        N'LegacyShop marketplace item in ' + c.Name + N'.',
        t.BasePrice + CONVERT(DECIMAL(18,2), ((n * 73) % 2200)),
        NULL,
        5 + ((n * 11) % 70),
        CASE WHEN n % 37 = 0 THEN 1 ELSE 0 END,
        1,
        DATEADD(MINUTE, -n, SYSUTCDATETIME())
    FROM N
    JOIN #Templates t
        ON t.TemplateId = ((n - 1) % @TemplateCount2) + 1
    JOIN dbo.Categories c
        ON c.Slug = t.CategorySlug
    OPTION (MAXRECURSION 0);
END

GO

/* ---------------------------------------------------------
   5) VERIFY RESULT
   --------------------------------------------------------- */

SELECT COUNT(*) AS TotalProducts
FROM dbo.Products;

SELECT COUNT(*) AS TotalCategories
FROM dbo.Categories
WHERE IsActive = 1;

SELECT
    c.Name AS Category,
    COUNT(p.Id) AS ProductCount
FROM dbo.Categories c
LEFT JOIN dbo.Products p
    ON p.CategoryId = c.Id
   AND p.IsActive = 1
WHERE c.IsActive = 1
GROUP BY c.Name
ORDER BY c.Name;

DROP TABLE #Templates;
GO
