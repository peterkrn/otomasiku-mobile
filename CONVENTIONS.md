# CONVENTIONS.md — Proven Patterns & Known Pitfalls
# Otomasiku Marketplace Mobile App

> **Purpose:** Patterns confirmed to work in this codebase. Updated every time a bug is found and fixed.
> Reference this file alongside `docs/AI_RULES.md`.
> Last updated: 2026-03-17

---

## ⚠️ Known Pitfalls — Do NOT Repeat

| # | Bug | Root Cause | Fix |
|---|-----|-----------|-----|
| 1 | Android back button exits app from shell tabs | `StatefulShellRoute` has no back stack | Wrap with `PopScope` — see §1 |
| 2 | Re-login required after app resumes | No `redirect` in GoRouter | Add auth redirect — see §2 |
| 3 | Product images not displaying | Wrong asset path or subfolder not registered in `pubspec.yaml` | See §3 |
| 4 | `overflow by N pixels` on product grid | `childAspectRatio` too large | Use `0.75` minimum — see §4 |
| 5 | `intl` version conflict | `flutter_localizations` pins `intl 0.20.2` | Use `intl: ^0.20.0` in pubspec — see §5 |
| 6 | `CardTheme` type error | Flutter 3.x renamed to `CardThemeData` | Use `CardThemeData` — see §6 |
| 7 | Hardcoded strings in models | `statusLabel`, `tierLabel` in model classes | Models = pure Dart, zero Flutter/strings — see §7 |
| 8 | `double` division in money calc | `discountPercent` used `/` operator | Use `~/` integer division — see §8 |
| 9 | Glass input fields render as white boxes | Missing `fillColor: Colors.transparent` | See §9 |
| 10 | `Icons.person_outlined` compile error | Icon name doesn't exist | Use `Icons.person_outline` (no 'd') |
| 11 | Double bottom nav bar showing | `HomeScreen` has `bottomNavigationBar` + shell also has it | Remove from all shell screens — only in `StatefulShellRoute` builder |
| 12 | Login screen overflow 408px with keyboard | `Column` inside `SafeArea` doesn't scroll | Wrap in `SingleChildScrollView`, add `resizeToAvoidBottomInset: true` |
| 13 | Invalid image data for avatar | `avatar.jpg` contained text 'placeholder_avatar', not image data | Use `CircleAvatar` with initials instead — see §16 |
| 14 | Skipped 100+ frames warning | `FutureBuilder` with stagger delay causes frame drops | Remove `FutureBuilder`, use `TweenAnimationBuilder` only — see §10 |
| 15 | Double checkmark icon on "Tambah" | `TextButton.icon` with dynamic label including its own icon | Use `TextButton` with manual `Row` + conditional icon — see §17 |
| 16 | Card bottom overflowed by 57px | `childAspectRatio` > 0.6 + rigid Column content | Set `childAspectRatio: 0.58` + use `Spacer()` — see §4 & §17 |

---

## §1 — StatefulShellRoute with Back Button Fix

**Problem:** Pressing Android back on any shell tab exits the app instead of returning to the home tab.

```dart
// ✅ CORRECT — app_router.dart
StatefulShellRoute.indexedStack(
  builder: (context, state, navigationShell) {
    return PopScope(
      // Only allow system back (exit) when on the first tab (Beranda)
      canPop: navigationShell.currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          // User pressed back on a non-home tab → go to home tab
          navigationShell.goBranch(0);
        }
      },
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: BottomNavBar(
          currentIndex: navigationShell.currentIndex,
          onTap: (index) => navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          ),
        ),
      ),
    );
  },
  branches: [
    StatefulShellBranch(routes: [
      GoRoute(path: '/home', name: AppRoute.home, builder: (_, __) => const HomeScreen()),
    ]),
    StatefulShellBranch(routes: [
      GoRoute(path: '/search', name: AppRoute.search, builder: (_, __) => const SearchScreen()),
    ]),
    StatefulShellBranch(routes: [
      GoRoute(path: '/projects', name: AppRoute.projects, builder: (_, __) => const ProjectsScreen()),
    ]),
    StatefulShellBranch(routes: [
      GoRoute(path: '/profile', name: AppRoute.profile, builder: (_, __) => const ProfileScreen()),
    ]),
  ],
),
```

