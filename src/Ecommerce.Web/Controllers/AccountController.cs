using System.Linq;
using System.Security.Cryptography;
using System.Text;
using Ecommerce.Core.Entities;
using Ecommerce.Data;
using System;
using System.Web.Mvc;
using Ecommerce.Core.ViewModels;
using Ecommerce.Web.Infrastructure;

namespace Ecommerce.Web.Controllers
{
    public class AccountController : Controller
    {
        [HttpGet]
        public ActionResult CustomerLogin()
        {
            if (Session["CustomerId"] != null && Convert.ToString(Session["Role"]) == "Customer")
            {
                return RedirectToAction("Dashboard", "Customer");
            }

            return View(new LoginViewModel());
        }

        [HttpPost, ValidateAntiForgeryToken]
        public ActionResult CustomerLogin(LoginViewModel model)
        {
            if (!ModelState.IsValid) return View(model);
            var result = ServiceFactory.Auth().Authenticate(model.Email, model.Password, "Customer");
            if (!result.Success)
            {
                ModelState.AddModelError("", result.Error);
                return View(model);
            }

            Session["UserId"] = result.UserId;
            Session["CustomerId"] = result.CustomerId;
            Session["Role"] = result.Role;
            Session["DisplayName"] = result.DisplayName;
            return RedirectToAction("Dashboard", "Customer");
        }

        [HttpGet]
        public ActionResult Register()
        {
            if (Session["CustomerId"] != null && Convert.ToString(Session["Role"]) == "Customer")
            {
                return RedirectToAction("Dashboard", "Customer");
            }

            return View(new RegisterViewModel());
        }

        [HttpPost, ValidateAntiForgeryToken]
        public ActionResult Register(RegisterViewModel model)
        {
            if (!ModelState.IsValid)
            {
                return View(model);
            }

            var email = (model.Email ?? "").Trim().ToLowerInvariant();
            var fullName = (model.FullName ?? "").Trim();
            var phone = string.IsNullOrWhiteSpace(model.Phone) ? null : model.Phone.Trim();

            using (var db = new LegacyEcommerceContext())
            {
                if (db.AppUsers.Any(x => x.Email == email) ||
                    db.Customers.Any(x => x.Email == email))
                {
                    ModelState.AddModelError("Email", "An account with this email already exists.");
                    return View(model);
                }

                using (var transaction = db.Database.BeginTransaction())
                {
                    try
                    {
                        var customer = new Customer
                        {
                            Email = email,
                            FullName = fullName,
                            Phone = phone,
                            CreatedAt = DateTime.UtcNow,
                            IsActive = true
                        };

                        db.Customers.Add(customer);
                        db.SaveChanges();

                        var user = new AppUser
                        {
                            Email = email,
                            PasswordHash = HashRegistrationPassword(model.Password),
                            Role = "Customer",
                            DisplayName = fullName,
                            CustomerId = customer.Id,
                            IsActive = true,
                            CreatedAt = DateTime.UtcNow
                        };

                        db.AppUsers.Add(user);
                        db.SaveChanges();
                        transaction.Commit();

                        Session["UserId"] = user.Id;
                        Session["CustomerId"] = customer.Id;
                        Session["Role"] = "Customer";
                        Session["DisplayName"] = fullName;

                        return RedirectToAction("Dashboard", "Customer");
                    }
                    catch
                    {
                        transaction.Rollback();
                        ModelState.AddModelError("", "We could not create the account. Please try again.");
                        return View(model);
                    }
                }
            }
        }



        [HttpGet]
        public ActionResult AdminLogin() { return View(new LoginViewModel()); }

        [HttpPost, ValidateAntiForgeryToken]
        public ActionResult AdminLogin(LoginViewModel model)
        {
            if (!ModelState.IsValid) return View(model);
            var result = ServiceFactory.Auth().Authenticate(model.Email, model.Password, "Admin");
            if (!result.Success)
            {
                ModelState.AddModelError("", result.Error);
                return View(model);
            }

            Session["UserId"] = result.UserId;
            Session["Role"] = result.Role;
            Session["DisplayName"] = result.DisplayName;
            return RedirectToAction("Dashboard", "Admin");
        }

        [HttpGet]
        public ActionResult AdminRegister()
        {
            if (Session["UserId"] != null && Convert.ToString(Session["Role"]) == "Admin")
            {
                return RedirectToAction("Dashboard", "Admin");
            }

            return View(new AdminRegisterViewModel());
        }

        [HttpPost, ValidateAntiForgeryToken]
        public ActionResult AdminRegister(AdminRegisterViewModel model)
        {
            if (!ModelState.IsValid)
            {
                return View(model);
            }

            var email = (model.Email ?? "").Trim().ToLowerInvariant();
            var fullName = (model.FullName ?? "").Trim();

            using (var db = new LegacyEcommerceContext())
            {
                if (db.AppUsers.Any(x => x.Email == email))
                {
                    ModelState.AddModelError("Email", "An account with this email already exists.");
                    return View(model);
                }

                var user = new AppUser
                {
                    Email = email,
                    PasswordHash = HashAdminRegistrationPassword(model.Password),
                    Role = "Admin",
                    DisplayName = fullName,
                    CustomerId = null,
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow
                };

                db.AppUsers.Add(user);
                db.SaveChanges();

                Session["UserId"] = user.Id;
                Session["CustomerId"] = null;
                Session["Role"] = "Admin";
                Session["DisplayName"] = fullName;

                return RedirectToAction("Dashboard", "Admin");
            }
        }



        public ActionResult Logout()
        {
            Session.Clear();
            Session.Abandon();
            return RedirectToAction("Index", "Home");
        }

        private static string HashRegistrationPassword(string password)
        {
            using (var sha = SHA256.Create())
            {
                var bytes = Encoding.Unicode.GetBytes("LegacyShop|" + password);
                var hash = sha.ComputeHash(bytes);
                var sb = new StringBuilder(hash.Length * 2);

                foreach (var b in hash)
                {
                    sb.Append(b.ToString("X2"));
                }

                return sb.ToString();
            }
        }



        private static string HashAdminRegistrationPassword(string password)
        {
            using (var sha = SHA256.Create())
            {
                var bytes = Encoding.Unicode.GetBytes("LegacyShop|" + password);
                var hash = sha.ComputeHash(bytes);
                var sb = new StringBuilder(hash.Length * 2);

                foreach (var b in hash)
                {
                    sb.Append(b.ToString("X2"));
                }

                return sb.ToString();
            }
        }


    }
}
