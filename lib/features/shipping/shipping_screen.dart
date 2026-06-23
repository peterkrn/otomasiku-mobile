import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../l10n/app_localizations.dart';
import '../../models/address.dart';
import '../../providers/address_provider.dart';
import '../../shared/widgets/app_error_view.dart';

class ShippingScreen extends ConsumerStatefulWidget {
  final bool isSelectable;

  const ShippingScreen({super.key, this.isSelectable = true});

  @override
  ConsumerState<ShippingScreen> createState() => _ShippingScreenState();
}

class _ShippingScreenState extends ConsumerState<ShippingScreen> {
  String? _selectedAddressId;

  void _selectAddress(Address address) {
    if (!widget.isSelectable) return;
    setState(() => _selectedAddressId = address.id);
  }

  void _goToEdit(String? addressId) {
    final params = <String, String>{};
    if (addressId != null) params['addressId'] = addressId;
    context.pushNamed(AppRoute.editAddress, queryParameters: params);
  }

  void _useSelected() {
    final addresses = ref.read(addressListProvider).valueOrNull ?? [];
    final selected = addresses.where((a) => a.id == _selectedAddressId).firstOrNull;
    if (selected != null) {
      context.pop(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final addressesAsync = ref.watch(addressListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF3F4F6),
      appBar: AppBar(
        leading: BackButton(onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.goNamed(AppRoute.home);
          }
        }),
        title: Text(
          l10n.shippingAddress,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        elevation: 0,
      ),
      body: addressesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => AppErrorView(
          error: error,
          onRetry: () => ref.invalidate(addressListProvider),
        ),
        data: (addresses) {
          if (addresses.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_off, size: 48, color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary),
                    const SizedBox(height: 16),
                    Text(
                      l10n.noAddressSaved,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => _goToEdit(null),
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(l10n.addAddress),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mitsubishiRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.isSelectable)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      l10n.selectAddress,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ...addresses.map((address) => _buildAddressCard(address, l10n, isDark)),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _goToEdit(null),
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(l10n.addAddress),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: widget.isSelectable
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black.withValues(alpha: 0.3) : const Color(0x1A000000),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selectedAddressId != null ? _useSelected : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mitsubishiRed,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFE5E7EB),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          l10n.useAddress,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildAddressCard(Address address, AppLocalizations l10n, bool isDark) {
    final isSelected = address.id == _selectedAddressId;

    return GestureDetector(
      onTap: widget.isSelectable ? () => _selectAddress(address) : () => _goToEdit(address.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.mitsubishiRed : (isDark ? AppColors.darkBorder : AppColors.border),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.isSelectable)
              Container(
                width: 20,
                height: 20,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.mitsubishiRed : (isDark ? AppColors.darkBorder : AppColors.border),
                    width: isSelected ? 5 : 2,
                  ),
                ),
              ),
            if (widget.isSelectable) const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        address.recipient,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                      ),
                      if (address.isDefault) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.blue.withValues(alpha: 0.2) : const Color(0xFFDBEAFE),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            l10n.primary,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.blue.shade300 : const Color(0xFF1D4ED8),
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      GestureDetector(
                        onTap: () => _goToEdit(address.id),
                        child: Text(
                          l10n.edit,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.mitsubishiRed,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address.phone,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${address.street}, ${address.city}, ${address.province} ${address.postalCode}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
