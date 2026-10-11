using System.Collections.Generic;
using Ecommerce.Core.Entities;

namespace Ecommerce.Core.Interfaces.Repositories
{
    public interface IOrderRepository
    {
        void Add(Order order);
        IList<Order> GetByCustomer(int customerId, int take);
        IList<Order> GetRecent(int take);
        int Count();
        decimal TotalSales();
    }
}
