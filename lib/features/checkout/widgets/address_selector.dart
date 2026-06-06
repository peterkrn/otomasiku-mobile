import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/address_provider.dart';
import '../../../shared/widgets/app_error_view.dart';

class AddressSelector extends ConsumerWidget {
  final String? selectedAddressId;
  final ValueChanged<String> onAddressSelected;
  final bool isDark;

  const AddressSelector({
    super.key,
    required this.selectedAddressId,
    required this.onAddressSelected,
    required this.isDark,
  });

  void _showAddressPicker(BuildContext context, List addresses) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              l10n.selectAddress,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          ...addresses.map((addr) => ListTile(
            leading: Icon(
              addr.id == selectedAddressId
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: AppColors.mitsubishiRed,
            ),
            title: Text('${addr.recipient} (${addr.label})'),
            subtitle: Text('${addr.street}, ${addr.city}'),
            onTap: () {
              onAddressSelected(addr.id);
              Navigator.pop(ctx);
            },
          )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final addresses = ref.watch(addressListProvider);

    return addresses.when(
      data: (addresses) {
        if (addresses.isEmpty) {
          return GestureDetector(
            onTap: () => context.pushNamed(AppRoute.editAddress),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.mitsubishiRed),
              ),
              child: Row(
                children: [
                  const Icon(Icons.add_location, color: AppColors.mitsubishiRed, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    l10n.noAddress,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.mitsubishiRed,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final selected = addresses.firstWhere(
          (a) => a.id == selectedAddressId,
          orElse: () => addresses.first,
        );

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                right: 0,
                child: Icon(Icons.location_on, color: AppColors.mitsubishiRed, size: 20),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        selected.recipient,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.bcaBlue.withValues(alpha: 0.2)
                              : Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          selected.label,
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark ? AppColors.bcaBlue : Colors.blue.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${selected.street}\n${selected.city}, ${selected.province} ${selected.postalCode}\n${selected.phone}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () => _showAddressPicker(context, addresses),
                        icon: const Icon(Icons.swap_horiz, size: 16),
                        label: Text(l10n.changeAddress),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.mitsubishiRed,
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      const SizedBox(width: 12),
                      TextButton.icon(
                        onPressed: () => context.pushNamed(AppRoute.editAddress),
                        icon: const Icon(Icons.add, size: 16),
                        label: Text(l10n.addAddress),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.mitsubishiRed,
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox(
        height: 60,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => AppErrorView(
        error: e,
        onRetry: () => ref.invalidate(addressListProvider),
      ),
    );
  }
}
