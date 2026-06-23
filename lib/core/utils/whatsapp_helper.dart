import 'package:url_launcher/url_launcher.dart';

class WhatsAppHelper {
  static const _phone = '6281252078076';

  static Future<void> openRfq({String? productName, String? quantity}) async {
    final buffer = StringBuffer('Halo, saya mau tanya terkait Otomasiku.');
    if (productName != null) {
      buffer.write('\n\nProduk: $productName');
    }
    if (quantity != null && quantity.isNotEmpty) {
      buffer.write('\nJumlah: $quantity unit');
    }

    final message = Uri.encodeComponent(buffer.toString());
    final url = Uri.parse('https://wa.me/$_phone?text=$message');
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }
}
