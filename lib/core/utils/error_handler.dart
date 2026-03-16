/// Translates error codes from Express backend to localized strings
/// Used when backend returns error.code instead of full messages
/// Source: docs/AI_RULES.md — "No hardcoded error text from Express"
String translateErrorCode(
  String code,
  Map<String, String> l10n, {
  Map<String, dynamic>? details,
}) {
  // Default fallbacks for each error code
  String fallback(String key) {
    switch (key) {
      case 'error_invalid_credentials':
        return 'Email atau kata sandi salah';
      case 'error_user_not_found':
        return 'Pengguna tidak ditemukan';
      case 'error_email_in_use':
        return 'Email sudah terdaftar';
      case 'error_weak_password':
        return 'Kata sandi minimal 6 karakter';
      case 'error_unauthorized':
        return 'Tidak memiliki akses';
      case 'error_product_not_found':
        return 'Produk tidak ditemukan';
      case 'error_out_of_stock':
        return 'Stok habis';
      case 'error_available':
        return 'tersedia';
      case 'error_insufficient_stock':
        return 'Stok tidak cukup';
      case 'error_order_not_found':
        return 'Pesanan tidak ditemukan';
      case 'error_order_paid':
        return 'Pesanan sudah dibayar';
      case 'error_order_cancelled':
        return 'Pesanan sudah dibatalkan';
      case 'error_payment_failed':
        return 'Pembayaran gagal';
      case 'error_va_expired':
        return 'Kode VA sudah kedaluwarsa';
      case 'error_invalid_amount':
        return 'Nominal tidak valid';
      case 'error_cart_empty':
        return 'Keranjang kosong';
      case 'error_invalid_quantity':
        return 'Jumlah tidak valid';
      case 'error_invalid_input':
        return 'Input tidak valid';
      case 'error_internal':
        return 'Terjadi kesalahan pada server';
      case 'error_service_unavailable':
        return 'Layanan sedang tidak tersedia';
      case 'error_unknown':
      default:
        return 'Terjadi kesalahan. Silakan coba lagi.';
    }
  }

  switch (code) {
    // Auth errors
    case 'INVALID_CREDENTIALS':
      return l10n['error_invalid_credentials'] ?? fallback('error_invalid_credentials');
    case 'USER_NOT_FOUND':
      return l10n['error_user_not_found'] ?? fallback('error_user_not_found');
    case 'EMAIL_ALREADY_IN_USE':
      return l10n['error_email_in_use'] ?? fallback('error_email_in_use');
    case 'WEAK_PASSWORD':
      return l10n['error_weak_password'] ?? fallback('error_weak_password');
    case 'UNAUTHORIZED':
      return l10n['error_unauthorized'] ?? fallback('error_unauthorized');

    // Product errors
    case 'PRODUCT_NOT_FOUND':
      return l10n['error_product_not_found'] ?? fallback('error_product_not_found');
    case 'OUT_OF_STOCK':
      final available = details?['available'] ?? 0;
      final outOfStock = l10n['error_out_of_stock'] ?? fallback('error_out_of_stock');
      final availableText = l10n['error_available'] ?? fallback('error_available');
      return '$outOfStock ($availableText: $available)';
    case 'INSUFFICIENT_STOCK':
      final available2 = details?['available'] ?? 0;
      final insufficientStock = l10n['error_insufficient_stock'] ?? fallback('error_insufficient_stock');
      final availableText2 = l10n['error_available'] ?? fallback('error_available');
      return '$insufficientStock ($availableText2: $available2)';

    // Order errors
    case 'ORDER_NOT_FOUND':
      return l10n['error_order_not_found'] ?? fallback('error_order_not_found');
    case 'ORDER_ALREADY_PAID':
      return l10n['error_order_paid'] ?? fallback('error_order_paid');
    case 'ORDER_CANCELLED':
      return l10n['error_order_cancelled'] ?? fallback('error_order_cancelled');

    // Payment errors
    case 'PAYMENT_FAILED':
      return l10n['error_payment_failed'] ?? fallback('error_payment_failed');
    case 'VA_EXPIRED':
      return l10n['error_va_expired'] ?? fallback('error_va_expired');
    case 'INVALID_AMOUNT':
      return l10n['error_invalid_amount'] ?? fallback('error_invalid_amount');

    // Cart errors
    case 'CART_EMPTY':
      return l10n['error_cart_empty'] ?? fallback('error_cart_empty');
    case 'INVALID_QUANTITY':
      return l10n['error_invalid_quantity'] ?? fallback('error_invalid_quantity');

    // Validation errors
    case 'VALIDATION_ERROR':
      final field = details?['field'] ?? '';
      final message = details?['message'] ?? '';
      return '$field: $message';
    case 'INVALID_INPUT':
      return l10n['error_invalid_input'] ?? fallback('error_invalid_input');

    // Server errors
    case 'INTERNAL_ERROR':
      return l10n['error_internal'] ?? fallback('error_internal');
    case 'SERVICE_UNAVAILABLE':
      return l10n['error_service_unavailable'] ?? fallback('error_service_unavailable');

    // Default
    default:
      return l10n['error_unknown'] ?? fallback('error_unknown');
  }
}
