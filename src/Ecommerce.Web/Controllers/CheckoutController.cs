using System;
using System.Web.Mvc;
using Ecommerce.Core.ViewModels;
using Ecommerce.Web.Infrastructure;

namespace Ecommerce.Web.Controllers
{
    [SessionRoleAuthorize("Customer")]
    public class CheckoutController : Controller
    {
        [HttpGet]
        public ActionResult Index()
        {
            var cart = new SessionCart(Session);

            if (cart.Items.Count == 0)
                return RedirectToAction("Index", "Cart");

            ViewBag.Cart = cart.ToViewModel();

            return View(new CheckoutViewModel
            {
                Country = "India"
            });
        }

        [HttpPost, ValidateAntiForgeryToken]
        public ActionResult Index(CheckoutViewModel model)
        {
            var cart = new SessionCart(Session);

            if (!ModelState.IsValid)
            {
                ViewBag.Cart = cart.ToViewModel();
                return View(model);
            }

            if (cart.Items.Count == 0)
            {
                ModelState.AddModelError("", "Your cart is empty.");
                ViewBag.Cart = cart.ToViewModel();
                return View(model);
            }

            try
            {
                var customerId = Convert.ToInt32(Session["CustomerId"]);

                var orderId = ServiceFactory.Orders()
                    .PlaceOrder(customerId, model, cart.Items);

                cart.Clear();

                return RedirectToAction("Success", new { id = orderId });
            }
            catch (Exception ex)
            {
                ModelState.AddModelError("", ex.Message);
                ViewBag.Cart = cart.ToViewModel();
                return View(model);
            }
        }

        public ActionResult Success(int id)
        {
            ViewBag.OrderId = id;
            return View();
        }
    }
}
