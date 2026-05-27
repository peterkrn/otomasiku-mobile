import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:otomasiku_mobile/data/repositories/address_repository.dart';
import 'package:otomasiku_mobile/models/address.dart';
import 'package:otomasiku_mobile/providers/address_provider.dart';
import 'package:otomasiku_mobile/providers/repository_providers.dart';

Address _addr(String id) => Address(
      id: id,
      label: 'Rumah',
      recipient: 'Budi',
      phone: '08123456789',
      street: 'Jl. Merdeka No. 1',
      city: 'Jakarta',
      province: 'DKI Jakarta',
      postalCode: '10110',
      isDefault: false,
      createdAt: DateTime.utc(2026, 1, 1),
    );

void main() {
  group('AddressListNotifier', () {
    late _MockAddressRepository mockRepo;

    setUp(() {
      mockRepo = _MockAddressRepository();
      mockRepo.addresses = [_addr('addr-1'), _addr('addr-2')];
    });

    ProviderContainer createContainer() => ProviderContainer(
          overrides: [
            addressRepositoryProvider.overrideWithValue(mockRepo),
          ],
        );

    test('loads addresses on build', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      final list = await container.read(addressListProvider.future);

      expect(list, hasLength(2));
      expect(mockRepo.getAddressesCallCount, 1);
    });

    test('persists state — does not re-fetch on second read', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      await container.read(addressListProvider.future);
      await container.read(addressListProvider.future);

      expect(mockRepo.getAddressesCallCount, 1);
    });

    test('refresh() re-fetches from API', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      await container.read(addressListProvider.future);
      await container.read(addressListProvider.notifier).refresh();

      expect(mockRepo.getAddressesCallCount, 2);
    });

    test('createAddress refreshes list', () async {
      final newAddr = _addr('addr-new');
      mockRepo.createResult = newAddr;

      final container = createContainer();
      addTearDown(container.dispose);

      await container.read(addressListProvider.future);

      final notifier = container.read(addressNotifierProvider);
      await notifier.createAddress(AddressInput(
        label: 'Kantor',
        recipient: 'Siti',
        phone: '08198765432',
        street: 'Jl. Sudirman',
        city: 'Jakarta',
        province: 'DKI Jakarta',
        postalCode: '10220',
      ));

      // List should have been refreshed
      expect(mockRepo.getAddressesCallCount, 2);
    });
  });
}

class _MockAddressRepository implements AddressRepository {
  List<Address> addresses = [];
  Address? createResult;
  int getAddressesCallCount = 0;

  @override
  Future<List<Address>> getAddresses() async {
    getAddressesCallCount++;
    return addresses;
  }

  @override
  Future<Address> getAddressById(String id) async =>
      addresses.firstWhere((a) => a.id == id);

  @override
  Future<Address> createAddress(AddressInput input) async =>
      createResult ?? addresses.first;

  @override
  Future<Address> updateAddress(String id, AddressInput input) async =>
      addresses.firstWhere((a) => a.id == id);

  @override
  Future<void> deleteAddress(String id) async {}
}
