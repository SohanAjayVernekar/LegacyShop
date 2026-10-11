namespace Ecommerce.Core.Entities
{
    public class ProductImage
    {
        public int Id { get; set; }
        public int ProductId { get; set; }
        public string ImageUrl { get; set; }
        public int SortOrder { get; set; }
        public virtual Product Product { get; set; }
    }
}
