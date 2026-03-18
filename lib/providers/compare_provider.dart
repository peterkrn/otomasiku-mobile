import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for managing product compare list (max 3 products)
final compareProvider = StateNotifierProvider<CompareNotifier, CompareState>((ref) {
  return CompareNotifier();
});

/// Compare list state
class CompareState {
  final List<String> productIds;

  const CompareState({
    required this.productIds,
  });

  /// Check if product is in compare list
  bool isInCompare(String productId) => productIds.contains(productId);

  /// Count of products in compare list
  int get count => productIds.length;

  /// Check if can add more products (max 3)
  bool get canAddMore => productIds.length < 3;

  CompareState copyWith({
    List<String>? productIds,
  }) {
    return CompareState(
      productIds: productIds ?? this.productIds,
    );
  }
}

/// Compare notifier
class CompareNotifier extends StateNotifier<CompareState> {
  CompareNotifier() : super(const CompareState(productIds: []));

  /// Toggle product in compare list
  /// - If already in list → remove
  /// - If not in list AND count < 3 → add
  /// - If count == 3 and trying to add → return false (caller shows error toast)
  bool toggle(String productId) {
    if (state.productIds.contains(productId)) {
      // Remove from list
      state = state.copyWith(
        productIds: state.productIds.where((id) => id != productId).toList(),
      );
      return true;
    } else {
      if (state.productIds.length >= 3) {
        // Max reached
        return false;
      }
      // Add to list
      state = state.copyWith(
        productIds: [...state.productIds, productId],
      );
      return true;
    }
  }

  /// Clear compare list
  void clear() {
    state = const CompareState(productIds: []);
  }
}
