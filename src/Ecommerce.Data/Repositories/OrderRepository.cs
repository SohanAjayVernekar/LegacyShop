using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using Ecommerce.Core.Entities;
using Ecommerce.Core.Interfaces.Repositories;

namespace Ecommerce.Data.Repositories
{
    public class OrderRepository : IOrderRepository
    {
        private readonly LegacyEcommerceContext _db;
        public OrderRepository(LegacyEcommerceContext db) { _db = db; }

        public void Add(Order order)
        {
            _db.Orders.Add(order);
            _db.SaveChanges();
        }

        public IList<Order> GetByCustomer(int customerId, int take)
        {
            return _db.Orders.Include(x => x.Lines)
                .Where(x => x.CustomerId == customerId)
                .OrderByDescending(x => x.CreatedAt).Take(take).ToList();
        }

        public IList<Order> GetRecent(int take)
        {
            return _db.Orders.Include(x => x.Customer)
                .OrderByDescending(x => x.CreatedAt).Take(take).ToList();
        }

        public int Count() { return _db.Orders.Count(); }
        public decimal TotalSales() { return _db.Orders.Where(x => x.Status != "Cancelled").Select(x => (decimal?)x.TotalAmount).Sum() ?? 0m; }
    }
}
