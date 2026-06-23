import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/feature_flags.dart';
import '../../../core/constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';

/// Bottom navigation bar with the currently visible marketplace tabs.
/// Uses StatefulNavigationShell for proper state preservation
class BottomNavBar extends ConsumerWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const BottomNavBar({super.key, required this.currentIndex, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap ?? (index) {},
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      surfaceTintColor: isDark ? AppColors.darkSurface : Colors.white,
      elevation: 8,
      shadowColor: isDark ? Colors.black45 : Colors.black26,
      height: 56,
      indicatorColor: AppColors.mitsubishiRed.withValues(
        alpha: isDark ? 0.2 : 0.1,
      ),
      destinations: [
        NavigationDestination(
          icon: Icon(
            Icons.home_outlined,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textTertiary,
          ),
          selectedIcon: const Icon(Icons.home, color: AppColors.mitsubishiRed),
          label: l10n.home,
        ),
        NavigationDestination(
          icon: Icon(
            Icons.search_outlined,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textTertiary,
          ),
          selectedIcon: const Icon(
            Icons.search,
            color: AppColors.mitsubishiRed,
          ),
          label: l10n.search,
        ),
        if (isProjectFeatureEnabled)
          NavigationDestination(
            icon: Icon(
              Icons.folder_outlined,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textTertiary,
            ),
            selectedIcon: const Icon(
              Icons.folder,
              color: AppColors.mitsubishiRed,
            ),
            label: l10n.project,
          ),
        NavigationDestination(
          icon: Icon(
            Icons.person_outline,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textTertiary,
          ),
          selectedIcon: const Icon(
            Icons.person,
            color: AppColors.mitsubishiRed,
          ),
          label: l10n.profile,
        ),
      ],
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return TextStyle(
            color: AppColors.mitsubishiRed,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          );
        }
        return TextStyle(
          color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
          fontSize: 12,
        );
      }),
    );
  }
}
