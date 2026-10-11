using System.Linq;
using Ecommerce.Core.Entities;
using Ecommerce.Core.Interfaces.Repositories;

namespace Ecommerce.Data.Repositories
{
    public class UserRepository : IUserRepository
    {
        private readonly LegacyEcommerceContext _db;
        public UserRepository(LegacyEcommerceContext db) { _db = db; }

        public AppUser FindActiveByEmail(string email)
        {
            return _db.AppUsers.Include("Customer").FirstOrDefault(x => x.Email == email && x.IsActive);
        }

        public int CustomerCount() { return _db.Customers.Count(x => x.IsActive); }
    }
}
