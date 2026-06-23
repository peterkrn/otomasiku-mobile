import 'package:dio/dio.dart';

import '../../core/errors/app_exception.dart';
import '../../core/network/api_response.dart';
import '../../models/address.dart';

abstract class AddressRepository {
  Future<List<Address>> getAddresses();
  Future<Address> getAddressById(String id);
  Future<Address> createAddress(AddressInput input);
  Future<Address> updateAddress(String id, AddressInput input);
  Future<void> deleteAddress(String id);
}

class AddressRepositoryImpl implements AddressRepository {
  AddressRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<Address>> getAddresses() async {
    final response = await _dio.get('/addresses');
    final json = response.data as Map<String, dynamic>;
    final success = json['success'] as bool? ?? false;

    if (!success || json['data'] == null) {
      throw ApiException(
        code: 'UNKNOWN',
        statusCode: response.statusCode ?? 200,
      );
    }

    final dataList = json['data'] as List;
    return dataList
        .map((e) => Address.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Address> getAddressById(String id) async {
    final response = await _dio.get('/addresses/$id');
    final apiResponse =
        ApiResponse<Map<String, dynamic>>.fromJson(
          response.data as Map<String, dynamic>,
          null,
        );

    if (!apiResponse.success || apiResponse.data == null) {
      throw ApiException(
        code: apiResponse.error?.code ?? 'UNKNOWN',
        statusCode: response.statusCode ?? 200,
        details: apiResponse.error?.details,
      );
    }

    return Address.fromJson(apiResponse.data!);
  }

  @override
  Future<Address> createAddress(AddressInput input) async {
    final response = await _dio.post('/addresses', data: input.toJson());
    final apiResponse =
        ApiResponse<Map<String, dynamic>>.fromJson(
          response.data as Map<String, dynamic>,
          null,
        );

    if (!apiResponse.success || apiResponse.data == null) {
      throw ApiException(
        code: apiResponse.error?.code ?? 'UNKNOWN',
        statusCode: response.statusCode ?? 200,
        details: apiResponse.error?.details,
      );
    }

    return Address.fromJson(apiResponse.data!);
  }

  @override
  Future<Address> updateAddress(String id, AddressInput input) async {
    final response = await _dio.put('/addresses/$id', data: input.toJson());
    final apiResponse =
        ApiResponse<Map<String, dynamic>>.fromJson(
          response.data as Map<String, dynamic>,
          null,
        );

    if (!apiResponse.success || apiResponse.data == null) {
      throw ApiException(
        code: apiResponse.error?.code ?? 'UNKNOWN',
        statusCode: response.statusCode ?? 200,
        details: apiResponse.error?.details,
      );
    }

    return Address.fromJson(apiResponse.data!);
  }

  @override
  Future<void> deleteAddress(String id) async {
    await _dio.delete('/addresses/$id');
  }
}

class AddressInput {
  final String label;
  final String recipient;
  final String phone;
  final String street;
  final String city;
  final String province;
  final String postalCode;
  final bool isDefault;

  const AddressInput({
    required this.label,
    required this.recipient,
    required this.phone,
    required this.street,
    required this.city,
    required this.province,
    required this.postalCode,
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() => {
    'label': label,
    'recipient': recipient,
    'phone': phone,
    'street': street,
    'city': city,
    'province': province,
    'postalCode': postalCode,
    'isDefault': isDefault,
  };
}
