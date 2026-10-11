using System.Collections.Generic;

namespace Ecommerce.Core.Entities
{
    public class Category
    {
        public Category() { Products = new HashSet<Product>(); }
        public int Id { get; set; }
        public string Name { get; set; }
        public string Slug { get; set; }
        public bool IsActive { get; set; }
        public virtual ICollection<Product> Products { get; set; }
    }
}
