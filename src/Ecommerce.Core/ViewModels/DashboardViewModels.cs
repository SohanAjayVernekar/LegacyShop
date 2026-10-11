using System.Collections.Generic;

namespace Ecommerce.Core.ViewModels
{
    public class CustomerDashboardViewModel
    {
        public CustomerDashboardViewModel() { RecentOrders = new List<OrderSummaryViewModel>(); }
        public string DisplayName { get; set; }
        public int TotalOrders { get; set; }
        public int PendingOrders { get; set; }
        public IList<OrderSummaryViewModel> RecentOrders { get; set; }
    }

    public class AdminDashboardViewModel
    {
        public int TotalProducts { get; set; }
        public int TotalOrders { get; set; }
        public int TotalCustomers { get; set; }
        public decimal TotalSales { get; set; }
        public int LowStockProducts { get; set; }
        public IList<OrderSummaryViewModel> RecentOrders { get; set; }
    }

    public class OrderSummaryViewModel
    {
        public int Id { get; set; }
        public string OrderNumber { get; set; }
        public string CustomerName { get; set; }
        public string Status { get; set; }
        public decimal TotalAmount { get; set; }
        public string CreatedAtText { get; set; }
    }
}
