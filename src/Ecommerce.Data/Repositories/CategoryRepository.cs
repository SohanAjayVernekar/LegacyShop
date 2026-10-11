using System.Collections.Generic;
using System.Linq;
using Ecommerce.Core.Entities;
using Ecommerce.Core.Interfaces.Repositories;

namespace Ecommerce.Data.Repositories
{
    public class CategoryRepository : ICategoryRepository
    {
        private readonly LegacyEcommerceContext _db;
        public CategoryRepository(LegacyEcommerceContext db) { _db = db; }
        public IList<Category> GetActive() { return _db.Categories.Where(x => x.IsActive).OrderBy(x => x.Name).ToList(); }
        public Category GetById(int id) { return _db.Categories.FirstOrDefault(x => x.Id == id); }
    }
}
