import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  EnvConfig._();

  static String get apiBaseUrl => dotenv.get(
        'API_BASE_URL',
        fallback:
            'https://otomasiku-backend-staging.up.railway.app/api',
      );

  static String get supabaseUrl => dotenv.get('SUPABASE_URL');

  static String get supabaseAnonKey => dotenv.get('SUPABASE_ANON_KEY');

  static String get bcaVaNumber => dotenv.get('BCA_VA_NUMBER', fallback: '');

  static String get bcaAccountName =>
      dotenv.get('BCA_ACCOUNT_NAME', fallback: 'PT Otomasiku Nusantara');
}
