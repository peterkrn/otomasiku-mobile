import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/compare_provider.dart';

/// Compare bar widget - slides up from bottom when products are added to compare
/// Positioned above bottom navigation bar
class CompareBar extends ConsumerWidget {
  const CompareBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final compareState = ref.watch(compareProvider);

    if (compareState.productIds.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedSlide(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      offset: const Offset(0, 0),
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: AppColors.border, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Product count text
                Expanded(
                  child: Text(
                    l10n.productSelected(compareState.count),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                // Hapus button
                OutlinedButton(
                  onPressed: () {
                    ref.read(compareProvider.notifier).clear();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    l10n.removeSelection,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Bandingkan button
                ElevatedButton(
                  onPressed: () => context.pushNamed('compare'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mitsubishiRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    l10n.compareProduct,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
