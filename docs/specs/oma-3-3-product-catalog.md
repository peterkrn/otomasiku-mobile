# Spec: OMA-3-3 — Halaman Katalog Produk (Grid + Search + Filter)

| Field | Value |
|-------|-------|
| **JIRA ID** | OMA-3 sub-task: "Halaman Katalog Produk" |
| **Epic** | OMA-3: Tampilan & Navigasi Aplikasi |
| **Sprint** | Sprint 1 |
| **Milestone** | Milestone 2 |
| **Priority** | High |
| **Story Points** | 2 |
| **Status** | ⬜ Draft |

---

## User Story

> **Sebagai** pelanggan Otomasiku,
> **Saya ingin** melihat daftar produk dalam bentuk grid dengan foto dan harga, serta bisa mencari dan memfilter berdasarkan kategori dan brand,
> **Sehingga** saya bisa dengan cepat menemukan inverter, PLC, HMI, atau servo yang saya butuhkan.

---

## Context & References

| Reference | Link |
|-----------|------|
| PRD Module | `docs/PRD.md` § Module 2: Katalog Produk |
| Architecture | `docs/ARCHITECTURE.md` § Flutter folder structure, Hybrid Supabase + Express design |
| HTML Mockup | `ui-otomasiku-marketplace/home.html` |
| AI Rules | `docs/AI_RULES.md` § UI Rules #1–#12, i18n, Mandatory Patterns |
| Plan Phase | `docs/PLAN_MILESTONE_2.md` § Phase M2-2 |
| Product Data | `docs/DUMMY_PRODUCT_MAPPING_PLAN.md` § 4 (10 products for Milestone 2) |
| Parent Spec | `docs/specs/oma-3-ui-navigation.md` |

---

## Functional Requirements

### Behavior Description

The Home screen (`/home`) is the main catalog view. After login, pelanggan lands here. The screen shows a scrollable grid of 10 products loaded from `dummy_products.dart` (Milestone 2 scope). Pelanggan can:

- **Search** by product name, SKU, or series — debounced text input
- **Filter** by category chip (Semua, Inverter, PLC, Servo, HMI) and brand (Mitsubishi, Danfoss)
- **Sort** implicitly (default: alphabetical by name, but chips rearrange view)
- **Tap** a product card to navigate to product detail
- **Tap "Tambah"** on a product card to add 1 unit to cart

> **Note:** Milestone 2 uses 10 dummy products for UI development. The full 125-product catalog is implemented in Milestone 3.

### UI/UX Specification

Based on `home.html` mockup:

```
┌─────────────────────────────┐
│ [Logo]          [🛒 badge] [👤]│  ← Header
├─────────────────────────────┤
│ 🔍 Cari FR-A820, FX5U...   │  ← Search bar
├─────────────────────────────┤
│ [Semua] [Mitsubishi] [Inv]..│  ← Category/Brand filter chips (horizontal scroll)
├─────────────────────────────┤
│ ┌──────────┐ ┌──────────┐  │
│ │ [Image]  │ │ [Image]  │  │
│ │ Badge    │ │ Badge    │  │
│ │ Name     │ │ Name     │  │
│ │ Desc     │ │ Desc     │  │
│ │ Rp XX.XX │ │ Rp XX.XX │  │
│ │ [Tambah] │ │ [Tambah] │  │  ← 2-column product grid
│ └──────────┘ └──────────┘  │
│        ... more rows ...    │
├─────────────────────────────┤
│ [Beranda] [Cari] [Proyek]   │  ← Bottom nav
│           [Keranjang] [Profil]│
└─────────────────────────────┘
```

**States:**
- **Loading:** Shimmer placeholder grid (brief, since data is local)
- **Empty (filtered):** "Tidak ada produk ditemukan" + illustration
- **Default:** 10 products in 2-column grid
- **Filtered:** Subset of products matching active filters

---

## Acceptance Criteria (Given/When/Then)

