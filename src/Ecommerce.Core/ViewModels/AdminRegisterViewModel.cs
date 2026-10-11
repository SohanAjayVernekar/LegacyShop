using System.ComponentModel.DataAnnotations;

namespace Ecommerce.Core.ViewModels
{
    public class AdminRegisterViewModel
    {
        [Required]
        [StringLength(160, MinimumLength = 2)]
        public string FullName { get; set; }

        [Required]
        [EmailAddress]
        [StringLength(256)]
        public string Email { get; set; }

        [Required]
        [DataType(DataType.Password)]
        [StringLength(100, MinimumLength = 6)]
        public string Password { get; set; }

        [Required]
        [DataType(DataType.Password)]
        [Compare("Password", ErrorMessage = "Passwords do not match.")]
        public string ConfirmPassword { get; set; }
    }
}
