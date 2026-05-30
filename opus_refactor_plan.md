# Opus Refactor Plan

> **Generated:** 2026-05-26  
> **Branch:** `feat/spec-08-09-profile-push`  
> **Trigger:** 12 edge-case bugs fixed in one session — signals systemic issues  
> **Skills applied:** `test-driven-development`, `ui-ux-pro-max`, `verification-before-completion`

---

## Executive Summary

The 12 bugs fixed today share common root causes: untested code, god classes, debug simulation polluting production, and i18n violations. This plan addresses the systemic issues, not just symptoms.

**Current state:**
- `flutter analyze`: 2 info-level issues (clean)
- Test coverage on purchase flow: **ZERO** (cart, checkout, order, payment)
- God classes: 2 (checkout 580 lines, product_detail 530 lines)
- kDebugMode simulation in production: 3 files
- Hardcoded strings: ~50+ violations
- Accessibility violations: undersized touch targets (32×32 instead of 44×44)

---

## Phase 1: Test Foundation (TDD — Must Do First)

> **Principle:** No refactoring without tests. Tests prove the refactor didn't break anything.

### 1.1 Cart Provider Tests

**File:** `test/providers/cart_provider_test.dart`

| Test Case | Covers Bug # |
|-----------|-------------|
| `addItem` adds to state optimistically | #2 |
| `addItem` rolls back on API failure | — |
| `loadCart` does NOT overwrite when items exist | #2 |
| `loadCart` fetches when items empty | #2 |
| `removeItem` removes from state | #3 |
| `clearCart` empties state | #10 |
| `selectedCartItemsProvider` populated by buyNow | #1 |
| Badge count matches actual item count | #2 |

**Approach:** Mock `CartRepository` via Riverpod overrides. Test `CartNotifier` in isolation.

### 1.2 Order Provider Tests

**File:** `test/providers/order_provider_test.dart`

| Test Case | Covers Bug # |
|-----------|-------------|
| `createOrder` returns order ID on success | #5 |
| `createOrder` throws on missing address | — |
| `orderDetailProvider` fetches real order | #11 |
| `createOrderStateProvider` tracks loading/success/error | — |

**Approach:** Refactor `createOrder()` from top-level function to notifier method FIRST (see Phase 2), then test.

### 1.3 Payment Provider Tests

**File:** `test/providers/payment_provider_test.dart`

| Test Case | Covers Bug # |
|-----------|-------------|
| Polling returns paid status | #5 |
| Polling handles timeout | — |
| Polling handles API error | — |

### 1.4 Order Repository Tests

**File:** `test/repositories/order_repository_test.dart`

| Test Case | Covers Bug # |
|-----------|-------------|
| `createOrder` sends correct payload | #5 |
| `createOrder` parses response correctly | — |
| `getOrderById` returns Order | #11 |
| `getOrders` with status filter | — |

### 1.5 Checkout Widget Tests

**File:** `test/features/checkout/checkout_screen_test.dart`

| Test Case | Covers Bug # |
|-----------|-------------|
| Shows items from `selectedCartItemsProvider` | #1 |
| Remove item updates selections | #3 |
| Empty cart shows "Keranjang Kosong" | #1 |
| Terms checkbox gates "Bayar" button | — |
| Address required before order | — |

---

## Phase 2: Architecture — Extract kDebugMode Simulation

> **Problem:** 3 production files contain `if (kDebugMode)` blocks that return fake data. This means debug builds NEVER exercise real API paths. Bugs #5 and #11 were caused by this.

### 2.1 Create Fake Repositories

```
lib/data/repositories/
├── order_repository.dart          (interface + real impl — unchanged)
├── fake_order_repository.dart     (NEW — kDebugMode simulation extracted here)
├── payment_repository.dart        (NEW — extract from payment_provider)
└── fake_payment_repository.dart   (NEW — kDebugMode simulation)
```

### 2.2 Inject via Riverpod Overrides

```dart
// lib/main.dart
final overrides = <Override>[
  if (kDebugMode) ...[
    orderRepositoryProvider.overrideWithValue(FakeOrderRepository()),
    paymentRepositoryProvider.overrideWithValue(FakePaymentRepository()),
  ],
];

runApp(ProviderScope(overrides: overrides, child: const OtomasikuApp()));
```

### 2.3 Refactor `createOrder()` 

**Current (anti-pattern):**
```dart
Future<void> createOrder(WidgetRef ref, {...}) async { ... }
```

**Target:**
```dart
class OrderNotifier extends AsyncNotifier<OrderState> {
  Future<String> createOrder({...}) async { ... }
}
```

**Why:** Top-level function with `WidgetRef` is untestable without widget context. Notifier can be tested with `ProviderContainer`.

