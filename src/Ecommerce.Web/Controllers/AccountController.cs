using System.Web.Mvc;
using Ecommerce.Core.ViewModels;
using Ecommerce.Web.Infrastructure;

namespace Ecommerce.Web.Controllers
{
    public class AccountController : Controller
    {
        [HttpGet]
        public ActionResult CustomerLogin() { return View(new LoginViewModel()); }

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

        public ActionResult Logout()
        {
            Session.Clear();
            Session.Abandon();
            return RedirectToAction("Index", "Home");
        }
    }
}
