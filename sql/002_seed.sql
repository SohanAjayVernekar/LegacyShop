USE LegacyEcommerceDb;
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Categories)
BEGIN
    INSERT dbo.Categories (Name, Slug) VALUES
      (N'Furniture', N'furniture'),
      (N'Lighting', N'lighting'),
      (N'Decor', N'decor'),
      (N'Textiles', N'textiles');
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Products)
BEGIN
    DECLARE @Furniture INT = (SELECT Id FROM dbo.Categories WHERE Slug=N'furniture');
    DECLARE @Lighting  INT = (SELECT Id FROM dbo.Categories WHERE Slug=N'lighting');
    DECLARE @Decor     INT = (SELECT Id FROM dbo.Categories WHERE Slug=N'decor');

    INSERT dbo.Products
      (CategoryId, Name, Slug, Description, Price, ThumbnailUrl, StockQuantity, IsFeatured)
    VALUES
      (@Furniture, N'Nordic Lounge Chair', N'nordic-lounge-chair',
       N'A comfortable lounge chair with a clean Scandinavian silhouette.',
       12999.00, N'/Content/images/products/chair.jpg', 15, 1),
      (@Lighting, N'Ceramic Table Lamp', N'ceramic-table-lamp',
       N'Warm ambient table lamp for living and bedroom spaces.',
       3499.00, N'/Content/images/products/lamp.jpg', 22, 1),
      (@Decor, N'Stoneware Vase', N'stoneware-vase',
       N'Minimal stoneware vase with a soft neutral finish.',
       1899.00, N'/Content/images/products/vase.jpg', 30, 1);
END
GO
