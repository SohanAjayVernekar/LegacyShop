using System;
using System.Linq;
using System.Text.RegularExpressions;
using System.Web.Mvc;
using Ecommerce.Core.Entities;
using Ecommerce.Core.ViewModels;
using Ecommerce.Data;
using Ecommerce.Web.Infrastructure;

namespace Ecommerce.Web.Controllers
{
    [SessionRoleAuthorize("Admin")]
    public class AdminController : Controller
    {
        public ActionResult Dashboard()
        {
            return View(ServiceFactory.Orders().GetAdminDashboard());
        }

        public ActionResult Products()
        {
            var model = ServiceFactory.Catalog().GetAdminProducts();

            using (var db = new LegacyEcommerceContext())
            {
                ViewBag.CategoryNames = db.Categories
                    .ToDictionary(x => x.Id, x => x.Name);
            }

            return View(model);
        }

        [HttpGet]
        public ActionResult ProductCreate()
        {
            LoadCategories();
            return View("ProductEdit", new AdminProductViewModel { IsActive = true });
        }

        [HttpPost, ValidateAntiForgeryToken]
        public ActionResult ProductCreate(AdminProductViewModel model)
        {
            if (!ModelState.IsValid)
            {
                LoadCategories();
                return View("ProductEdit", model);
            }

            ServiceFactory.Catalog().SaveAdminProduct(model);
            return RedirectToAction("Products");
        }

        [HttpGet]
        public ActionResult ProductEdit(int id)
        {
            var model = ServiceFactory.Catalog().GetAdminProduct(id);
            if (model == null) return HttpNotFound();

            LoadCategories();
            return View(model);
        }

        [HttpPost, ValidateAntiForgeryToken]
        public ActionResult ProductEdit(AdminProductViewModel model)
        {
            if (!ModelState.IsValid)
            {
                LoadCategories();
                return View(model);
            }

            ServiceFactory.Catalog().SaveAdminProduct(model);
            return RedirectToAction("Products");
        }

        public ActionResult Categories()
        {
            using (var db = new LegacyEcommerceContext())
            {
                var rows = db.Categories
                    .OrderBy(x => x.Name)
                    .ToList();

                ViewBag.ProductCounts = db.Products
                    .GroupBy(x => x.CategoryId)
                    .Select(g => new { CategoryId = g.Key, Count = g.Count() })
                    .ToDictionary(x => x.CategoryId, x => x.Count);

                return View(rows);
            }
        }

        [HttpPost, ValidateAntiForgeryToken]
        public ActionResult CategoryCreate(string name)
        {
            name = (name ?? "").Trim();

            if (name.Length < 2)
            {
                TempData["AdminMessage"] = "Enter a category name.";
                return RedirectToAction("Categories");
            }

            using (var db = new LegacyEcommerceContext())
            {
                var slugBase = Slugify(name);
                var slug = slugBase;
                var suffix = 2;

                while (db.Categories.Any(x => x.Slug == slug))
                {
                    slug = slugBase + "-" + suffix;
                    suffix++;
                }

                db.Categories.Add(new Category
                {
                    Name = name,
                    Slug = slug,
                    IsActive = true
                });

                db.SaveChanges();
            }

            TempData["AdminMessage"] = "Category created.";
            return RedirectToAction("Categories");
        }

        [HttpPost, ValidateAntiForgeryToken]
        public ActionResult CategoryToggle(int id)
        {
            using (var db = new LegacyEcommerceContext())
            {
                var category = db.Categories.FirstOrDefault(x => x.Id == id);
                if (category == null) return HttpNotFound();

                category.IsActive = !category.IsActive;
                db.SaveChanges();
            }

            return RedirectToAction("Categories");
        }

        public ActionResult Orders()
        {
            using (var db = new LegacyEcommerceContext())
            {
                var rows = db.Orders
                    .Include("Customer")
                    .OrderByDescending(x => x.CreatedAt)
                    .Take(200)
                    .ToList();

                return View(rows);
            }
        }

        [HttpPost, ValidateAntiForgeryToken]
        public ActionResult OrderStatus(int id, string status)
        {
            var allowed = new[] { "Processing", "Packed", "Shipped", "Delivered", "Cancelled" };

            if (!allowed.Contains(status))
                return RedirectToAction("Orders");

            using (var db = new LegacyEcommerceContext())
            {
                var order = db.Orders.FirstOrDefault(x => x.Id == id);
                if (order == null) return HttpNotFound();

                order.Status = status;
                db.SaveChanges();
            }

            return RedirectToAction("Orders");
        }

        public ActionResult Customers()
        {
            using (var db = new LegacyEcommerceContext())
            {
                var rows = db.Customers
                    .OrderByDescending(x => x.CreatedAt)
                    .Take(300)
                    .ToList();

                ViewBag.OrderCounts = db.Orders
                    .GroupBy(x => x.CustomerId)
                    .Select(g => new { CustomerId = g.Key, Count = g.Count() })
                    .ToDictionary(x => x.CustomerId, x => x.Count);

                return View(rows);
            }
        }

