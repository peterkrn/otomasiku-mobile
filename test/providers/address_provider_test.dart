import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:otomasiku_mobile/data/repositories/address_repository.dart';
import 'package:otomasiku_mobile/models/address.dart';
import 'package:otomasiku_mobile/providers/address_provider.dart';
import 'package:otomasiku_mobile/providers/repository_providers.dart';

Address _address({
  required String id,
  String label = 'Rumah',
  String recipient = 'Budi',
  String phone = '08123456789',
  String street = 'Jl. Merdeka No. 1',
  String city = 'Jakarta',
  String province = 'DKI Jakarta',
  String postalCode = '10110',
  bool isDefault = false,
  DateTime? createdAt,
}) {
  return Address(
    id: id,
    label: label,
    recipient: recipient,
    phone: phone,
    street: street,
    city: city,
    province: province,
    postalCode: postalCode,
    isDefault: isDefault,
    createdAt: createdAt ?? DateTime.utc(2026, 1, 1),
  );
}

void main() {
  group('addressListProvider', () {
    test('returns list from repository', () async {
      final addresses = [
        _address(id: 'addr-1'),
        _address(id: 'addr-2', label: 'Kantor'),
      ];

      final mockRepository = MockAddressRepository();
      mockRepository.addresses = addresses;

      final container = ProviderContainer(
        overrides: [
          addressRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);

      final list = await container.read(addressListProvider.future);

      expect(list, addresses);
      expect(mockRepository.getAddressesCallCount, 1);
    });
  });

  group('AddressNotifier', () {
    ProviderContainer createContainer(MockAddressRepository mock) {
      return ProviderContainer(
        overrides: [
          addressRepositoryProvider.overrideWithValue(mock),
        ],
      );
    }

    test('createAddress calls repository and invalidates list', () async {
      final mockRepository = MockAddressRepository();
      mockRepository.addresses = [
        _address(id: 'addr-1'),
      ];

      final input = AddressInput(
        label: 'Kantor',
        recipient: 'Siti',
        phone: '08198765432',
        street: 'Jl. Sudirman No. 10',
        city: 'Jakarta',
        province: 'DKI Jakarta',
        postalCode: '10220',
        isDefault: false,
      );

      final created = _address(id: 'addr-new', label: 'Kantor');
      mockRepository.createResult = created;

      final container = createContainer(mockRepository);
      addTearDown(container.dispose);

      // Read list first to establish baseline
      final initialList = await container.read(addressListProvider.future);
      expect(initialList.length, 1);

      final notifier = container.read(addressNotifierProvider);
      final result = await notifier.createAddress(input);

      expect(result, created);
      expect(mockRepository.createInput, input);
      expect(mockRepository.createCallCount, 1);

      // After invalidation, list should refetch
      final refreshedList = await container.read(addressListProvider.future);
      expect(refreshedList, mockRepository.addresses);
      // Baseline read (1) + invalidation refetch (1)
      expect(mockRepository.getAddressesCallCount, 2);
    });

    test('updateAddress calls repository and invalidates list', () async {
      final mockRepository = MockAddressRepository();
      mockRepository.addresses = [
        _address(id: 'addr-1', isDefault: true),
      ];

      final input = AddressInput(
        label: 'Rumah Baru',
        recipient: 'Budi',
        phone: '08123456789',
        street: 'Jl. Baru No. 5',
        city: 'Jakarta',
        province: 'DKI Jakarta',
        postalCode: '10110',
        isDefault: true,
      );

      final updated = _address(id: 'addr-1', label: 'Rumah Baru', isDefault: true);
      mockRepository.updateResult = updated;

      final container = createContainer(mockRepository);
      addTearDown(container.dispose);

      await container.read(addressListProvider.future);

      final notifier = container.read(addressNotifierProvider);
      final result = await notifier.updateAddress('addr-1', input);

      expect(result, updated);
      expect(mockRepository.updateId, 'addr-1');
      expect(mockRepository.updateInput, input);
      expect(mockRepository.updateCallCount, 1);

      final refreshedList = await container.read(addressListProvider.future);
      expect(refreshedList, mockRepository.addresses);
      expect(mockRepository.getAddressesCallCount, 2);
    });

    test('deleteAddress calls repository and invalidates list', () async {
      final mockRepository = MockAddressRepository();
      mockRepository.addresses = [
        _address(id: 'addr-1'),
        _address(id: 'addr-2'),
      ];

      final container = createContainer(mockRepository);
      addTearDown(container.dispose);

      await container.read(addressListProvider.future);

      final notifier = container.read(addressNotifierProvider);
      await notifier.deleteAddress('addr-1');

      expect(mockRepository.deleteId, 'addr-1');
      expect(mockRepository.deleteCallCount, 1);

      final refreshedList = await container.read(addressListProvider.future);
      expect(refreshedList, mockRepository.addresses);
      expect(mockRepository.getAddressesCallCount, 2);
    });
  });
}

class MockAddressRepository implements AddressRepository {
  List<Address> addresses = [];
  Address? createResult;
  Address? updateResult;
  AddressInput? createInput;
  AddressInput? updateInput;
  String? updateId;
  String? deleteId;
  int getAddressesCallCount = 0;
  int createCallCount = 0;
  int updateCallCount = 0;
  int deleteCallCount = 0;

  @override
  Future<List<Address>> getAddresses() async {
    getAddressesCallCount++;
    return addresses;
  }

  @override
  Future<Address> getAddressById(String id) async {
    return addresses.firstWhere((a) => a.id == id);
  }

  @override
  Future<Address> createAddress(AddressInput input) async {
    createCallCount++;
    createInput = input;
    return createResult ?? addresses.first;
  }

  @override
  Future<Address> updateAddress(String id, AddressInput input) async {
    updateCallCount++;
    updateId = id;
    updateInput = input;
    return updateResult ?? addresses.first;
  }

  @override
  Future<void> deleteAddress(String id) async {
    deleteCallCount++;
    deleteId = id;
  }
}
