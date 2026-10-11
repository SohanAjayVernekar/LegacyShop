using System.Collections.Generic;
using System.Linq;
using System.Web;
using Ecommerce.Core.ViewModels;

namespace Ecommerce.Web.Infrastructure
{
    public class SessionCart
    {
        private const string Key = "LegacyShop.Cart";
        private readonly HttpSessionStateBase _session;

        public SessionCart(HttpSessionStateBase session)
        {
            _session = session;
        }

        public IList<CartItemViewModel> Items
        {
            get
            {
                var items = _session[Key] as List<CartItemViewModel>;

                if (items == null)
                {
                    items = new List<CartItemViewModel>();
                    _session[Key] = items;
                }

                return items;
            }
        }

        public void Add(ProductDetailViewModel product, int quantity)
        {
            if (quantity < 1)
                quantity = 1;

            var item = Items.FirstOrDefault(x => x.ProductId == product.Id);

            if (item == null)
            {
                Items.Add(new CartItemViewModel
                {
                    ProductId = product.Id,
                    Name = product.Name,
                    Price = product.Price,
                    Quantity = quantity,
                    ThumbnailUrl = product.Images != null && product.Images.Count > 0
                        ? product.Images[0]
                        : null
                });
            }
            else
            {
                item.Quantity += quantity;
            }

            _session[Key] = Items.ToList();
        }

        public void Update(int productId, int quantity)
        {
            var list = Items.ToList();
            var item = list.FirstOrDefault(x => x.ProductId == productId);

            if (item == null)
                return;

            if (quantity <= 0)
            {
                list.Remove(item);
            }
            else
            {
                item.Quantity = quantity;
            }

            _session[Key] = list;
        }

        public void Remove(int productId)
        {
            _session[Key] = Items
                .Where(x => x.ProductId != productId)
                .ToList();
        }

        public void Clear()
        {
            _session.Remove(Key);
        }

        public CartViewModel ToViewModel()
        {
            return new CartViewModel
            {
                Items = Items.ToList()
            };
        }
    }
}
