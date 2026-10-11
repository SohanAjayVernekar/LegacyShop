using System.Collections.Generic;
using Ecommerce.Core.Entities;

namespace Ecommerce.Core.Interfaces.Repositories
{
    public interface IProductRepository
    {
        Product GetById(int id);
        IList<Product> Search(int? categoryId, string query, int page, int pageSize, out int totalCount);
        IList<Product> GetAllForAdmin();
        void Add(Product product);
        void Update(Product product);
        int Count();
        int CountLowStock(int threshold);
    }
}
