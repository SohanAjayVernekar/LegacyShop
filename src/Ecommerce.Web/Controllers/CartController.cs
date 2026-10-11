using System.Web.Mvc;
using Ecommerce.Web.Infrastructure;

namespace Ecommerce.Web.Controllers
{
    public class CartController : Controller
    {
        public ActionResult Index()
        {
            return View(new SessionCart(Session).ToViewModel());
        }

        [HttpPost, ValidateAntiForgeryToken]
        public ActionResult Add(int productId, int quantity = 1)
        {
            var product = ServiceFactory.Catalog().GetDetail(productId);

            if (product == null)
                return HttpNotFound();

            if (quantity > product.StockQuantity)
                quantity = product.StockQuantity;

            if (quantity < 1)
                quantity = 1;

            new SessionCart(Session).Add(product, quantity);

            return RedirectToAction("Index");
        }

        [HttpPost, ValidateAntiForgeryToken]
        public ActionResult Update(int productId, int quantity)
        {
            var product = ServiceFactory.Catalog().GetDetail(productId);

            if (product == null)
                return HttpNotFound();

            if (quantity > product.StockQuantity)
                quantity = product.StockQuantity;

            new SessionCart(Session).Update(productId, quantity);

            return RedirectToAction("Index");
        }

        [HttpPost, ValidateAntiForgeryToken]
        public ActionResult Remove(int productId)
        {
            new SessionCart(Session).Remove(productId);
            return RedirectToAction("Index");
        }

        [HttpPost, ValidateAntiForgeryToken]
        public ActionResult Clear()
        {
            new SessionCart(Session).Clear();
            return RedirectToAction("Index");
        }
    }
}
