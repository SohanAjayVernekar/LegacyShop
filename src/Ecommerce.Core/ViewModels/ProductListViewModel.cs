using System;
using System.Collections.Generic;

namespace Ecommerce.Core.ViewModels
{
    public class ProductListViewModel
    {
        public ProductListViewModel()
        {
            Products = new List<ProductCardViewModel>();
            Categories = new List<CategoryOptionViewModel>();
            Page = 1;
            PageSize = 24;
        }

        public IList<ProductCardViewModel> Products { get; set; }
        public IList<CategoryOptionViewModel> Categories { get; set; }
        public int? CategoryId { get; set; }
        public string Query { get; set; }

        public int Page { get; set; }
        public int PageSize { get; set; }
        public int TotalCount { get; set; }
        public int TotalPages
        {
            get
            {
                if (PageSize <= 0) return 1;
                return Math.Max(1, (int)Math.Ceiling((double)TotalCount / PageSize));
            }
        }
    }

    public class ProductCardViewModel
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public string CategoryName { get; set; }
        public decimal Price { get; set; }
        public string ThumbnailUrl { get; set; }
        public int StockQuantity { get; set; }
    }

    public class CategoryOptionViewModel
    {
        public int Id { get; set; }
        public string Name { get; set; }
    }
}
