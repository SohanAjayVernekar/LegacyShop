using System.Collections.Generic;
using System.Linq;

namespace Ecommerce.Core.ViewModels
{
    public class CartViewModel
    {
        public CartViewModel() { Items = new List<CartItemViewModel>(); }
        public IList<CartItemViewModel> Items { get; set; }
        public decimal Subtotal { get { return Items.Sum(x => x.Price * x.Quantity); } }
        public int ItemCount { get { return Items.Sum(x => x.Quantity); } }
    }

    public class CartItemViewModel
    {
        public int ProductId { get; set; }
        public string Name { get; set; }
        public decimal Price { get; set; }
        public int Quantity { get; set; }
        public string ThumbnailUrl { get; set; }
    }
}
