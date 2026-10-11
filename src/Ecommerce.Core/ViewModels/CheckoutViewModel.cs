using System.ComponentModel.DataAnnotations;

namespace Ecommerce.Core.ViewModels
{
    public class CheckoutViewModel
    {
        [Required] public string FullName { get; set; }
        [Required] public string Line1 { get; set; }
        public string Line2 { get; set; }
        [Required] public string City { get; set; }
        [Required] public string State { get; set; }
        [Required] public string PostalCode { get; set; }
        [Required] public string Country { get; set; }
    }
}
