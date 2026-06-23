import '../core/errors/app_exception.dart';

const orderNotReadyRetryDelay = Duration(milliseconds: 250);
const orderNotReadyMaxAttempts = 3;

Future<T> retryOrderNotReady<T>({
  required Future<T> Function() load,
  Duration delay = orderNotReadyRetryDelay,
  int maxAttempts = orderNotReadyMaxAttempts,
}) async {
  for (var attempt = 0; attempt < maxAttempts; attempt++) {
    try {
      return await load();
    } on ApiException catch (e) {
      final isLastAttempt = attempt == maxAttempts - 1;
      if (e.code != 'ORDER_NOT_READY' || isLastAttempt) {
        rethrow;
      }
      await Future<void>.delayed(delay);
    }
  }

  throw StateError(
    'retryOrderNotReady exhausted without returning or throwing',
  );
}
