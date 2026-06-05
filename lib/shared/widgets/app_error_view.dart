import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/error_handler.dart';
import '../../l10n/app_localizations.dart';

/// Adapts [AppLocalizations] to the [ErrorL10n] interface required by [errorMessageFor].
extension AppLocalizationsErrorL10n on AppLocalizations {
  ErrorL10n get asErrorL10n => _AppLocalizationsErrorL10nImpl(this);
}

class _AppLocalizationsErrorL10nImpl implements ErrorL10n {
  final AppLocalizations _l10n;
  const _AppLocalizationsErrorL10nImpl(this._l10n);

  @override String get errorOffline => _l10n.errorOffline;
  @override String get errorTimeout => _l10n.errorTimeout;
  @override String get errorSessionExpired => _l10n.errorSessionExpired;
  @override String get errorServer => _l10n.errorServer;
  @override String get errorGeneric => _l10n.errorGeneric;

  // Backend error code getters
  @override String get errorInvalidCredentials => _l10n.errorInvalidCredentials;
  @override String get errorUserNotFound => _l10n.errorUserNotFound;
  @override String get errorDuplicateEntry => _l10n.errorDuplicateEntry;
  @override String get errorWeakPassword => _l10n.errorWeakPassword;
  @override String get errorUnauthorized => _l10n.errorUnauthorized;
  @override String get errorProductNotFound => _l10n.errorProductNotFound;
  @override String get outOfStock => _l10n.outOfStock;
  @override String get available => _l10n.available;
  @override String insufficientStock(int count) => _l10n.insufficientStock(count);
  @override String get orderNotFound => _l10n.orderNotFound;
  @override String get errorOrderPaid => _l10n.errorOrderPaid;
  @override String get cancelled => _l10n.cancelled;
  @override String get errorPaymentFailed => _l10n.errorPaymentFailed;
  @override String get errorBcaVaExpired => _l10n.errorBcaVaExpired;
  @override String get errorInvalidAmount => _l10n.errorInvalidAmount;
  @override String get errorCartEmpty => _l10n.errorCartEmpty;
  @override String get errorInvalidQuantity => _l10n.errorInvalidQuantity;
  @override String get errorValidation => _l10n.errorValidation;
  @override String get errorServiceUnavailable => _l10n.errorServiceUnavailable;
}

/// A box (non-sliver) error state widget.
/// Use [AppErrorSliver] when inside a [CustomScrollView].
class AppErrorView extends StatelessWidget {
  final Object error;
  final VoidCallback? onRetry;

  const AppErrorView({super.key, required this.error, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final message = errorMessageFor(error, l10n.asErrorL10n);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 56,
              color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mitsubishiRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(l10n.retry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Sliver variant of [AppErrorView] — use inside [CustomScrollView].
class AppErrorSliver extends StatelessWidget {
  final Object error;
  final VoidCallback? onRetry;

  const AppErrorSliver({super.key, required this.error, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: AppErrorView(error: error, onRetry: onRetry),
    );
  }
}
