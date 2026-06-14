import 'package:url_launcher/url_launcher.dart';

import '../config/env_config.dart';

class WhatsAppHelper {
  static String get _phone => EnvConfig.whatsappNumber;

  static Future<void> openRfq({String? productName, String? quantity}) async {
    final buffer = StringBuffer('Halo, saya mau tanya terkait Otomasiku.');
    if (productName != null) {
      buffer.write('\n\nProduk: $productName');
    }
    if (quantity != null && quantity.isNotEmpty) {
      buffer.write('\nJumlah: $quantity unit');
    }

    await _launch(_phone, buffer.toString());
  }

  /// Open WhatsApp with a pre-filled message asking the admin when an unpriced
  /// product will become available for purchase.
  static Future<void> openProductAvailabilityInquiry(
    String productName, {
    String locale = 'id',
  }) async {
    final String message = locale == 'id'
        ? 'Halo Admin Otomasiku, saya ingin bertanya kapan produk "$productName" '
            'akan tersedia untuk dipesan? Terima kasih.'
        : 'Hello Otomasiku Admin, I would like to ask when the product '
            '"$productName" will be available to order? Thank you.';

    await _launch(_phone, message);
  }

  static Future<void> _launch(String phone, String message) async {
    final encoded = Uri.encodeComponent(message);
    final url = Uri.parse('https://wa.me/$phone?text=$encoded');
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }
}