        [HttpPost, ValidateAntiForgeryToken]
        public ActionResult CustomerToggle(int id)
        {
            using (var db = new LegacyEcommerceContext())
            {
                var customer = db.Customers.FirstOrDefault(x => x.Id == id);
                if (customer == null) return HttpNotFound();

                customer.IsActive = !customer.IsActive;
                db.SaveChanges();
            }

            return RedirectToAction("Customers");
        }

        public ActionResult Inventory()
        {
            using (var db = new LegacyEcommerceContext())
            {
                var rows = db.Products
                    .Include("Category")
                    .OrderBy(x => x.StockQuantity)
                    .ThenBy(x => x.Name)
                    .Take(300)
                    .ToList();

                ViewBag.TotalProducts = db.Products.Count(x => x.IsActive);
                ViewBag.LowStock = db.Products.Count(x => x.IsActive && x.StockQuantity <= 10);
                ViewBag.OutOfStock = db.Products.Count(x => x.IsActive && x.StockQuantity <= 0);

                return View(rows);
            }
        }

        [HttpPost, ValidateAntiForgeryToken]
        public ActionResult InventoryAdjust(int id, int stockQuantity)
        {
            if (stockQuantity < 0) stockQuantity = 0;

            using (var db = new LegacyEcommerceContext())
            {
                var product = db.Products.FirstOrDefault(x => x.Id == id);
                if (product == null) return HttpNotFound();

                product.StockQuantity = stockQuantity;
                db.SaveChanges();
            }

            return RedirectToAction("Inventory");
        }

        public ActionResult Reports()
        {
            using (var db = new LegacyEcommerceContext())
            {
                var orders = db.Orders.ToList();

                ViewBag.TotalSales = orders.Sum(x => (decimal?)x.TotalAmount) ?? 0m;
                ViewBag.TotalOrders = orders.Count;
                ViewBag.DeliveredOrders = orders.Count(x => x.Status == "Delivered");
                ViewBag.AverageOrder = orders.Count == 0 ? 0m : orders.Average(x => x.TotalAmount);
                ViewBag.TotalCustomers = db.Customers.Count();
                ViewBag.ActiveProducts = db.Products.Count(x => x.IsActive);
                ViewBag.LowStock = db.Products.Count(x => x.IsActive && x.StockQuantity <= 10);

                var topCategory = (
                    from p in db.Products
                    join c in db.Categories on p.CategoryId equals c.Id
                    where p.IsActive
                    group p by c.Name into g
                    orderby g.Count() descending
                    select new
                    {
                        Name = g.Key,
                        Count = g.Count()
                    }
                ).FirstOrDefault();

                ViewBag.TopCategory = topCategory == null ? "N/A" : topCategory.Name;
                ViewBag.TopCategoryCount = topCategory == null ? 0 : topCategory.Count;
            }

            return View();
        }

        [HttpGet]
        public ActionResult Settings()
        {
            ViewBag.StoreName = Session["AdminStoreName"] ?? "LegacyShop";
            ViewBag.StoreEmail = Session["AdminStoreEmail"] ?? "admin@legacyshop.local";
            ViewBag.LowStockThreshold = Session["AdminLowStockThreshold"] ?? 10;
            ViewBag.MaintenanceMode = Session["AdminMaintenanceMode"] ?? false;
            ViewBag.Saved = TempData["AdminSettingsSaved"];

            return View();
        }

        [HttpPost, ValidateAntiForgeryToken]
        public ActionResult Settings(string storeName, string storeEmail, int lowStockThreshold = 10, bool maintenanceMode = false)
        {
            if (string.IsNullOrWhiteSpace(storeName))
                storeName = "LegacyShop";

            if (lowStockThreshold < 0)
                lowStockThreshold = 0;

            Session["AdminStoreName"] = storeName.Trim();
            Session["AdminStoreEmail"] = (storeEmail ?? "").Trim();
            Session["AdminLowStockThreshold"] = lowStockThreshold;
            Session["AdminMaintenanceMode"] = maintenanceMode;

            TempData["AdminSettingsSaved"] = "Settings saved for this demo session.";
            return RedirectToAction("Settings");
        }

        private void LoadCategories()
        {
            using (var db = new LegacyEcommerceContext())
            {
                ViewBag.Categories = new SelectList(
                    db.Categories
                        .Where(x => x.IsActive)
                        .OrderBy(x => x.Name)
                        .ToList(),
                    "Id",
                    "Name"
                );
            }
        }

        private static string Slugify(string value)
        {
            value = (value ?? "").Trim().ToLowerInvariant();
            value = Regex.Replace(value, @"[^a-z0-9]+", "-");
            value = value.Trim('-');

            return string.IsNullOrEmpty(value)
                ? "category-" + DateTime.UtcNow.Ticks
                : value;
        }
    }
}
