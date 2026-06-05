import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app.dart';
import 'core/config/env_config.dart';
import 'core/errors/app_error_widget.dart';
import 'core/network/api_client.dart';
import 'core/notifications/notification_service.dart';
import 'core/router/app_router.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Global Flutter error safety net — shows branded screen instead of red box.
  ErrorWidget.builder = (details) => AppErrorWidget(details);

  // Route Flutter framework errors to Crashlytics.
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    FirebaseCrashlytics.instance.recordFlutterFatalError(details);
  };

  // Route platform / async errors to Crashlytics.
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

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

  // Listen for password recovery deep link
  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    if (data.event == AuthChangeEvent.passwordRecovery) {
      appRouter.goNamed(AppRoute.resetPassword);
    }
  });

  final notificationService = NotificationService();
  await notificationService.initialize(router: appRouter);

  runZonedGuarded(
    () => runApp(ProviderScope(child: const OtomasikuApp())),
    (error, stack) {
      debugPrint('[Zone] Uncaught error: $error');
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    },
  );
}
