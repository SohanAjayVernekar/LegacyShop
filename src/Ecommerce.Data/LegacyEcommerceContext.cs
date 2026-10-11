using System;
using System.Data.Entity;
using Ecommerce.Core.Entities;

namespace Ecommerce.Data
{
    public class LegacyEcommerceContext : DbContext
    {
        static LegacyEcommerceContext()
        {
            Database.SetInitializer<LegacyEcommerceContext>(null);
        }

        public LegacyEcommerceContext() : base(BuildConnectionString()) { }

        private static string BuildConnectionString()
        {
            var host = Environment.GetEnvironmentVariable("LEGACYSHOP_DB_HOST") ?? "localhost";
            var port = Environment.GetEnvironmentVariable("LEGACYSHOP_DB_PORT") ?? "14330";
            var database = Environment.GetEnvironmentVariable("LEGACYSHOP_DB_NAME") ?? "LegacyEcommerceDb";
            var user = Environment.GetEnvironmentVariable("LEGACYSHOP_DB_USER") ?? "sa";
            var password = Environment.GetEnvironmentVariable("LEGACYSHOP_DB_PASSWORD") ?? "";

            return "Server=" + host + "," + port
                 + ";Database=" + database
                 + ";User Id=" + user
                 + ";Password=" + password
                 + ";MultipleActiveResultSets=True;TrustServerCertificate=True;";
        }

        public DbSet<Category> Categories { get; set; }
        public DbSet<Product> Products { get; set; }
        public DbSet<ProductImage> ProductImages { get; set; }
        public DbSet<ProductVariant> ProductVariants { get; set; }
        public DbSet<Customer> Customers { get; set; }
        public DbSet<Address> Addresses { get; set; }
        public DbSet<Order> Orders { get; set; }
        public DbSet<OrderLine> OrderLines { get; set; }
        public DbSet<AppUser> AppUsers { get; set; }

        protected override void OnModelCreating(DbModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Category>().ToTable("Categories");
            modelBuilder.Entity<Product>().ToTable("Products");
            modelBuilder.Entity<ProductImage>().ToTable("ProductImages");
            modelBuilder.Entity<ProductVariant>().ToTable("ProductVariants");
            modelBuilder.Entity<Customer>().ToTable("Customers");
            modelBuilder.Entity<Address>().ToTable("Addresses");
            modelBuilder.Entity<Order>().ToTable("Orders");
            modelBuilder.Entity<OrderLine>().ToTable("OrderLines");
            modelBuilder.Entity<AppUser>().ToTable("AppUsers");

            modelBuilder.Entity<Product>()
                .HasRequired(x => x.Category)
                .WithMany(x => x.Products)
                .HasForeignKey(x => x.CategoryId)
                .WillCascadeOnDelete(false);

            modelBuilder.Entity<ProductImage>()
                .HasRequired(x => x.Product)
                .WithMany(x => x.Images)
                .HasForeignKey(x => x.ProductId);

            modelBuilder.Entity<ProductVariant>()
                .HasRequired(x => x.Product)
                .WithMany(x => x.Variants)
                .HasForeignKey(x => x.ProductId);

            modelBuilder.Entity<Address>()
                .HasRequired(x => x.Customer)
                .WithMany(x => x.Addresses)
                .HasForeignKey(x => x.CustomerId);

            modelBuilder.Entity<Order>()
                .HasRequired(x => x.Customer)
                .WithMany(x => x.Orders)
                .HasForeignKey(x => x.CustomerId)
                .WillCascadeOnDelete(false);

            modelBuilder.Entity<OrderLine>()
                .HasRequired(x => x.Order)
                .WithMany(x => x.Lines)
                .HasForeignKey(x => x.OrderId);

            modelBuilder.Entity<OrderLine>()
                .HasRequired(x => x.Product)
                .WithMany()
                .HasForeignKey(x => x.ProductId)
                .WillCascadeOnDelete(false);

            modelBuilder.Entity<AppUser>()
                .HasOptional(x => x.Customer)
                .WithMany()
                .HasForeignKey(x => x.CustomerId);

            base.OnModelCreating(modelBuilder);
        }
    }
}
