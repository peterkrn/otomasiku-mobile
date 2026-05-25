# Spec 07 — Payment: BCA VA Display, Countdown Timer, Payment Polling

| Field | Value |
|-------|-------|
| **Phase** | 3 — Backend Integration |
| **Priority** | High |
| **Status** | ⬜ Draft |
| **Depends On** | 01, 02, 03, 06 |
| **API Endpoints** | `GET /api/orders/:id` (poll for payment status) |

---

## Scope

Display the BCA Virtual Account payment screen after order creation. Show VA number, payment amount, countdown timer (24h deadline), and transfer instructions. Poll `GET /api/orders/:id` every 10 seconds to detect when BCA callback confirms payment. Navigate to success screen on confirmation.

> **Note:** BCA VA creation is handled server-side (Express → BCA Developer API). Flutter only displays what the order response contains. If `vaNumber` is null (backend not yet wired), show a "Menunggu nomor VA..." placeholder.

---

## Modified Files

```
lib/providers/payment_provider.dart   # Replace dummy → real polling logic
lib/features/payment/                 # Wire payment screen to real order data
```

---

## Payment Screen Layout

```
┌─────────────────────────────┐
│ ← Pembayaran BCA VA         │  ← AppBar (no back on success)
├─────────────────────────────┤
│ Order: OMA-20260525-001     │
│ Total: Rp 39.600.000        │
├─────────────────────────────┤
│ Nomor Virtual Account       │
│ ┌─────────────────────────┐ │
│ │  1234 5678 9012 3456    │ │  ← VA number (large, monospace)
│ │              [Salin]    │ │  ← Copy to clipboard button
│ └─────────────────────────┘ │
├─────────────────────────────┤
│ Bayar sebelum:              │
│ ⏱ 23:45:12                 │  ← Countdown timer (HH:MM:SS)
├─────────────────────────────┤
│ Cara Pembayaran:            │
│ • BCA Mobile Banking        │
│ • ATM BCA                   │
│ • Internet Banking KlikBCA  │
├─────────────────────────────┤
│ [Cek Status Pembayaran]     │  ← Manual refresh button
└─────────────────────────────┘
```

---

## Acceptance Criteria

### AC-1: Payment screen shows VA number from order
```gherkin
Given the user just placed an order and is on the payment screen
When the screen loads with orderId
Then GET /api/orders/:id is called once
And the VA number is displayed (from order.vaNumber)
And the payment amount is displayed using CurrencyFormatter
And the order number is displayed
If order.vaNumber is null
Then "Sedang membuat nomor VA..." is shown with a loading indicator
```

### AC-2: Countdown timer counts down to VA expiry
```gherkin
Given order.vaExpiresAt is set (e.g. 24 hours from order creation)
When the payment screen is visible
Then a countdown timer shows remaining time in HH:MM:SS format
And the timer decrements every second
When the timer reaches 00:00:00
Then the timer shows "Waktu pembayaran habis"
And the VA number is grayed out
And a "Pesanan Dibatalkan" message is shown
```

### AC-3: Auto-polling detects payment confirmation
```gherkin
Given the user is on the payment screen
When the screen is active
Then GET /api/orders/:id is polled every 10 seconds
When the response shows paymentStatus = "paid"
Then polling stops
And the screen navigates to the payment success screen
And the success screen shows order number and confirmation message
```

### AC-4: Manual status check button
```gherkin
Given the user taps "Cek Status Pembayaran"
Then GET /api/orders/:id is called immediately
And a loading indicator shows on the button
If paymentStatus = "paid"
Then navigate to success screen
If paymentStatus = "unpaid"
Then show "Pembayaran belum diterima. Silakan tunggu."
```

### AC-5: Copy VA number to clipboard
```gherkin
Given the VA number is displayed
When the user taps "Salin"
Then the VA number is copied to the device clipboard
And a snackbar confirms "Nomor VA disalin"
```

### AC-6: Polling stops when screen is disposed
```gherkin
Given the user navigates away from the payment screen
When the screen is disposed
Then the polling timer is cancelled
And no further API calls are made
```

### AC-7: Payment success screen
```gherkin
Given the payment is confirmed (paymentStatus = "paid")
When the success screen is shown
Then it displays: order number, total amount, "Pembayaran Berhasil" message
And a "Lihat Pesanan" button navigates to /orders/:id
And the back button is disabled (cannot go back to payment screen)
```

---

## Provider Design

```dart
class PaymentPollingNotifier extends AutoDisposeAsyncNotifier<Order> {
  Timer? _pollingTimer;

  @override
  Future<Order> build(String orderId) async {
    ref.onDispose(() => _pollingTimer?.cancel());
    final order = await ref.read(orderRepositoryProvider).getOrderById(orderId);
    if (order.paymentStatus != 'paid') _startPolling(orderId);
    return order;
  }

  void _startPolling(String orderId) {
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      final order = await ref.read(orderRepositoryProvider).getOrderById(orderId);
      state = AsyncData(order);
      if (order.paymentStatus == 'paid') {
        _pollingTimer?.cancel();
      }
    });
  }

  Future<void> checkNow(String orderId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() =>
      ref.read(orderRepositoryProvider).getOrderById(orderId)
    );
  }
}

final paymentPollingProvider = AsyncNotifierProvider.autoDispose.family<PaymentPollingNotifier, Order, String>(
  PaymentPollingNotifier.new,
);
```

---

## Countdown Timer

```dart
// Computed from order.vaExpiresAt
// Update every second via Timer.periodic in the widget (not provider)
// Format: HH:MM:SS
// When expired: show "Waktu pembayaran habis", stop timer

Duration get remaining {
  if (vaExpiresAt == null) return Duration.zero;
  final diff = vaExpiresAt!.difference(DateTime.now());
  return diff.isNegative ? Duration.zero : diff;
}
```

---

## Verification Checklist

- [ ] VA number displayed from order.vaNumber
- [ ] Null vaNumber shows loading placeholder
- [ ] Countdown timer counts down correctly
- [ ] Timer stops and shows expired message at 00:00:00
- [ ] Polling every 10 seconds while screen is active
- [ ] Polling stops on screen dispose
- [ ] Payment confirmed → navigate to success screen
- [ ] Manual "Cek Status" button works
- [ ] Copy VA to clipboard works
- [ ] Success screen back button disabled
- [ ] `flutter analyze` clean
