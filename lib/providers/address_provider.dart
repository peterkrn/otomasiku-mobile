import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/address_repository.dart';
import '../models/address.dart';
import 'repository_providers.dart';

final addressListProvider =
    AsyncNotifierProvider<AddressListNotifier, List<Address>>(AddressListNotifier.new);

class AddressListNotifier extends AsyncNotifier<List<Address>> {
  @override
  Future<List<Address>> build() =>
      ref.read(addressRepositoryProvider).getAddresses();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(addressRepositoryProvider).getAddresses(),
    );
  }
}

final addressNotifierProvider = Provider<AddressNotifier>((ref) {
  return AddressNotifier(ref, ref.read(addressRepositoryProvider));
});

class AddressNotifier {
  AddressNotifier(this._ref, this._repository);

  final Ref _ref;
  final AddressRepository _repository;

  Future<Address> createAddress(AddressInput input) async {
    final address = await _repository.createAddress(input);
    await _ref.read(addressListProvider.notifier).refresh();
    return address;
  }

  Future<Address> updateAddress(String id, AddressInput input) async {
    final address = await _repository.updateAddress(id, input);
    await _ref.read(addressListProvider.notifier).refresh();
    return address;
  }

  Future<void> deleteAddress(String id) async {
    await _repository.deleteAddress(id);
    await _ref.read(addressListProvider.notifier).refresh();
  }
}
