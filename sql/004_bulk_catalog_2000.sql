SET QUOTED_IDENTIFIER ON;
GO
SET ANSI_NULLS ON;
GO

USE LegacyEcommerceDb;
GO

DECLARE @CurrentCount INT = (SELECT COUNT(*) FROM dbo.Products);
DECLARE @Need INT = 2000 - @CurrentCount;
DECLARE @BulkExisting INT = (SELECT COUNT(*) FROM dbo.Products WHERE Slug LIKE N'legacy-bulk-%');

DECLARE @Furniture INT = (SELECT TOP 1 Id FROM dbo.Categories WHERE Slug = N'furniture');
DECLARE @Lighting  INT = (SELECT TOP 1 Id FROM dbo.Categories WHERE Slug = N'lighting');
DECLARE @Decor     INT = (SELECT TOP 1 Id FROM dbo.Categories WHERE Slug = N'decor');
DECLARE @Textiles  INT = (SELECT TOP 1 Id FROM dbo.Categories WHERE Slug = N'textiles');

IF @Need > 0
BEGIN
    ;WITH N AS
    (
        SELECT 1 AS n
        UNION ALL
        SELECT n + 1
        FROM N
        WHERE n < @Need
    ),
    X AS
    (
        SELECT
            n,
            @BulkExisting + n AS ProductNo,
            ((@BulkExisting + n - 1) % 16) + 1 AS ProductType,
            ((@BulkExisting + n - 1) % 4) + 1 AS CategoryNo
        FROM N
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
        CASE CategoryNo
            WHEN 1 THEN @Furniture
            WHEN 2 THEN @Lighting
            WHEN 3 THEN @Decor
            ELSE @Textiles
        END,
        CASE ProductType
            WHEN 1  THEN N'Cloud Lounge Chair'
            WHEN 2  THEN N'Arc Floor Lamp'
            WHEN 3  THEN N'Stoneware Vase'
            WHEN 4  THEN N'Woven Throw'
            WHEN 5  THEN N'Oak Coffee Table'
            WHEN 6  THEN N'Linen Cushion'
            WHEN 7  THEN N'Ceramic Desk Lamp'
            WHEN 8  THEN N'Ripple Side Table'
            WHEN 9  THEN N'Matte Planter'
            WHEN 10 THEN N'Textured Rug'
            WHEN 11 THEN N'Nordic Bench'
            WHEN 12 THEN N'Glass Pendant Light'
            WHEN 13 THEN N'Round Wall Mirror'
            WHEN 14 THEN N'Cotton Bed Throw'
            WHEN 15 THEN N'Sculpted Accent Chair'
            ELSE N'Natural Storage Basket'
        END
        + N' ' + RIGHT(N'0000' + CONVERT(NVARCHAR(10), ProductNo), 4),
        N'legacy-bulk-' + RIGHT(N'0000' + CONVERT(NVARCHAR(10), ProductNo), 4),
        N'A curated LegacyShop home and lifestyle piece with warm materials, practical details and a calm contemporary look.',
        CONVERT(DECIMAL(18,2), 699 + ((ProductNo * 337) % 24500)),
        NULL,
        4 + ((ProductNo * 7) % 58),
        CASE WHEN ProductNo % 31 = 0 THEN 1 ELSE 0 END,
        1,
        DATEADD(MINUTE, -ProductNo, SYSUTCDATETIME())
    FROM X
    OPTION (MAXRECURSION 0);
END
GO

SELECT COUNT(*) AS TotalProducts FROM dbo.Products;
GO
