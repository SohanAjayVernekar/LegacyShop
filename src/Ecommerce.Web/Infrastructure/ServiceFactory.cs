using Ecommerce.Data;
using Ecommerce.Data.Repositories;
using Ecommerce.Services;
using Ecommerce.Core.Interfaces.Services;

namespace Ecommerce.Web.Infrastructure
{
    public static class ServiceFactory
    {
        public static ICatalogService Catalog()
        {
            var db = new LegacyEcommerceContext();
            return new CatalogService(new ProductRepository(db), new CategoryRepository(db));
        }

        public static IAuthService Auth()
        {
            var db = new LegacyEcommerceContext();
            return new AuthService(new UserRepository(db));
        }

        public static IOrderService Orders()
        {
            var db = new LegacyEcommerceContext();
            return new OrderService(new OrderRepository(db), new ProductRepository(db), new UserRepository(db));
        }
    }
}
