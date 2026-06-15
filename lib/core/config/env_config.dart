import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  EnvConfig._();

  static String get apiBaseUrl => dotenv.get(
        'API_BASE_URL',
        fallback: 'https://otomasiku-backend-staging-2127.up.railway.app/api',
      );

  static String get supabaseUrl => dotenv.get('SUPABASE_URL');

  static String get supabaseAnonKey => dotenv.get('SUPABASE_ANON_KEY');

  static String get bcaVaNumber => dotenv.get('BCA_VA_NUMBER', fallback: '');

  static String get bcaAccountName =>
      dotenv.get('BCA_ACCOUNT_NAME', fallback: 'PT Otomasiku Nusantara');

  static String get whatsappNumber =>
      dotenv.get('WHATSAPP_NUMBER', fallback: '6281252078076');

  static String get deepLinkScheme =>
      dotenv.get('DEEP_LINK_SCHEME', fallback: 'com.otomasiku.app');
}