### AC-1: Product grid displays all 10 products
```gherkin
Given the user is on the Home screen
And no filters are active (chip "Semua" is selected)
When the screen loads
Then a 2-column grid displays product cards
And all 10 products are available via scrolling
And each card shows: product image, stock badge, name, description snippet, price, "Tambah" button
And prices are formatted as "Rp X.XXX.XXX" using CurrencyFormatter
```

### AC-2: Product images are real assets
```gherkin
Given the user is on the Home screen
When viewing any product card
Then the product image is loaded via Image.asset() from assets/images/products/
And images are NOT placeholder URLs (placehold.co)
And if an image fails to load, an error fallback icon is shown
```

### AC-3: Category filter chips work
```gherkin
Given the user is on the Home screen with "Semua" chip active
When the user taps the "Inverter" chip
Then only Inverter products are displayed (33 Mitsubishi + 29 Danfoss = 62)
And the "Inverter" chip has red background with white text
And the "Semua" chip reverts to gray
When the user taps "PLC"
Then only PLC products are displayed (32)
When the user taps "Semua"
Then all 10 products are displayed again
```

### AC-4: Brand filter works
```gherkin
Given the user is on the Home screen
When the user taps the "Mitsubishi" chip
Then only Mitsubishi products are displayed (33+32+11+20 = 96)
When the user taps the "Danfoss" chip
Then only Danfoss products are displayed (29)
```

### AC-5: Search filters by name/SKU
```gherkin
Given the user is on the Home screen
When the user types "FR-A840" in the search bar
Then the product grid filters to show only products with "FR-A840" in name or SKU
And the result count is displayed or the grid updates in real-time
When the user clears the search input
Then all products (respecting active category filter) are displayed
```

### AC-6: Search is debounced
```gherkin
Given the user is typing in the search bar
When the user types rapidly ("F", "FR", "FR-", "FR-A")
Then the grid does NOT update on every keystroke
And the grid updates after the user pauses typing (~300ms debounce)
```

### AC-7: "Tambah" button adds to cart
```gherkin
Given the user is on the Home screen
When the user taps "Tambah" on a product card
Then 1 unit of that product is added to the cart
And the cart badge on the Keranjang tab increments by 1
And a brief toast/snackbar confirms "Ditambahkan ke keranjang"
```

### AC-8: Tap product card navigates to detail
```gherkin
Given the user is on the Home screen
When the user taps on a product card (not the "Tambah" button)
Then the app navigates to /product/{productId}
And the product detail screen shows the correct product
```

### AC-9: Empty filter results
```gherkin
Given the user has "HMI" category filter active
And types "Danfoss" in the search bar
When the filter produces 0 results (Danfoss has no HMI products)
Then an empty state is shown: illustration + "Tidak ada produk ditemukan"
```

### AC-10: Stock badges are correct
```gherkin
Given a product has stock > 5
Then the badge is green: "{stock} Unit"
Given a product has stock 1-5
Then the badge is orange: "Sisa {stock} Unit"
Given a product has stock = 0
Then the badge is red: "Habis"
And the "Tambah" button is disabled
```

---

## Technical Design

### State Management

```dart
// providers/product_provider.dart

/// All 10 products from dummy data
final allProductsProvider = Provider<List<Product>>((ref) {
  return dummyProducts; // from dummy_products.dart
});

/// Active category filter ("Semua" | "Inverter" | "PLC" | "HMI" | "Servo")
final categoryFilterProvider = StateProvider<String>((ref) => 'Semua');

/// Active brand filter ("Semua" | "Mitsubishi" | "Danfoss")
final brandFilterProvider = StateProvider<String>((ref) => 'Semua');

/// Search query (debounced)
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Filtered products (combines category + brand + search)
final filteredProductsProvider = Provider<List<Product>>((ref) {
  final products = ref.watch(allProductsProvider);
  final category = ref.watch(categoryFilterProvider);
  final brand = ref.watch(brandFilterProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();

  return products.where((p) {
    final matchCategory = category == 'Semua' || p.category == category;
    final matchBrand = brand == 'Semua' || p.brand == brand;
    final matchSearch = query.isEmpty ||
        p.name.toLowerCase().contains(query) ||
        (p.sku?.toLowerCase().contains(query) ?? false);
    return matchCategory && matchBrand && matchSearch;
  }).toList();
});
```