```dart
// ✅ CORRECT — bottom_nav_bar.dart
// Accept onTap callback from parent — do NOT navigate internally
class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,  // ← delegate to parent
      // ... destinations
    );
  }
}
```

---

## §2 — GoRouter Auth Redirect

**Problem:** App loses auth state on resume because there's no redirect guard.

```dart
// ✅ CORRECT — app_router.dart
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final container = ProviderScope.containerOf(context, listen: false);
    final isLoggedIn = container.read(authProvider).isLoggedIn;

    final isAuthRoute = [
      '/',         // splash
      '/login',
      '/register',
    ].contains(state.matchedLocation);

    // Not logged in + trying to access protected route → login
    if (!isLoggedIn && !isAuthRoute) return '/login';

    // Already logged in + on auth route → home
    if (isLoggedIn && isAuthRoute) return '/home';

    return null; // no redirect needed
  },
  routes: [ /* ... */ ],
);
```

---

## §3 — Asset Registration & Image Paths

**Problem:** `Image.asset()` shows error widget because subfolder not registered in `pubspec.yaml`.

```yaml
# ✅ CORRECT — pubspec.yaml
# Every subfolder must be listed explicitly
flutter:
  assets:
    - assets/
    - assets/images/
    - assets/images/profile/
    - assets/images/products/
    - assets/images/products/inverter/
    - assets/images/products/plc/
    - assets/images/products/servo/
    - assets/images/products/hmi/
```

**Verify before running:**
```bash
# Check files actually exist before referencing in code
ls assets/images/products/inverter/
ls assets/images/products/plc/

# If empty, copy from docs/dummy-products/
cp docs/dummy-products/01-fr-a820-0.4k.jpg assets/images/products/inverter/
cp docs/dummy-products/03-fx5u-32mt-es.jpg assets/images/products/plc/
# etc. — see DUMMY_PRODUCT_MAPPING_PLAN.md § 3 for full mapping
```

**After adding new asset folders:** `flutter pub get` — hot reload won't pick up new assets.

---

## §4 — Product Grid Without Overflow

**Problem:** `bottom overflowed by N pixels` on product cards.

```dart
// ✅ CORRECT — product grid in home_screen.dart
SliverGrid(
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    mainAxisSpacing: 12,
    crossAxisSpacing: 12,
    childAspectRatio: 0.58,  // ← 0.58—0.6 prevents overflow for compact cards
  ),
  // ...
)

// ✅ CORRECT — bottom padding to clear nav bar
const SliverToBoxAdapter(
  child: SizedBox(height: 96),  // matches bottom nav height + safe area
)
```

---

## §5 — intl Version Constraint

**Problem:** `intl ^0.19.0` conflicts with `flutter_localizations` which pins `intl 0.20.2`.

```yaml
# ❌ WRONG
dependencies:
  intl: ^0.19.0

# ✅ CORRECT
dependencies:
  intl: ^0.20.0  # matches flutter_localizations pin of 0.20.2
```

---

## §6 — ThemeData Class Names (Flutter 3.x)

**Problem:** `CardTheme` renamed to `CardThemeData` in Flutter 3.x.

```dart
// ❌ WRONG
theme: ThemeData(
  cardTheme: CardTheme(/* ... */),
)

// ✅ CORRECT
theme: ThemeData(
  cardTheme: CardThemeData(/* ... */),
)
```

---

## §7 — Models Are Pure Dart — No Strings, No Flutter

**Problem:** `statusLabel`, `tierLabel`, `statusColor` in model classes hardcode strings — violates i18n rule.

```dart
// ❌ WRONG — model contains UI strings
class Order {
  String get statusLabel {
    switch (status) {
      case OrderStatus.processing: return 'Sedang Diproses'; // hardcoded!
    }
  }
  Color get statusColor => const Color(0xFF1976D2); // Flutter import in model!
}

// ✅ CORRECT — model is pure data, zero Flutter dependency
class Order {
  final OrderStatus status;
  // No statusLabel, no statusColor, no import 'package:flutter/material.dart'
}

// Status labels live in the UI layer, translated via AppLocalizations:
// In a widget:
Text(_getStatusLabel(order.status, l10n))

String _getStatusLabel(OrderStatus status, AppLocalizations l10n) {
  return switch (status) {
    OrderStatus.pending    => l10n.orderStatusPending,
    OrderStatus.processing => l10n.orderStatusProcessing,
    OrderStatus.shipping   => l10n.orderStatusShipping,
    OrderStatus.completed  => l10n.orderStatusCompleted,
    OrderStatus.cancelled  => l10n.orderStatusCancelled,
  };
}
```

