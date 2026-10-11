using System.Web.Mvc;
using Ecommerce.Web.Infrastructure;

namespace Ecommerce.Web.Controllers
{
    public class ProductController : Controller
    {
        public ActionResult Index(int? categoryId, string q, int page = 1)
        {
            return View(ServiceFactory.Catalog().GetListing(categoryId, q, page));
        }

        public ActionResult Detail(int id)
        {
            var vm = ServiceFactory.Catalog().GetDetail(id);
            if (vm == null) return HttpNotFound();

            return View(vm);
        }
    }
}
