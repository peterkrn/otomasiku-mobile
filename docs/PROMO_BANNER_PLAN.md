# Promo Banner Management — Implementation Plan

## Current State

3 hardcoded banners in `lib/features/home/widgets/hero_banner.dart:38-60` — can only change via app release.

| Badge | Title | Category Slug | Gradient |
|-------|-------|---------------|----------|
| `'New Arrival'` | `'Melsec iQ-R Series'` | `'plc'` | Dark slate -> Mitsubishi red |
| `'Best Seller'` | `'FR-E800 Series'` | `'inverter'` | Dark blue -> Teal |
| `'Promo'` | `'GOT2000 Series'` | `'hmi'` | Dark purple -> Violet |

When tapped, they try to match a product in the already-loaded `productListProvider` by category slug, then navigate to detail or fall back to search with that category filter. There is **no backend API, no DB table, no admin UI** for promos.

---

## Option A: Just Update Hardcoded Banners

**Effort: ~5 minutes**

Edit `hero_banner.dart:38-60` to change the 3 banners to match newly seeded products:

| Current | Proposed | Reason |
|---------|----------|--------|
| `Melsec iQ-R Series` → `plc` | `Melsec Q Series` → `plc` | Q Series now exists in DB |
| `FR-E800 Series` → `inverter` | `FR-A800 Series` → `inverter` | FR-A840 is a flagship product |
| `GOT2000 Series` → `hmi` | `GOT GT Series` → `hmi` | Matches seeded HMI products |

### Files to change
- `lib/features/home/widgets/hero_banner.dart` — update `_bannerData` list

### Pros
- Fastest — zero backend changes, no migration, no API work
- No new endpoints, no new DB tables

### Cons
- Requires app release for any promo change
- No admin control whatsoever
- Banner navigation still uses fragile category-matching hack (tries to find a product by category slug from an already-loaded list)

---

## Option B: `is_featured` / `is_promo` Columns on Product

**Effort: 2-3 hours**

Add columns directly to the `products` table so any product can be featured from the admin.

### Database Changes

**Migration** (`prisma/migrations/`):
```prisma
model Product {
  // ... existing columns
  
  is_featured        Boolean  @default(false)
  is_promo           Boolean  @default(false)
  featured_sort_order Int     @default(0)
  promo_badge_text   String?  // "New Arrival", "Best Seller", etc.
  featured_image_url String?  // Optional custom banner image (overrides product image)
}
```

### Backend API

**New endpoint** in `product.handler.ts` + `product.routes.ts`:
```
GET /api/products/featured
```
Returns up to 5 products with `is_featured = true`, ordered by `featured_sort_order`. Response includes:
- Product id, name, slug, price, images
- `is_promo`, `promo_badge_text`
- `featured_image_url` (banner image, falls back to primary product image)

### Mobile App Changes

**New provider** in `lib/providers/product_provider.dart`:
```dart
final featuredProductsProvider = FutureProvider<List<Product>>((ref) async {
  final repo = ref.read(productRepositoryProvider);
  return repo.getFeatured();
});
```

**Updated widget** in `lib/features/home/widgets/hero_banner.dart`:
- Replace static `_bannerData` list with `featuredProductsProvider`
- Render banner background: `featured_image_url` ?? product's primary image
- Badge text: `promo_badge_text` ?? `product.name`
- On tap: navigate to `AppRoute.productDetail` with product slug (no category hack)
- Show shimmer while loading, hide entirely if empty

**Repository method** in `lib/data/repositories/product_repository.dart`:
```dart
Future<List<Product>> getFeatured() async {
  final response = await apiClient.get('/products/featured');
  return (response.data as List).map((json) => Product.fromJson(json)).toList();
}
```

### Admin Changes (otomasiku-admin)

**Product edit page** additions:
- "Feature this product" toggle
- Sort order number field
- Badge text input (e.g. "New Arrival", "Best Seller")
- Optional banner image upload

### Pros
- Simple DB approach — leverages existing Product model
- No new tables, one small migration
- Admin can feature/unfeature any product
- Mobile app becomes dynamic — no hardcoded data

