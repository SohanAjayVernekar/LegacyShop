using System;
using System.Collections.Generic;

namespace Ecommerce.Core.Entities
{
    public class Order
    {
        public Order() { Lines = new HashSet<OrderLine>(); }
        public int Id { get; set; }
        public int CustomerId { get; set; }
        public string OrderNumber { get; set; }
        public string Status { get; set; }
        public decimal Subtotal { get; set; }
        public decimal ShippingAmount { get; set; }
        public decimal TotalAmount { get; set; }
        public string ShippingName { get; set; }
        public string ShippingLine1 { get; set; }
        public string ShippingLine2 { get; set; }
        public string ShippingCity { get; set; }
        public string ShippingState { get; set; }
        public string ShippingPostalCode { get; set; }
        public string ShippingCountry { get; set; }
        public DateTime CreatedAt { get; set; }

        public virtual Customer Customer { get; set; }
        public virtual ICollection<OrderLine> Lines { get; set; }
    }
}
