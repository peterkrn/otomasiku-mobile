import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  EnvConfig._();

  static String get apiBaseUrl => dotenv.get(
    'API_BASE_URL',
    fallback: 'https://otomasiku-backend-production.up.railway.app/api',
  );

  static String get privacyPolicyUrl => dotenv.get(
    'PRIVACY_POLICY_URL',
    fallback: 'https://otomasiku.com/privacy-policy/index.html',
  );

  static String get supabaseUrl => dotenv.get('SUPABASE_URL');

  static String get supabaseAnonKey => dotenv.get('SUPABASE_ANON_KEY');

  static String get bcaVaNumber => dotenv.get('BCA_VA_NUMBER', fallback: '');

  static String get bcaAccountName => dotenv.get(
    'BCA_ACCOUNT_NAME',
    fallback: 'PT. Abadi Bangun Bersama (Otomasiku.com)',
  );

  static String get whatsappNumber =>
      dotenv.get('ADMIN_WHATSAPP_NUMBER', fallback: 'CHANGE_ME');

  static String get supportEmail => dotenv.get('SUPPORT_EMAIL', fallback: '');

  static bool get hasSupportWhatsapp {
    final number = whatsappNumber.trim();
    return number.isNotEmpty && number != 'CHANGE_ME';
  }

  static String get supportWhatsappDisplay {
    final number = whatsappNumber.trim();
    if (number.isEmpty || number == 'CHANGE_ME') {
      return '';
    }

    return number.startsWith('+') ? number : '+$number';
  }

  static String get deepLinkScheme =>
      dotenv.get('DEEP_LINK_SCHEME', fallback: 'com.otomasiku.app');
}
