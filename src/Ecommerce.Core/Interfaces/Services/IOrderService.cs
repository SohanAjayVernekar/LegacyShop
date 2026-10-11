using System.Collections.Generic;
using Ecommerce.Core.ViewModels;

namespace Ecommerce.Core.Interfaces.Services
{
    public interface IOrderService
    {
        int PlaceOrder(int customerId, CheckoutViewModel checkout, IList<CartItemViewModel> cartItems);
        CustomerDashboardViewModel GetCustomerDashboard(int customerId, string displayName);
        AdminDashboardViewModel GetAdminDashboard();
    }
}