### Cons
- Limited to one image per product (or you must add `featured_image_url`)
- No standalone banners that aren't linked to a product
- Admin needs a way to edit these fields (may need otomasiku-admin changes)

---

## Option C: Dedicated `banners` Table (Full CRUD)

**Effort: 4-6 hours**

A proper `banners` table with admin CRUD, custom images, and flexible linking.

### Database Schema

**New model** in `prisma/schema.prisma`:
```prisma
model Banner {
  id           Int       @id @default(autoincrement())
  title        String
  subtitle     String?
  badge_text   String?                     // "New Arrival", "Best Seller", "Promo"
  image_url    String                      // Banner image in storage
  image_path   String?                     // Storage path for admin management

  // Link to product (optional — banner can link to search page instead)
  product_id   Int?      @map("product_id")
  product      Product?  @relation(fields: [product_id], references: [id], onDelete: SetNull)

  // Fallback link (when no product_id)
  link_type    String?                     // "category" | "search" | "none"
  link_value   String?                     // category slug, search query

  sort_order   Int       @default(0)
  is_active    Boolean   @default(true)
  created_at   DateTime  @default(now())
  updated_at   DateTime  @updatedAt

  @@index([is_active, sort_order])
}
```

### Backend API

**Public endpoints** (new file `banner.routes.ts`):
```
GET /api/banners → active banners ordered by sort_order
```
Response:
```json
[
  {
    "id": 1,
    "title": "Melsec Q Series",
    "subtitle": "High-performance modular PLC",
    "badge_text": "New Arrival",
    "image_url": "https://...",
    "product_id": 33,
    "link_type": "product",
    "link_value": null,
    "sort_order": 0
  }
]
```

**Admin endpoints**:
```
POST   /api/admin/banners              → create banner
GET    /api/admin/banners              → list all (including inactive)
GET    /api/admin/banners/:id          → get single
PUT    /api/admin/banners/:id          → update
DELETE /api/admin/banners/:id          → delete
POST   /api/admin/banners/reorder      → batch update sort_order
```

### Storage Configuration

Banner images stored in `otomasiku-products-storage/banners/{id}/{filename}`. Reuses the existing bucket (public read, admin write via `private.is_admin()` RLS policy). Allowed MIME types: `image/jpeg`, `image/png`, `image/webp`. Max 5 MB.

### Mobile App Changes

**New model** in `lib/models/banner.dart`:
```dart
@JsonSerializable()
class Banner {
  final int id;
  final String title;
  final String? subtitle;
  final String? badgeText;
  final String imageUrl;
  final int? productId;
  final String? linkType;
  final String? linkValue;
  final int sortOrder;
}
```

**New API endpoint** in `lib/data/repositories/banner_repository.dart`:
```dart
class BannerRepository {
  final ApiClient apiClient;

  Future<List<Banner>> getActive() async {
    final response = await apiClient.get('/banners');
    return (response.data as List).map((j) => Banner.fromJson(j)).toList();
  }
}
```

**New provider** in `lib/providers/banner_provider.dart`:
```dart
final bannerProvider = FutureProvider<List<Banner>>((ref) async {
  final repo = ref.read(bannerRepositoryProvider);
  return repo.getActive();
});
```

**Updated widget** in `hero_banner.dart`:
- Consume `bannerProvider` instead of static data
- Render using `Banner` fields
- Tap handler:
  - If `productId` set → `context.goNamed(AppRoute.productDetail, pathParameters: {'id': productId.toString()})`
  - If `linkType == "category"` → navigate to search with category filter
  - Else → no-op

### Admin UI (otomasiku-admin)

**New page**: `/admin/banners`

**List view**: Table with columns (image thumbnail, title, badge, active, sort_order) + drag-to-reorder.

**Create/Edit form**:
- Title (text input, required)
- Subtitle (text input, optional)
- Badge text (text input, optional — "New Arrival", "Best Seller", "Promo")
- Image upload (file picker → upload to storage → preview)
- Link type (select: "Product" | "Category" | "None")
- Product search (if link type = Product — autocomplete search by name)
- Category select (if link type = Category)
- Sort order (number input)
- Active (toggle)

### Seed Migration

