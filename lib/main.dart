import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app.dart';
import 'core/config/env_config.dart';
import 'core/network/api_client.dart';
import 'core/notifications/notification_service.dart';
import 'core/router/app_router.dart';
import 'data/repositories/fake_order_repository.dart';
import 'data/repositories/fake_payment_repository.dart';
import 'firebase_options.dart';
import 'providers/repository_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Supabase.initialize(
    url: EnvConfig.supabaseUrl,
    anonKey: EnvConfig.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  ApiClient().configure(
    supabase: Supabase.instance.client,
    onSessionExpired: () => appRouter.goNamed(AppRoute.login),
  );

  final notificationService = NotificationService();
  await notificationService.initialize(router: appRouter);

  runApp(ProviderScope(
    overrides: [
      if (kDebugMode) ...[
        orderRepositoryProvider.overrideWithValue(FakeOrderRepository()),
        paymentRepositoryProvider.overrideWithValue(FakePaymentRepository()),
      ],
    ],
    child: const OtomasikuApp(),
  ));
}
