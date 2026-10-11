using System;
using System.Collections.Generic;

namespace Ecommerce.Core.Entities
{
    public class Product
    {
        public Product()
        {
            Images = new HashSet<ProductImage>();
            Variants = new HashSet<ProductVariant>();
        }

        public int Id { get; set; }
        public int CategoryId { get; set; }
        public string Name { get; set; }
        public string Slug { get; set; }
        public string Description { get; set; }
        public decimal Price { get; set; }
        public string ThumbnailUrl { get; set; }
        public int StockQuantity { get; set; }
        public bool IsFeatured { get; set; }
        public bool IsActive { get; set; }
        public DateTime CreatedAt { get; set; }

        public virtual Category Category { get; set; }
        public virtual ICollection<ProductImage> Images { get; set; }
        public virtual ICollection<ProductVariant> Variants { get; set; }
    }
}