File: `prisma/migrations/YYYYMMDDHHMMSS_seed_banners.sql`
```sql
INSERT INTO banners (title, badge_text, link_type, link_value, sort_order, is_active, image_url)
VALUES
  ('Melsec Q Series', 'New Arrival', 'category', 'plc', 0, true, ''),
  ('FR-A800 Series', 'Best Seller', 'category', 'inverter', 1, true, ''),
  ('GOT2000 Series', 'Promo', 'category', 'hmi', 2, true, '');
```

Initial banners won't have custom images — first admin can upload them.

### Pros
- Full CRUD — create, edit, delete banners
- Custom images per banner
- Flexible linking (product, category, search)
- Admin-managed without app releases
- Future-proof (add scheduling, A/B testing, analytics later)

### Cons
- Most work up-front
- Requires admin UI development
- New table + migration + endpoints + mobile model

---

## Option D: Hybrid — `AppConfig` JSON Config

**Effort: ~2 hours**

Store banner config as a single JSON row in a config table instead of building a full relational schema.

### Database

**New model** in `prisma/schema.prisma`:
```prisma
model AppConfig {
  id    Int    @id @default(autoincrement())
  key   String @unique     // "home_banners"
  value Json               // JSON array of banner objects
}
```

### Seed Data
```json
{
  "home_banners": [
    {
      "title": "Melsec Q Series",
      "subtitle": "High-performance modular PLC",
      "badgeText": "New Arrival",
      "categorySlug": "plc",
      "gradient": ["#1e293b", "#dc2626"]
    },
    {
      "title": "FR-A800 Series",
      "subtitle": "Advanced inverter drives",
      "badgeText": "Best Seller",
      "categorySlug": "inverter",
      "gradient": ["#1e3a5f", "#0d9488"]
    },
    {
      "title": "GOT2000 Series",
      "subtitle": "Next-gen HMI panels",
      "badgeText": "Promo",
      "categorySlug": "hmi",
      "gradient": ["#4c1d95", "#7c3aed"]
    }
  ]
}
```

### Backend API

**New endpoint**:
```
GET /api/config/home-banners → returns parsed JSON array
```

One file change in `product.handler.ts` or new `config.routes.ts`.

### Mobile App Changes

```dart
final homeBannersProvider = FutureProvider<List<HomeBanner>>((ref) async {
  final api = ref.read(apiClientProvider);
  final json = await api.get('/config/home-banners');
  return (json['value'] as List).map((e) => HomeBanner.fromJson(e)).toList();
});
```

### Admin Changes

- Single JSON editor field, or
- Simple form that constructs the JSON and saves it

### Pros
- Very flexible schema — add fields without migrations
- Single API call, minimal backend surface
- Admin can edit without app release
- Low complexity

### Cons
- No relational integrity (can reference a deleted product)
- Gradients currently hardcoded in Dart — would need to be moved to config
- Image URLs stored as strings with no storage management

---

## Comparison Matrix

| Criterion | A: Hardcoded | B: is_featured | C: Banners table | D: JSON Config |
|-----------|:---:|:---:|:---:|:---:|
| **Effort** | 5 min | 2-3 hrs | 4-6 hrs | 2 hrs |
| **Migration needed** | No | Yes (columns) | Yes (new table) | Yes (new table) |
| **Admin control** | None | Limited (on/off) | Full CRUD | Medium |
| **Custom banner images** | No | Optional | Yes | Yes |
| **App release needed for change** | Yes | No | No | No |
| **Links to specific products** | No | Yes (direct FK) | Yes (direct FK) | No (string only) |
| **Future flexibility** | None | Low | High | Medium |
| **Schema complexity** | None | Minimal | Standard | Minimal |

---

## Recommendation

**Option C (Banners table)** is the right production approach if you want full admin control with custom visuals and the ability to change promos without any code deployment.

**Option B (is_featured)** is the pragmatic sweet spot if you primarily need to feature specific products — lightweight, leverages existing product images, minimal API surface.

Given you already have `otomasiku-admin`, Option C aligns best with your architecture: a dedicated admin section for managing banners that feed into the mobile app dynamically.
