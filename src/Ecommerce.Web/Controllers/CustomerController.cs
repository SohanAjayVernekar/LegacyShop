using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Web.Mvc;
using Ecommerce.Core.Entities;
using Ecommerce.Data;
using Ecommerce.Web.Infrastructure;

namespace Ecommerce.Web.Controllers
{
    [SessionRoleAuthorize("Customer")]
    public class CustomerController : Controller
    {
        public ActionResult Dashboard()
        {
            var customerId = Convert.ToInt32(Session["CustomerId"]);
            var displayName = Session["DisplayName"] as string ?? "Customer";

            return View(
                ServiceFactory.Orders()
                    .GetCustomerDashboard(customerId, displayName)
            );
        }

        public ActionResult Orders()
        {
            var customerId = CurrentCustomerId();

            using (var db = new LegacyEcommerceContext())
            {
                var orders = db.Orders
                    .Include(x => x.Lines)
                    .Where(x => x.CustomerId == customerId)
                    .OrderByDescending(x => x.CreatedAt)
                    .ToList();

                return View(orders);
            }
        }

        public ActionResult Wishlist()
        {
            var ids = WishlistIds();

            using (var db = new LegacyEcommerceContext())
            {
                var saved = ids.Count == 0
                    ? new List<Product>()
                    : db.Products
                        .Include(x => x.Category)
                        .Where(x => ids.Contains(x.Id) && x.IsActive)
                        .OrderBy(x => x.Name)
                        .ToList();

                var savedIds = saved.Select(x => x.Id).ToList();

                ViewBag.Suggestions = db.Products
                    .Include(x => x.Category)
                    .Where(x => x.IsActive && !savedIds.Contains(x.Id))
                    .OrderByDescending(x => x.IsFeatured)
                    .ThenByDescending(x => x.CreatedAt)
                    .Take(8)
                    .ToList();

                return View(saved);
            }
        }

        [HttpPost, ValidateAntiForgeryToken]
        public ActionResult WishlistAdd(int productId)
        {
            var ids = WishlistIds();

            if (!ids.Contains(productId))
                ids.Add(productId);

            Session["WishlistIds"] = ids;

            return RedirectToAction("Wishlist");
        }

        [HttpPost, ValidateAntiForgeryToken]
        public ActionResult WishlistRemove(int productId)
        {
            var ids = WishlistIds();
            ids.Remove(productId);
            Session["WishlistIds"] = ids;

            return RedirectToAction("Wishlist");
        }

        public ActionResult Addresses()
        {
            var customerId = CurrentCustomerId();

            using (var db = new LegacyEcommerceContext())
            {
                var addresses = db.Addresses
                    .Where(x => x.CustomerId == customerId)
                    .OrderByDescending(x => x.IsDefault)
                    .ThenBy(x => x.Label)
                    .ToList();

                return View(addresses);
            }
        }

        [HttpPost, ValidateAntiForgeryToken]
        public ActionResult AddressCreate(
            string label,
            string line1,
            string line2,
            string city,
            string state,
            string postalCode,
            string country)
        {
            var customerId = CurrentCustomerId();

            if (string.IsNullOrWhiteSpace(label) ||
                string.IsNullOrWhiteSpace(line1) ||
                string.IsNullOrWhiteSpace(city) ||
                string.IsNullOrWhiteSpace(state) ||
                string.IsNullOrWhiteSpace(postalCode) ||
                string.IsNullOrWhiteSpace(country))
            {
                TempData["CustomerMessage"] = "Please complete all required address fields.";
                return RedirectToAction("Addresses");
            }

            using (var db = new LegacyEcommerceContext())
            {
                var hasAddress = db.Addresses.Any(x => x.CustomerId == customerId);

                db.Addresses.Add(new Address
                {
                    CustomerId = customerId,
                    Label = label.Trim(),
                    Line1 = line1.Trim(),
                    Line2 = (line2 ?? "").Trim(),
                    City = city.Trim(),
                    State = state.Trim(),
                    PostalCode = postalCode.Trim(),
                    Country = country.Trim(),
                    IsDefault = !hasAddress
                });

                db.SaveChanges();
            }

            TempData["CustomerMessage"] = "Address added.";
            return RedirectToAction("Addresses");
        }

        [HttpPost, ValidateAntiForgeryToken]
        public ActionResult AddressDefault(int id)
        {
            var customerId = CurrentCustomerId();

            using (var db = new LegacyEcommerceContext())
            {
                var rows = db.Addresses
                    .Where(x => x.CustomerId == customerId)
                    .ToList();

                var selected = rows.FirstOrDefault(x => x.Id == id);
                if (selected == null)
                    return HttpNotFound();

                foreach (var address in rows)
                    address.IsDefault = address.Id == id;

                db.SaveChanges();
            }

            return RedirectToAction("Addresses");
        }

        [HttpPost, ValidateAntiForgeryToken]
        public ActionResult AddressDelete(int id)
        {
            var customerId = CurrentCustomerId();

            using (var db = new LegacyEcommerceContext())
            {
                var address = db.Addresses
                    .FirstOrDefault(x => x.Id == id && x.CustomerId == customerId);

                if (address == null)
                    return HttpNotFound();

                var wasDefault = address.IsDefault;

                db.Addresses.Remove(address);
                db.SaveChanges();

                if (wasDefault)
                {
                    var next = db.Addresses
                        .FirstOrDefault(x => x.CustomerId == customerId);

                    if (next != null)
                    {
                        next.IsDefault = true;
                        db.SaveChanges();
                    }
                }
            }

            return RedirectToAction("Addresses");
        }

        private int CurrentCustomerId()
        {
            return Convert.ToInt32(Session["CustomerId"]);
        }

        private List<int> WishlistIds()
        {
            var ids = Session["WishlistIds"] as List<int>;

            if (ids == null)
            {
                ids = new List<int>();
                Session["WishlistIds"] = ids;
            }

            return ids;
        }
    }
}
