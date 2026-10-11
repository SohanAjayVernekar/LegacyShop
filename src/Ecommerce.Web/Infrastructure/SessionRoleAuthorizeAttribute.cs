using System;
using System.Web.Mvc;

namespace Ecommerce.Web.Infrastructure
{
    public class SessionRoleAuthorizeAttribute : AuthorizeAttribute
    {
        private readonly string _role;
        public SessionRoleAuthorizeAttribute(string role) { _role = role; }

        protected override bool AuthorizeCore(System.Web.HttpContextBase httpContext)
        {
            if (httpContext == null || httpContext.Session == null) return false;
            var role = httpContext.Session["Role"] as string;
            return string.Equals(role, _role, StringComparison.OrdinalIgnoreCase);
        }

        protected override void HandleUnauthorizedRequest(AuthorizationContext filterContext)
        {
            var controller = string.Equals(_role, "Admin", StringComparison.OrdinalIgnoreCase) ? "AdminLogin" : "CustomerLogin";
            filterContext.Result = new RedirectToRouteResult(
                new System.Web.Routing.RouteValueDictionary(new { controller = "Account", action = controller })
            );
        }
    }
}
