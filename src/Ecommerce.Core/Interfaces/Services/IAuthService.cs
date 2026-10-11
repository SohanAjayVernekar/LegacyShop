namespace Ecommerce.Core.Interfaces.Services
{
    public interface IAuthService
    {
        AuthResult Authenticate(string email, string password, string requiredRole);
    }

    public class AuthResult
    {
        public bool Success { get; set; }
        public string Error { get; set; }
        public int UserId { get; set; }
        public int? CustomerId { get; set; }
        public string Role { get; set; }
        public string DisplayName { get; set; }
    }
}
