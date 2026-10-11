using Ecommerce.Core.Entities;

namespace Ecommerce.Core.Interfaces.Repositories
{
    public interface IUserRepository
    {
        AppUser FindActiveByEmail(string email);
        int CustomerCount();
    }
}
