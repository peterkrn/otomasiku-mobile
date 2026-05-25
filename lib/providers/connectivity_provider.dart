import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/connectivity_service.dart';

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

final connectivityProvider = StreamProvider<bool>((ref) {
  final service = ref.read(connectivityServiceProvider);
  return service.isConnected;
});
