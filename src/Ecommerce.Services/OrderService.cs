using System;
using System.Collections.Generic;
using System.Linq;
using Ecommerce.Core.Entities;
using Ecommerce.Core.Interfaces.Repositories;
using Ecommerce.Core.Interfaces.Services;
using Ecommerce.Core.ViewModels;

namespace Ecommerce.Services
{
    public class OrderService : IOrderService
    {
        private readonly IOrderRepository _orders;
        private readonly IProductRepository _products;
        private readonly IUserRepository _users;

        public OrderService(IOrderRepository orders, IProductRepository products, IUserRepository users)
        {
            _orders = orders;
            _products = products;
            _users = users;
        }

        public int PlaceOrder(int customerId, CheckoutViewModel checkout, IList<CartItemViewModel> cartItems)
        {
            if (cartItems == null || cartItems.Count == 0) throw new InvalidOperationException("Your cart is empty.");

            var order = new Order
            {
                CustomerId = customerId,
                OrderNumber = "LS-" + DateTime.UtcNow.ToString("yyyyMMddHHmmss"),
                Status = "Processing",
                ShippingName = checkout.FullName,
                ShippingLine1 = checkout.Line1,
                ShippingLine2 = checkout.Line2,
                ShippingCity = checkout.City,
                ShippingState = checkout.State,
                ShippingPostalCode = checkout.PostalCode,
                ShippingCountry = checkout.Country,
                CreatedAt = DateTime.UtcNow,
                ShippingAmount = 0m
            };

            decimal subtotal = 0m;

            foreach (var item in cartItems)
            {
                var product = _products.GetById(item.ProductId);
                if (product == null || !product.IsActive) throw new InvalidOperationException("A product in your cart is no longer available.");
                if (item.Quantity <= 0 || item.Quantity > product.StockQuantity) throw new InvalidOperationException("Invalid quantity for " + product.Name + ".");

                subtotal += product.Price * item.Quantity;
                order.Lines.Add(new OrderLine
                {
                    ProductId = product.Id,
                    ProductName = product.Name,
                    UnitPrice = product.Price,
                    Quantity = item.Quantity
                });
            }

            order.Subtotal = subtotal;
            order.TotalAmount = subtotal + order.ShippingAmount;
            _orders.Add(order);
            return order.Id;
        }

        public CustomerDashboardViewModel GetCustomerDashboard(int customerId, string displayName)
        {
            var all = _orders.GetByCustomer(customerId, 50);
            return new CustomerDashboardViewModel
            {
                DisplayName = displayName,
                TotalOrders = all.Count,
                PendingOrders = all.Count(x => x.Status == "Processing" || x.Status == "Pending" || x.Status == "Shipped"),
                RecentOrders = all.Take(5).Select(x => new OrderSummaryViewModel
                {
                    Id = x.Id,
                    OrderNumber = x.OrderNumber,
                    Status = x.Status,
                    TotalAmount = x.TotalAmount,
                    CreatedAtText = x.CreatedAt.ToLocalTime().ToString("dd MMM yyyy")
                }).ToList()
            };
        }

        public AdminDashboardViewModel GetAdminDashboard()
        {
            return new AdminDashboardViewModel
            {
                TotalProducts = _products.Count(),
                TotalOrders = _orders.Count(),
                TotalCustomers = _users.CustomerCount(),
                TotalSales = _orders.TotalSales(),
                LowStockProducts = _products.CountLowStock(5),
                RecentOrders = _orders.GetRecent(6).Select(x => new OrderSummaryViewModel
                {
                    Id = x.Id,
                    OrderNumber = x.OrderNumber,
                    CustomerName = x.Customer == null ? "" : x.Customer.FullName,
                    Status = x.Status,
                    TotalAmount = x.TotalAmount,
                    CreatedAtText = x.CreatedAt.ToLocalTime().ToString("dd MMM yyyy")
                }).ToList()
            };
        }
    }
}
