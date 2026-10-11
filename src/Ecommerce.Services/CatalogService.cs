using System;
using System.Collections.Generic;
using System.Linq;
using Ecommerce.Core.Entities;
using Ecommerce.Core.Interfaces.Repositories;
using Ecommerce.Core.Interfaces.Services;
using Ecommerce.Core.ViewModels;

namespace Ecommerce.Services
{
    public class CatalogService : ICatalogService
    {
        private readonly IProductRepository _products;
        private readonly ICategoryRepository _categories;

        public CatalogService(IProductRepository products, ICategoryRepository categories)
        {
            _products = products;
            _categories = categories;
        }

        public ProductListViewModel GetListing(int? categoryId, string query, int page)
        {
            if (page < 1) page = 1;
            const int pageSize = 24;

            int totalCount;

            var rows = _products.Search(categoryId, query, page, pageSize, out totalCount);

            var vm = new ProductListViewModel
            {
                CategoryId = categoryId,
                Query = query,
                Page = page,
                PageSize = pageSize,
                TotalCount = totalCount
            };

            vm.Categories = _categories.GetActive()
                .Select(x => new CategoryOptionViewModel
                {
                    Id = x.Id,
                    Name = x.Name
                })
                .ToList();

            vm.Products = rows
                .Select(x => new ProductCardViewModel
                {
                    Id = x.Id,
                    Name = x.Name,
                    CategoryName = x.Category == null ? "" : x.Category.Name,
                    Price = x.Price,
                    ThumbnailUrl = x.ThumbnailUrl,
                    StockQuantity = x.StockQuantity
                })
                .ToList();

            return vm;
        }

        public ProductDetailViewModel GetDetail(int productId)
        {
            var p = _products.GetById(productId);
            if (p == null) return null;

            return new ProductDetailViewModel
            {
                Id = p.Id,
                Name = p.Name,
                CategoryName = p.Category == null ? "" : p.Category.Name,
                Description = p.Description,
                Price = p.Price,
                StockQuantity = p.StockQuantity,
                Images = p.Images.OrderBy(x => x.SortOrder).Select(x => x.ImageUrl).ToList(),
                Variants = p.Variants.Select(x => new ProductVariantViewModel
                {
                    Id = x.Id,
                    Name = x.Name,
                    PriceAdjustment = x.PriceAdjustment,
                    StockQuantity = x.StockQuantity
                }).ToList()
            };
        }

        public IList<AdminProductViewModel> GetAdminProducts()
        {
            return _products.GetAllForAdmin().Select(x => new AdminProductViewModel
            {
                Id = x.Id,
                CategoryId = x.CategoryId,
                Name = x.Name,
                Slug = x.Slug,
                Description = x.Description,
                Price = x.Price,
                StockQuantity = x.StockQuantity,
                IsFeatured = x.IsFeatured,
                IsActive = x.IsActive
            }).ToList();
        }

        public AdminProductViewModel GetAdminProduct(int id)
        {
            var p = _products.GetAllForAdmin().FirstOrDefault(x => x.Id == id);
            if (p == null) return null;

            return new AdminProductViewModel
            {
                Id = p.Id,
                CategoryId = p.CategoryId,
                Name = p.Name,
                Slug = p.Slug,
                Description = p.Description,
                Price = p.Price,
                StockQuantity = p.StockQuantity,
                IsFeatured = p.IsFeatured,
                IsActive = p.IsActive
            };
        }

        public void SaveAdminProduct(AdminProductViewModel model)
        {
            if (model.Id == 0)
            {
                _products.Add(new Product
                {
                    CategoryId = model.CategoryId,
                    Name = model.Name,
                    Slug = model.Slug,
                    Description = model.Description,
                    Price = model.Price,
                    StockQuantity = model.StockQuantity,
                    IsFeatured = model.IsFeatured,
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow
                });
                return;
            }

            var p = _products.GetAllForAdmin().FirstOrDefault(x => x.Id == model.Id);
            if (p == null) throw new InvalidOperationException("Product not found.");

            p.CategoryId = model.CategoryId;
            p.Name = model.Name;
            p.Slug = model.Slug;
            p.Description = model.Description;
            p.Price = model.Price;
            p.StockQuantity = model.StockQuantity;
            p.IsFeatured = model.IsFeatured;
            p.IsActive = model.IsActive;

            _products.Update(p);
        }
    }
}
