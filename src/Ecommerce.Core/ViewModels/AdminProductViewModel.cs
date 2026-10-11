using System.ComponentModel.DataAnnotations;

namespace Ecommerce.Core.ViewModels
{
    public class AdminProductViewModel
    {
        public int Id { get; set; }
        [Required] public int CategoryId { get; set; }
        [Required] public string Name { get; set; }
        [Required] public string Slug { get; set; }
        public string Description { get; set; }
        [Range(0.01, 99999999)] public decimal Price { get; set; }
        [Range(0, 999999)] public int StockQuantity { get; set; }
        public bool IsFeatured { get; set; }
        public bool IsActive { get; set; }
    }
}
