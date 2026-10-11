using System;

namespace Ecommerce.Core.Entities
{
    public class AppUser
    {
        public int Id { get; set; }
        public string Email { get; set; }
        public string PasswordHash { get; set; }
        public string Role { get; set; }
        public string DisplayName { get; set; }
        public int? CustomerId { get; set; }
        public bool IsActive { get; set; }
        public DateTime CreatedAt { get; set; }

        public virtual Customer Customer { get; set; }
    }
}
