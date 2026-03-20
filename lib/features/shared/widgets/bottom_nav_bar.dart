import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/cart_provider.dart';

/// Bottom navigation bar with 5 tabs: Beranda, Cari, Proyek, Keranjang, Profil
/// Uses StatefulNavigationShell for proper state preservation
class BottomNavBar extends ConsumerWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final cartItems = ref.watch(cartProvider).items;
    final cartCount = cartItems.fold(0, (sum, item) => sum + item.quantity);

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap ?? (index) {},
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 8,
      shadowColor: Colors.black26,
      height: 56,
      destinations: [
        // Tab 1: Beranda (Home)
        NavigationDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home, color: Color(0xFFE7192D)),
          label: l10n.home,
        ),
        // Tab 2: Cari (Search)
        NavigationDestination(
          icon: const Icon(Icons.search_outlined),
          selectedIcon: const Icon(Icons.search, color: Color(0xFFE7192D)),
          label: l10n.search,
        ),
        // Tab 3: Proyek (Projects)
        NavigationDestination(
          icon: const Icon(Icons.folder_outlined),
          selectedIcon: const Icon(Icons.folder, color: Color(0xFFE7192D)),
          label: l10n.project,
        ),
        // Tab 4: Keranjang (Cart)
        NavigationDestination(
          icon: Badge(
            isLabelVisible: cartCount > 0,
            label: Text('$cartCount'),
            child: const Icon(Icons.shopping_cart_outlined),
          ),
          selectedIcon: Badge(
            isLabelVisible: cartCount > 0,
            label: Text('$cartCount'),
            child: const Icon(Icons.shopping_cart, color: Color(0xFFE7192D)),
          ),
          label: l10n.cart,
        ),
        // Tab 5: Profil (Profile)
        NavigationDestination(
          icon: const Icon(Icons.person_outline),
          selectedIcon: const Icon(Icons.person, color: Color(0xFFE7192D)),
          label: l10n.profile,
        ),
      ],
    );
  }
}
