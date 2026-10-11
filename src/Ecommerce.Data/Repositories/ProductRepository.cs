using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using Ecommerce.Core.Entities;
using Ecommerce.Core.Interfaces.Repositories;

namespace Ecommerce.Data.Repositories
{
    public class ProductRepository : IProductRepository
    {
        private readonly LegacyEcommerceContext _db;
        public ProductRepository(LegacyEcommerceContext db) { _db = db; }

        public Product GetById(int id)
        {
            return _db.Products
                .Include(x => x.Category)
                .Include(x => x.Images)
                .Include(x => x.Variants)
                .FirstOrDefault(x => x.Id == id && x.IsActive);
        }

        public IList<Product> Search(int? categoryId, string query, int page, int pageSize, out int totalCount)
        {
            if (page < 1) page = 1;
            if (pageSize < 1) pageSize = 24;

            var q = _db.Products
                .Include(x => x.Category)
                .Where(x => x.IsActive);

            if (categoryId.HasValue)
                q = q.Where(x => x.CategoryId == categoryId.Value);

            if (!string.IsNullOrWhiteSpace(query))
            {
                query = query.Trim();
                q = q.Where(x => x.Name.Contains(query) || x.Description.Contains(query));
            }

            totalCount = q.Count();

            return q
                .OrderByDescending(x => x.IsFeatured)
                .ThenByDescending(x => x.CreatedAt)
                .ThenBy(x => x.Name)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToList();
        }

        public IList<Product> GetAllForAdmin()
        {
            return _db.Products
                .Include(x => x.Category)
                .OrderByDescending(x => x.Id)
                .ToList();
        }

        public void Add(Product product)
        {
            _db.Products.Add(product);
            _db.SaveChanges();
        }

        public void Update(Product product)
        {
            _db.Entry(product).State = EntityState.Modified;
            _db.SaveChanges();
        }

        public int Count()
        {
            return _db.Products.Count(x => x.IsActive);
        }

        public int CountLowStock(int threshold)
        {
            return _db.Products.Count(x => x.IsActive && x.StockQuantity <= threshold);
        }
    }
}
