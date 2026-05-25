import 'package:dio/dio.dart';

import '../../core/errors/app_exception.dart';
import '../../core/network/api_response.dart';
import '../../models/product.dart';

abstract class ProductRepository {
  Future<ProductListResponse> getProducts(ProductFilter filter);
  Future<Product> getProductById(String id);
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
        'limit': filter.pageSize,
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
    final products = (data['data'] as List)
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
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

    return Product.fromJson(apiResponse.data!['data'] as Map<String, dynamic>);
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