---

## Phase 3: Split God Classes

### 3.1 CheckoutScreen (580 → ~150 + 4 widgets)

| Extract To | Responsibility | Lines |
|-----------|---------------|-------|
| `checkout_screen.dart` | Orchestrator, state, navigation | ~150 |
| `widgets/order_summary_section.dart` | Item list, quantities, subtotal | ~100 |
| `widgets/address_selector.dart` | Address picker with load/error states | ~80 |
| `widgets/payment_method_section.dart` | BCA payment instructions | ~120 |
| `widgets/checkout_bottom_bar.dart` | Total, terms, pay button | ~80 |

### 3.2 ProductDetailScreen (530 → ~120 + 5 widgets)

| Extract To | Responsibility | Lines |
|-----------|---------------|-------|
| `product_detail_screen.dart` | Orchestrator, tabs, state | ~120 |
| `widgets/product_image_section.dart` | Image carousel/display | ~60 |
| `widgets/tiered_pricing_widget.dart` | Pricing tiers table | ~80 |
| `widgets/product_info_section.dart` | Name, brand, stock, description | ~100 |
| `widgets/product_bottom_bar.dart` | Add to cart, buy now, compare | ~80 |
| `widgets/rfq_bottom_sheet.dart` | RFQ dialog | ~60 |

---

## Phase 4: i18n — Fix Hardcoded Strings

> **Rule:** All user-facing strings via `AppLocalizations.of(context)`. Both `app_id.arb` and `app_en.arb`.

### 4.1 Files with violations (by count)

| File | Approx. Violations | Priority |
|------|-------------------|----------|
| `checkout_screen.dart` | ~20 (payment instructions, errors) | HIGH |
| `edit_address_screen.dart` | ~15 (placeholders, validation messages) | HIGH |
| `product_detail_screen.dart` | ~8 (badges, tiers, docs) | MEDIUM |
| `projects_screen.dart` | ~8 (toast, dates, labels) | MEDIUM |
| `profile_screen.dart` | ~5 (locale toggle, fallbacks) | LOW |
| `payment_success_screen.dart` | ~2 (month names) | LOW |

### 4.2 Month Name Formatting

Replace hardcoded month arrays with `intl` `DateFormat`:
```dart
// Before (2 files)
final months = ['Jan', 'Feb', ...];

// After
DateFormat('d MMM yyyy', locale).format(date)
```

### 4.3 ARB Key Naming Convention

```
checkout_paymentInstructionAtm → "Transfer via ATM BCA"
checkout_paymentInstructionMobile → "Transfer via BCA Mobile / myBCA"
address_placeholderLabel → "Rumah, Kantor, dll"
address_validationMaxChars → "Maksimal {count} karakter"
```

---

## Phase 5: UI/UX Fixes (ui-ux-pro-max checklist)

### 5.1 Accessibility — Touch Targets (CRITICAL)

| File | Element | Current | Required |
|------|---------|---------|----------|
| `cart_item_card.dart` | Quantity +/- buttons | 32×32 | 44×44dp min |
| `product_detail_screen.dart` | Tier pricing GestureDetector | No size constraint | 44×44dp min |

**Fix:** Wrap in `SizedBox(width: 44, height: 44)` or use `IconButton` with `constraints: BoxConstraints(minWidth: 44, minHeight: 44)`.

### 5.2 Error Handling — Swallowed Errors

| File | Location | Issue | Fix |
|------|----------|-------|-----|
| `checkout_screen.dart` | `_loadAddresses` | `catch (_) {}` — silent failure | Show error state in address selector |
| `product_detail_screen.dart` | `_addToCart` | Doesn't await, no error feedback | Await + show snackbar on failure |

### 5.3 `use_build_context_synchronously` (flutter analyze)

**File:** `checkout_screen.dart:853, 858`

**Fix:** Guard with `if (!context.mounted) return;` after each await.

### 5.4 Navigation — Back Stack Integrity

Bug #12 showed `PopScope` navigating to wrong route. Audit all `PopScope` and `WillPopScope` usages:
- Payment success → orders ✅ (already fixed)
- Checkout → cart (verify)
- Order detail → orders (verify)

---

## Phase 6: Constants & Magic Numbers

| Magic Value | Location | Extract To |
|-------------|----------|-----------|
| `0.11` (tax rate) | `checkout_screen.dart` | `AppConstants.taxRate` |
| `'sim-'` prefix | 3 files | `AppConstants.simulatedOrderPrefix` |
| `32` (button size) | `cart_item_card.dart` | Use `AppConstants.minTouchTarget = 44` |
| `2` seconds (poll delay) | `payment_provider.dart` | `AppConstants.simulatedPaymentDelay` |
| Tier ranges `1-5, 6-10, 11+` | `product_detail_screen.dart` | Model data from API |

