using System.Collections.Generic;
using Ecommerce.Core.Entities;

namespace Ecommerce.Core.Interfaces.Repositories
{
    public interface ICategoryRepository
    {
        IList<Category> GetActive();
        Category GetById(int id);
    }
}
