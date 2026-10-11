using System.Collections.Generic;
using Ecommerce.Core.ViewModels;

namespace Ecommerce.Core.Interfaces.Services
{
    public interface ICatalogService
    {
        ProductListViewModel GetListing(int? categoryId, string query, int page);
        ProductDetailViewModel GetDetail(int productId);
        IList<AdminProductViewModel> GetAdminProducts();
        AdminProductViewModel GetAdminProduct(int id);
        void SaveAdminProduct(AdminProductViewModel model);
    }
}
