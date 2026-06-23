import 'package:dio/dio.dart';

import '../../core/errors/app_exception.dart';
import '../../core/network/api_response.dart';
import '../../models/product.dart';

abstract class ProductRepository {
  Future<ProductListResponse> getProducts(ProductFilter filter);
  Future<Product> getProductById(String id);
  Future<List<Brand>> getBrands();
  Future<List<Category>> getCategories();
}

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<ProductListResponse> getProducts(ProductFilter filter) async {
    final response = await _dio.get(
      '/products',
      queryParameters: {
        if (filter.search != null) 'search': filter.search,
        if (filter.brand != null) 'brand': filter.brand,
        if (filter.category != null) 'category': filter.category,
        'page': filter.page,
        'pageSize': filter.pageSize,
      },
    );

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

    final data = apiResponse.data!;
    final rawData = data['data'];
    if (rawData is! List) throw ApiException(code: 'INVALID_RESPONSE', statusCode: 0);
    final products = rawData
        .cast<Map<String, dynamic>>()
        .map((e) => Product.fromJson(e))
        .toList();

    return ProductListResponse(
      data: products,
      total: data['total'] as int,
      page: data['page'] as int,
      pageSize: data['pageSize'] as int,
    );
  }

  @override
  Future<Product> getProductById(String id) async {
    final response = await _dio.get('/products/$id');
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

    return Product.fromJson(apiResponse.data!);
  }

  @override
  Future<List<Brand>> getBrands() async {
    final response = await _dio.get('/brands');
    final json = response.data as Map<String, dynamic>;
    final success = json['success'] as bool? ?? false;
    if (!success || json['data'] == null) {
      throw ApiException(code: 'UNKNOWN', statusCode: response.statusCode ?? 200);
    }
    final rawData = json['data'];
    if (rawData is! List) throw ApiException(code: 'INVALID_RESPONSE', statusCode: 0);
    return rawData
        .cast<Map<String, dynamic>>()
        .map((e) => Brand.fromJson(e))
        .toList();
  }

  @override
  Future<List<Category>> getCategories() async {
    final response = await _dio.get('/categories');
    final json = response.data as Map<String, dynamic>;
    final success = json['success'] as bool? ?? false;
    if (!success || json['data'] == null) {
      throw ApiException(code: 'UNKNOWN', statusCode: response.statusCode ?? 200);
    }
    final rawData = json['data'];
    if (rawData is! List) throw ApiException(code: 'INVALID_RESPONSE', statusCode: 0);
    return rawData
        .cast<Map<String, dynamic>>()
        .map((e) => Category.fromJson(e))
        .toList();
  }
}

class ProductFilter {
  final String? search;
  final String? brand;
  final String? category;
  final int page;
  final int pageSize;

  const ProductFilter({
    this.search,
    this.brand,
    this.category,
    this.page = 1,
    this.pageSize = 20,
  });

  ProductFilter copyWith({
    String? search,
    String? brand,
    String? category,
    int? page,
    int? pageSize,
    bool clearSearch = false,
    bool clearBrand = false,
    bool clearCategory = false,
  }) {
    return ProductFilter(
      search: clearSearch ? null : (search ?? this.search),
      brand: clearBrand ? null : (brand ?? this.brand),
      category: clearCategory ? null : (category ?? this.category),
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}

class ProductListResponse {
  final List<Product> data;
  final int total;
  final int page;
  final int pageSize;

  const ProductListResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.pageSize,
  });
}
