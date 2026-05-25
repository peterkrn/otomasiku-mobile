# Spec 04 — Product Catalog: List, Search, Filter, Pagination

| Field | Value |
|-------|-------|
| **Phase** | 3 — Backend Integration |
| **Priority** | High |
| **Status** | ⬜ Draft |
| **Depends On** | 01, 02, 03 |
| **API Endpoints** | `GET /api/products`, `GET /api/products/:id`, `GET /api/brands`, `GET /api/categories` |

---

## Scope

Replace dummy product data with real API calls. Implement infinite scroll pagination, debounced search, category/brand filter chips, and product detail screen wired to real data.

---

## Modified Files

```
lib/providers/product_provider.dart   # Replace dummy → FutureProvider + pagination
lib/features/home/                    # Wire home screen to real providers
lib/features/product_detail/          # Wire product detail to real API
```

---

## API Reference

### `GET /api/products`
```
Query: ?search=FR-A820&brand=mitsubishi&category=inverter&page=1&pageSize=20
Response: {
  "success": true,
  "data": {
    "data": [Product],
    "total": 125,
    "page": 1,
    "pageSize": 20
  }
}
```

### `GET /api/products/:id`
```
Response: { "success": true, "data": Product }
Error: 404 → { "error": { "code": "PRODUCT_NOT_FOUND" } }
```

---

## Acceptance Criteria

### AC-1: Product grid loads from API
```gherkin
Given the user is on the home screen
When the screen loads
Then GET /api/products?page=1&pageSize=20 is called
And a 2-column product grid is displayed with real data
And each card shows: primary image (Supabase Storage URL via cached_network_image), name, price, stock badge
And prices use CurrencyFormatter ("Rp X.XXX.XXX")
```

### AC-2: Infinite scroll loads next page
```gherkin
Given the user is on the home screen with 20 products loaded
When the user scrolls to the bottom of the list
Then GET /api/products?page=2&pageSize=20 is called
And the next 20 products are appended to the grid
And a loading indicator appears at the bottom while fetching
When all products are loaded (total reached)
Then no more requests are made
```

### AC-3: Search is debounced and calls API
```gherkin
Given the user is on the home screen
When the user types "FR-A840" in the search bar
Then after 300ms of no typing, GET /api/products?search=FR-A840&page=1 is called
And the grid resets to page 1 with filtered results
When the user clears the search
Then GET /api/products?page=1 is called (no search param)
```

### AC-4: Category filter chip calls API
```gherkin
Given the user taps the "Inverter" chip
Then GET /api/products?category=inverter&page=1 is called
And the grid resets to page 1 with only inverter products
And the "Inverter" chip is visually active (red background)
When the user taps "Semua"
Then GET /api/products?page=1 is called with no category filter
```

### AC-5: Brand filter chip calls API
```gherkin
Given the user taps the "Mitsubishi" chip
Then GET /api/products?brand=mitsubishi&page=1 is called
And combined with active category filter if any
```

### AC-6: Product detail loads from API
```gherkin
Given the user taps a product card
When the product detail screen opens
Then GET /api/products/:id is called
And the screen shows: image gallery (swipeable), name, SKU, brand, series, variant, price, stock, description
And the description shown matches the current locale (descriptionId or descriptionEn)
```

### AC-7: Loading and error states
```gherkin
Given the API is slow
When the product list is loading
Then a shimmer placeholder grid is shown (not a spinner)
Given the API returns an error
When the product list fails to load
Then an error view is shown with a "Coba Lagi" retry button
And the error message is localized (not raw server text)
```

### AC-8: Pull-to-refresh
```gherkin
Given the user is on the home screen
When the user pulls down to refresh
Then the product list resets to page 1 and re-fetches
And the filter/search state is preserved
```

---

## Provider Design

```dart
// Filter state
final productFilterProvider = StateProvider<ProductFilter>((ref) => const ProductFilter());

// Paginated product list — uses AsyncNotifier for append-on-scroll
final productListProvider = AsyncNotifierProvider<ProductListNotifier, List<Product>>(
  ProductListNotifier.new,
);

class ProductListNotifier extends AsyncNotifier<List<Product>> {
  int _page = 1;
  bool _hasMore = true;

  @override
  Future<List<Product>> build() async {
    // Watch filter — reset on filter change
    ref.watch(productFilterProvider);
    _page = 1;
    _hasMore = true;
    return _fetchPage(1);
  }

  Future<void> loadMore() async { /* append next page */ }
  Future<void> refresh() async { /* reset to page 1 */ }

  Future<List<Product>> _fetchPage(int page) async {
    final filter = ref.read(productFilterProvider);
    final result = await ref.read(productRepositoryProvider).getProducts(filter.copyWith(page: page));
    _hasMore = result.data.length < result.total;
    return result.data;
  }
}

// Product detail — scoped to product ID
final productDetailProvider = FutureProvider.autoDispose.family<Product, String>((ref, id) {
  return ref.read(productRepositoryProvider).getProductById(id);
});

// Brands and categories for filter chips — cached
final brandsProvider = FutureProvider<List<Brand>>((ref) {
  return ref.read(productRepositoryProvider).getBrands();
});
final categoriesProvider = FutureProvider<List<Category>>((ref) {
  return ref.read(productRepositoryProvider).getCategories();
});
```

---

## Image Loading

Product images are hosted on Supabase Storage CDN. Use `cached_network_image`:

```dart
CachedNetworkImage(
  imageUrl: product.primaryImageUrl,
  placeholder: (context, url) => const ShimmerBox(),
  errorWidget: (context, url, error) => const Icon(Icons.image_not_supported),
  fit: BoxFit.cover,
)
```

---

## Verification Checklist

- [ ] Home screen loads real products from API
- [ ] Infinite scroll appends products correctly
- [ ] Search debounce 300ms — no API call on every keystroke
- [ ] Category + brand filters reset pagination to page 1
- [ ] Combined filters work (category + brand + search)
- [ ] Product detail shows correct locale description
- [ ] Shimmer shown during loading (not spinner)
- [ ] Error state shows retry button
- [ ] Pull-to-refresh works
- [ ] `dummy_products.dart` no longer imported in providers
- [ ] `cached_network_image` used for all product images
- [ ] `flutter analyze` clean