---

## Execution Order & Dependencies

```
Phase 1 (Tests)          ← DO FIRST, enables safe refactoring
  │
  ├── 1.1 Cart tests     (independent)
  ├── 1.2 Order tests    (depends on Phase 2.3 — refactor createOrder first)
  ├── 1.3 Payment tests  (depends on Phase 2.1 — extract repository first)
  └── 1.4 Repo tests     (independent)
  │
Phase 2 (Architecture)   ← Enables testability
  │
  ├── 2.1 Fake repos     (independent)
  ├── 2.2 DI overrides   (depends on 2.1)
  └── 2.3 createOrder    (independent)
  │
Phase 3 (Split classes)  ← Requires Phase 1 tests as safety net
  │
  ├── 3.1 Checkout       (independent)
  └── 3.2 ProductDetail  (independent)
  │
Phase 4 (i18n)           ← Can run in parallel with Phase 3
  │
Phase 5 (UI/UX)          ← Can run in parallel with Phase 4
  │
Phase 6 (Constants)      ← Lowest priority, do last
```

---

## Suggested Sprint Breakdown

| Sprint | Phases | Effort | Outcome |
|--------|--------|--------|---------|
| **Sprint A** (2-3 days) | 2.1, 2.2, 2.3 + 1.1, 1.4 | Architecture + cart/repo tests | Testable architecture, cart regression-proof |
| **Sprint B** (2-3 days) | 1.2, 1.3, 1.5 + 3.1, 3.2 | Remaining tests + split god classes | Full test coverage, maintainable screens |
| **Sprint C** (1-2 days) | 4.1–4.3 + 5.1–5.4 | i18n + UI/UX fixes | Compliant with AI_RULES.md |
| **Sprint D** (0.5 day) | 6 | Constants extraction | Clean code |

**Total estimated effort:** 6–9 days

---

## Success Criteria

- [ ] `flutter analyze` — 0 issues (not just 0 errors)
- [ ] `flutter test` — all pass, 0 skipped
- [ ] Test coverage on purchase flow: cart, order, payment providers + order repository
- [ ] No `kDebugMode` simulation in production provider/repository files
- [ ] No file > 300 lines in `features/`
- [ ] 0 hardcoded user-facing strings in widgets
- [ ] All touch targets ≥ 44×44dp
- [ ] No swallowed errors (`catch (_) {}`)
- [ ] `createOrder` testable without widget context
- [ ] Both ARB files have all keys used in code

---

## Risk & Mitigation

| Risk | Mitigation |
|------|-----------|
| Refactoring breaks working flows | Phase 1 tests FIRST — they catch regressions |
| i18n changes break build | Add keys to BOTH arb files simultaneously; `flutter pub get` after |
| God class split introduces bugs | Extract one widget at a time, run tests after each |
| Fake repos diverge from real API | Fake repos implement same interface; integration tests catch drift |

---

## Files Created/Modified (Expected)

### New Files (~15)
```
test/providers/cart_provider_test.dart
test/providers/order_provider_test.dart
test/providers/payment_provider_test.dart
test/repositories/order_repository_test.dart
test/features/checkout/checkout_screen_test.dart
lib/data/repositories/fake_order_repository.dart
lib/data/repositories/fake_payment_repository.dart
lib/data/repositories/payment_repository.dart
lib/features/checkout/widgets/order_summary_section.dart
lib/features/checkout/widgets/address_selector.dart
lib/features/checkout/widgets/payment_method_section.dart
lib/features/checkout/widgets/checkout_bottom_bar.dart
lib/features/product_detail/widgets/tiered_pricing_widget.dart
lib/features/product_detail/widgets/product_bottom_bar.dart
lib/core/constants/app_constants.dart (or extend existing)
```

### Modified Files (~12)
```
lib/providers/cart_provider.dart (minor — expose for testing)
lib/providers/order_provider.dart (major — refactor to notifier)
lib/providers/payment_provider.dart (major — extract simulation)
lib/data/repositories/order_repository.dart (moderate — remove kDebugMode)
lib/features/checkout/checkout_screen.dart (major — split + i18n)
lib/features/product_detail/product_detail_screen.dart (major — split + i18n)
lib/features/cart/widgets/cart_item_card.dart (minor — touch targets)
lib/features/address/edit_address_screen.dart (minor — i18n)
lib/features/projects/projects_screen.dart (minor — i18n)
lib/features/profile/profile_screen.dart (minor — i18n)
lib/features/payment/payment_success_screen.dart (minor — DateFormat)
lib/l10n/app_id.arb + app_en.arb (~50 new keys each)
```
