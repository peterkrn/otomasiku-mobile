import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

/// Global error widget shown by [ErrorWidget.builder].
/// Constraint-safe: uses intrinsic sizing so it fits in any parent.
class AppErrorWidget extends StatelessWidget {
  final FlutterErrorDetails details;

  const AppErrorWidget(this.details, {super.key});

  String _message(BuildContext context) {
    try {
      return AppLocalizations.of(context).errorGeneric;
    } catch (_) {
      return 'Something went wrong.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Color(0xFFE7192D)),
              const SizedBox(height: 12),
              Text(
                _message(context),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              if (kDebugMode) ...[
                const SizedBox(height: 8),
                SingleChildScrollView(
                  child: Text(
                    details.exceptionAsString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