**Rule:** If a model file has `import 'package:flutter/material.dart'` → it's wrong.

---

## §8 — Integer-Only Money Math

**Problem:** `discountPercent` used double division `(a / b) * 100`.

```dart
// ❌ WRONG — uses double
int get discountPercent {
  return (((originalPrice! - price) / originalPrice!) * 100).round();
}

// ✅ CORRECT — integer-only with ~/ operator
int get discountPercent {
  if (originalPrice == null || originalPrice! <= price) return 0;
  return ((originalPrice! - price) * 100) ~/ originalPrice!;
}
```

**Rule:** For monetary calculations, ALWAYS multiply before dividing. Use `~/` not `/`.

---

## §9 — Glass Morphism Input Fields (Dark Screens)

**Problem:** Input fields render as solid white boxes on dark/image backgrounds.

```dart
// ✅ CORRECT pattern for glass inputs on dark backgrounds
Widget _buildGlassInput({
  required TextEditingController controller,
  required String hintText,
  required IconData prefixIcon,
  bool obscureText = false,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.15),   // semi-transparent
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.2),
      ),
    ),
    child: TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),   // ← white text
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(prefixIcon, color: Colors.white70, size: 20),
        border: InputBorder.none,
        fillColor: Colors.transparent,               // ← CRITICAL: prevents theme override
        filled: true,                                // ← must be true for fillColor to work
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    ),
  );
}

// Also required on the Scaffold:
Scaffold(
  backgroundColor: Colors.black, // ← prevents white showing through
  body: Stack(children: [...]),
)
```

---

## §10 — Filter Chips with Stagger Animation

**Problem:** Category filter switching feels instant and cheap (no animation).

```dart
// ✅ CORRECT — animated product grid with stagger
Widget _buildAnimatedProductCard({required Product product, required int index}) {
  return TweenAnimationBuilder<double>(
    key: ValueKey('${product.id}-${DateTime.now().millisecondsSinceEpoch}'),
    duration: const Duration(milliseconds: 300),
    tween: Tween(begin: 0.0, end: 1.0),
    curve: Curves.easeOutCubic,
    child: ProductCard(product: product),
    builder: (context, value, child) {
      return Transform.translate(
        offset: Offset(0, 20 * (1 - value)),   // slide up 20px
        child: Opacity(opacity: value, child: child),
      );
    },
  );
}

// Trigger rebuild with a key when filter changes:
// In HomeScreen state: int _filterVersion = 0;
// On chip tap: setState(() { _filterVersion++; _selectedCategory = category; });
// On grid: key: ValueKey(_filterVersion)
```

---

## §11 — AppLocalizations Usage

```dart
// ❌ WRONG — old nullable pattern
final l10n = AppLocalizations.of(context);
Text(l10n!.homeTitle)   // unnecessary null check

// ✅ CORRECT — non-nullable (l10n.yaml has nullable-getter: false)
final l10n = AppLocalizations.of(context)!;
Text(l10n.homeTitle)

// ❌ WRONG — hardcoded string
Text('Katalog Produk')

// ✅ CORRECT — ARB key
Text(l10n.homeTitle)
```

---

## §12 — Navigation Patterns

```dart
// ❌ WRONG — Navigator.push
Navigator.push(context, MaterialPageRoute(builder: (_) => SomeScreen()));

// ❌ WRONG — hardcoded path string
context.go('/product/MIT-INV-001');

// ✅ CORRECT — named route with AppRoute constant
context.goNamed(AppRoute.productDetail, pathParameters: {'id': product.id});

// ✅ CORRECT — push for screens that need back button (outside shell)
context.pushNamed(AppRoute.cart);
context.pushNamed(AppRoute.checkout);
```

---

## §13 — Riverpod State Patterns