### Component Tree

```
HomeScreen (ConsumerWidget)
├── AppBar
│   ├── Logo (Image.asset)
│   ├── CartIconButton (with badge from cartProvider)
│   └── ProfileAvatar
├── SearchBarWidget
│   └── TextField (onChanged → debounce → update searchQueryProvider)
├── CategoryChips (horizontal ListView)
│   └── FilterChip × N (onSelected → update categoryFilterProvider/brandFilterProvider)
├── HeroBanner (InkWell → navigate to product detail)
└── ProductGrid (GridView.builder, 2 columns)
    └── ProductCard × N (from filteredProductsProvider)
        ├── Image.asset(product.primaryImage, errorBuilder: ...)
        ├── StockBadge(stock: product.stock)
        ├── Text(product.name)
        ├── PriceText(price: product.price)
        └── ElevatedButton("Tambah", onPressed: → cartProvider.addItem)
```

### Constraints (from AI_RULES.md)

- `CurrencyFormatter.format()` for all prices — never manual formatting
- `Image.asset()` for product images — never `Image.network()` or placeholder URLs
- `errorBuilder` on all `Image.asset()` calls
- Riverpod providers for all state — no `setState` except simple animations
- GoRouter `context.goNamed()` for navigation — never `Navigator.push()`
- Minimum touch target 44×44dp on all interactive elements
- Bottom padding `pb-24` (96px) on scroll content to clear bottom nav

---

## File Changes

### New Files
- `lib/features/home/screens/home_screen.dart` — Main catalog screen
- `lib/features/home/widgets/product_card.dart` — Reusable product card
- `lib/features/home/widgets/category_chips.dart` — Horizontal filter chips
- `lib/features/home/widgets/hero_banner.dart` — Promotional banner card
- `lib/features/home/widgets/search_bar_widget.dart` — Search input with debounce
- `lib/features/shared/widgets/price_text.dart` — Formatted price widget
- `lib/features/shared/widgets/stock_badge.dart` — Color-coded stock badge

### Modified Files
- `lib/core/router/app_router.dart` — Wire `/home` route to HomeScreen
- `lib/providers/product_provider.dart` — Add filter/search providers
- `lib/providers/cart_provider.dart` — Ensure `addItem` action works

### Test Files
- `test/features/home/home_screen_test.dart` — Widget tests: grid renders, filter works
- `test/features/home/widgets/product_card_test.dart` — Card renders with correct data
- `test/features/shared/widgets/stock_badge_test.dart` — Badge color logic
- `test/core/utils/currency_formatter_test.dart` — Formatting edge cases

---

## Out of Scope

- Infinite scroll / pagination (not needed for 125 items with local data — GridView handles it)
- Compare product selection (handled in M2-8 spec)
- Product detail screen (handled in `oma-3-4-product-detail.md`)
- Backend API integration (M2 uses dummy data only)
- Sort dropdown (keep it simple — filter chips are the primary mechanism)

---

## Verification Checklist

- [ ] Home screen renders 10 products in 2-column grid
- [ ] Product images are real assets from `assets/images/products/`
- [ ] Category chips filter correctly (Semua, Inverter, PLC, HMI, Servo)
- [ ] Brand chips filter correctly (Mitsubishi, Danfoss)
- [ ] Search by name/SKU filters in real-time (debounced)
- [ ] Combined filters work (e.g. "Inverter" + "Danfoss" → 29 products)
- [ ] Empty state shown when no products match
- [ ] "Tambah" button adds to cart, badge updates
- [ ] Tap card navigates to `/product/{id}`
- [ ] Stock badges: green (>5), orange (1-5), red (0, button disabled)
- [ ] All prices use `CurrencyFormatter` → "Rp X.XXX.XXX"
- [ ] Visual match against `home.html` mockup
- [ ] Smooth scroll performance with 10 items
- [ ] `flutter analyze` passes with no errors
