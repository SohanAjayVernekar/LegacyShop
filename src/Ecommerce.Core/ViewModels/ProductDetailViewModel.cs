using System.Collections.Generic;

namespace Ecommerce.Core.ViewModels
{
    public class ProductDetailViewModel
    {
        public ProductDetailViewModel()
        {
            Images = new List<string>();
            Variants = new List<ProductVariantViewModel>();
        }
        public int Id { get; set; }
        public string Name { get; set; }
        public string CategoryName { get; set; }
        public string Description { get; set; }
        public decimal Price { get; set; }
        public int StockQuantity { get; set; }
        public IList<string> Images { get; set; }
        public IList<ProductVariantViewModel> Variants { get; set; }
    }

    public class ProductVariantViewModel
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public decimal PriceAdjustment { get; set; }
        public int StockQuantity { get; set; }
    }
}
