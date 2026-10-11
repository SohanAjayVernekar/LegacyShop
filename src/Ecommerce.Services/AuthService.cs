using System;
using System.Security.Cryptography;
using System.Text;
using Ecommerce.Core.Interfaces.Repositories;
using Ecommerce.Core.Interfaces.Services;

namespace Ecommerce.Services
{
    public class AuthService : IAuthService
    {
        private readonly IUserRepository _users;
        public AuthService(IUserRepository users) { _users = users; }

        public AuthResult Authenticate(string email, string password, string requiredRole)
        {
            if (string.IsNullOrWhiteSpace(email) || string.IsNullOrEmpty(password))
                return new AuthResult { Success = false, Error = "Email and password are required." };

            email = email.Trim().ToLowerInvariant();
            var user = _users.FindActiveByEmail(email);

            if (user == null || !string.Equals(user.Role, requiredRole, StringComparison.OrdinalIgnoreCase))
                return new AuthResult { Success = false, Error = "Invalid credentials." };

            var actualHash = HashPassword(password);
            if (!string.Equals(actualHash, user.PasswordHash, StringComparison.OrdinalIgnoreCase))
                return new AuthResult { Success = false, Error = "Invalid credentials." };

            return new AuthResult
            {
                Success = true,
                UserId = user.Id,
                CustomerId = user.CustomerId,
                Role = user.Role,
                DisplayName = user.DisplayName
            };
        }

        private static string HashPassword(string password)
        {
            using (var sha = SHA256.Create())
            {
                var bytes = Encoding.Unicode.GetBytes("LegacyShop|" + password);
                var hash = sha.ComputeHash(bytes);
                var sb = new StringBuilder(hash.Length * 2);
                foreach (var b in hash) sb.Append(b.ToString("X2"));
                return sb.ToString();
            }
        }
    }
}
