# Skill: Flutter UI Screens
# Otomasiku Marketplace Mobile App

> **When to use:** Building any Flutter screen, widget, or UI component for the Otomasiku app.

---

## Pre-Flight Checklist

Before building ANY screen:

1. ✅ Check the **HTML mockup** in `ui-otomasiku-marketplace/` — pixel-match it
2. ✅ Read `docs/AI_RULES.md` § UI Rules — colors, fonts, spacing, touch targets
3. ✅ Read `docs/PLAN_MILESTONE_2.md` for the current phase's tasks and exit criteria
4. ✅ Check the **Product model** in `docs/DUMMY_PRODUCT_MAPPING_PLAN.md` § 7

---

## Screen-to-Mockup Mapping

| Screen | HTML Reference | Route Name |
|--------|---------------|------------|
| Splash | — (no mockup) | `splash` |
| Login | `login.html` | `login` |
| Register | — (similar to login) | `register` |
| Home (Catalog) | `home.html` | `home` |
| Search Results | `search-results.html` | `searchResults` |
| Product Detail | `product-detail.html` | `productDetail` |
| Compare | `compare.html` | `compare` |
| Cart | `checkout.html` (items section) | `cart` |
| Checkout | `checkout.html` | `checkout` |
| Shipping / Address | `shipping.html` | `shipping` |
| Payment (BCA VA) | `payment.html` | `payment` |
| Payment Success | `payment-success.html` | `paymentSuccess` |
| Order Detail | `order-detail.html` | `orderDetail` |
| Profile | `profile.html` | `profile` |
| Projects | `projects.html` | `projects` |

---

## Patterns

### Screen Scaffold

Every screen follows this pattern:

```dart
// features/{feature}/screens/{feature}_screen.dart
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background, // #F9FAFB
      body: SafeArea(
        child: // ... screen content
      ),
    );
  }
}
```

### Product Card Widget

```dart
// features/home/widgets/product_card.dart
Widget build(BuildContext context) {
  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16), // rounded-2xl
    ),
    child: Column(
      children: [
        // Product image — ALWAYS use Image.asset()
        Image.asset(
          product.primaryImage,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) =>
              const Icon(Icons.image_not_supported),
        ),
        // Price — ALWAYS use CurrencyFormatter
        Text(CurrencyFormatter.format(product.price)),
        // Stock badge
        StockBadge(stock: product.stock),
      ],
    ),
  );
}
```

### Navigation

```dart
// ✅ ALWAYS: GoRouter named routes
context.goNamed('productDetail', pathParameters: {'id': product.id});

// ❌ NEVER: Navigator.push
Navigator.push(context, MaterialPageRoute(...));
```

### State from Providers

```dart
// ✅ ALWAYS: Watch Riverpod providers
final products = ref.watch(productListProvider);
products.when(
  data: (list) => ProductGrid(products: list),
  loading: () => const Center(child: CircularProgressIndicator()),
  error: (err, _) => Center(child: Text('Error: $err')),
);
```

---

## Theme Constants

```dart
// core/theme/app_colors.dart
static const primary = Color(0xFFE7192D);     // Mitsubishi Red
static const background = Color(0xFFF9FAFB);  // Gray-50
static const surface = Colors.white;

// Border radius
static const cardRadius = 16.0;     // rounded-2xl
static const buttonRadius = 12.0;   // rounded-xl
static const inputRadius = 8.0;     // rounded-lg
```

---

## Product Images

- **M2 (UI-only):** Use `Image.asset('assets/images/products/...')` — all 125 images are local
- **Production:** Use `CachedNetworkImage` for Supabase Storage CDN URLs
- **NEVER** use placeholder URLs (`placehold.co`, `via.placeholder.com`)
- **ALWAYS** provide `errorBuilder` fallback

Full image mapping: `docs/DUMMY_PRODUCT_MAPPING_PLAN.md` § 3A–3E

---

## Bottom Navigation

5 tabs — match mockup exactly:

| # | Label | Icon | Screen |
|---|-------|------|--------|
| 1 | Beranda | Home | `HomeScreen` |
| 2 | Cari | Search | `SearchResultsScreen` |
| 3 | Proyek | Folder | `ProjectsScreen` |
| 4 | Keranjang | Cart + badge | `CartScreen` |
| 5 | Profil | Person | `ProfileScreen` |

Active color: `AppColors.primary` (`#E7192D`)

---

## Currency Formatting

```dart
// ✅ ALWAYS
CurrencyFormatter.format(19800000)  // → "Rp 19.800.000"

// ❌ NEVER
"Rp ${price / 100}"       // WRONG — never divide, never use double
NumberFormat('#,###')      // WRONG — use project's CurrencyFormatter
```

---

## Responsive Guidelines

- Min touch target: **44×44dp**
- Bottom padding on all screens: **pb-24** (96px) to clear bottom nav
- Product grid: **2 columns** on mobile
- Max content width: follow mockup proportions