```dart
// ❌ WRONG — setState for business logic
setState(() => _products = filtered);

// ✅ CORRECT — Riverpod provider
ref.read(productProvider.notifier).setCategory(FilterCategory.inverter);

// ❌ WRONG — watch inside conditional or loop
if (someCondition) {
  final state = ref.watch(productProvider); // error: conditional watch
}

// ✅ CORRECT — watch at top of build()
@override
Widget build(BuildContext context, WidgetRef ref) {
  final productState = ref.watch(productProvider);  // always at top
  final cartCount = ref.watch(cartProvider.select((s) => s.totalItems));
  // ...
}
```

---

## §14 — Backend: pnpm Only

```bash
# ❌ WRONG
npm install
npm run dev
yarn add express

# ✅ CORRECT
pnpm install
pnpm run dev
pnpm add express

# Lock file to commit: pnpm-lock.yaml
# Lock file to NEVER commit: package-lock.json, yarn.lock
```

---

## §15 — Express API Route Prefix

```typescript
// ❌ WRONG — no prefix, or versioned prefix
router.get('/products', ...)
router.get('/api/v1/products', ...)

// ✅ CORRECT — /api/ prefix, no version segment
router.get('/api/products', ...)
router.post('/api/orders', ...)
router.post('/api/payments/bca/callback', ...)
```

---

## §16 — Never Use Placeholder Text Files as Image Assets

**Problem:** Creating a text file (e.g., `avatar.jpg` containing 'placeholder_avatar') and using it as an image asset causes "Invalid image data" error.

```dart
// ❌ WRONG — text file is not a valid image
// assets/images/profile/avatar.jpg contains: "placeholder_avatar"
Image.asset('assets/images/profile/avatar.jpg') // ← Invalid image data error
```

**Fix:** If a real image is not available, use `CircleAvatar` with initials instead of a fake image file:

```dart
// ✅ CORRECT — CircleAvatar with initials
CircleAvatar(
  radius: 16,
  backgroundColor: AppColors.mitsubishiRed,
  child: const Text(
    'JD', // User initials
    style: TextStyle(
      color: Colors.white,
      fontSize: 10,
      fontWeight: FontWeight.bold,
    ),
  ),
)
```

**Rule:** Image assets must be valid image files (JPEG, PNG, WEBP, GIF). Never create fake ".jpg" files with text content.

---

## Checklist Before Every PR

```
[ ] flutter analyze — zero errors, zero warnings
[ ] flutter gen-l10n — zero errors
[ ] No hardcoded Indonesian/English strings in widgets (grep for Text\(')
[ ] No double/float for money (grep for double|float in models)
[ ] All Image.asset() calls have errorBuilder fallback
[ ] All navigations use context.goNamed() or context.pushNamed()
[ ] New asset folders registered in pubspec.yaml
[ ] No import 'package:flutter/material.dart' in model files
[ ] Back button behavior correct on all shell tabs
[ ] Product grid shows with images (not error icons)
```

---

## §17 — Justified Layout & Interactive Button States

**Problem:** Cards have varying heights due to different text lengths, making buttons misaligned. Also, static buttons feel dull.

```dart
// ✅ CORRECT — product_card.dart
// 1. Column MUST NOT use mainAxisSize: min to allow filling the Grid cell
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    _buildImageArea(),
    _buildProductInfo(),
    
    // 2. Use Spacer to push the button to the very bottom (Justified look)
    const Spacer(),

    // 3. Button with Hover (Red) and Success (Green) states
    _buildInteractiveAddToCartButton(),
  ],
)

// ✅ CORRECT — Button state styling
TextButton(
  style: ButtonStyle(
    backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
      if (isAdded) return Colors.green;
      if (states.contains(WidgetState.hovered)) return AppColors.mitsubishiRed;
      return AppColors.surfaceVariant;
    }),
    foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
      if (isAdded || states.contains(WidgetState.hovered)) return Colors.white;
      return AppColors.textPrimary;
    }),
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      // 4. Manual Row avoids the "Double Icon" bug of TextButton.icon
      if (!isAdded) ...[
        const Icon(Icons.add, size: 16),
        const SizedBox(width: 4),
      ],
      Text(isAdded ? l10n.added : l10n.addToCartShort),
    ],
  ),
)
```

**Rule:** Always use a `Spacer()` before the final action button in a grid card to ensure a "justified" bottom edge across all items. Use snappy animations (~600ms) for success states.

---