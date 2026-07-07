import 'package:json_annotation/json_annotation.dart';

import '../core/utils/bigint_converter.dart';

part 'product.g.dart';

@JsonSerializable()
class Product {
  final int id;
  final String name;
  final String slug;
  final String? sku;
  final int brandId;
  final int categoryId;
  final String? series;
  final String? subSeries;
  final String? variant;

  @BigIntStringConverter()
  final int price;

  @NullableBigIntStringConverter()
  final int? originalPrice;

  final int stock;
  final int version;
  final String unit;
  final int minOrder;
  final String? descriptionId;
  final String? descriptionEn;
  final bool isPublished;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Optional nested objects (returned by some endpoints)
  @JsonKey(name: 'brand')
  final Brand? brandObj;
  @JsonKey(name: 'category')
  final Category? categoryObj;
  @JsonKey(defaultValue: [])
  final List<ProductImage> images;

  const Product({
    required this.id,
    required this.name,
    required this.slug,
    this.sku,
    required this.brandId,
    required this.categoryId,
    this.series,
    this.subSeries,
    this.variant,
    required this.price,
    this.originalPrice,
    required this.stock,
    required this.version,
    required this.unit,
    required this.minOrder,
    this.descriptionId,
    this.descriptionEn,
    required this.isPublished,
    required this.createdAt,
    required this.updatedAt,
    this.brandObj,
    this.categoryObj,
    this.images = const [],
  });

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);

  Map<String, dynamic> toJson() => _$ProductToJson(this);

  /// UI-compatible getters
  String get idString => id.toString();

  String get primaryImageUrl =>
      images.isNotEmpty
          ? images.firstWhere((i) => i.isPrimary, orElse: () => images.first).url
          : '';

  Brand get brand => brandObj ?? Brand(id: brandId, name: '', slug: '');
  Category get category => categoryObj ?? Category(id: categoryId, name: '', slug: '');

  bool get isOutOfStock => stock == 0;
  bool get isLowStock => stock > 0 && stock <= 5;
  bool get hasDiscount => originalPrice != null && originalPrice! > price;

  int? get discountPercent {
    if (originalPrice == null || originalPrice! == 0) return null;
    return ((originalPrice! - price) * 100) ~/ originalPrice!;
  }
}

@JsonSerializable()
class Brand {
  final int id;
  final String name;
  @JsonKey(defaultValue: '')
  final String slug;
  final String? description;
  final String? logoUrl;

  const Brand({
    required this.id,
    required this.name,
    this.slug = '',
    this.description,
    this.logoUrl,
  });

  factory Brand.fromJson(Map<String, dynamic> json) => _$BrandFromJson(json);

  Map<String, dynamic> toJson() => _$BrandToJson(this);
}

@JsonSerializable()
class Category {
  final int id;
  final String name;
  @JsonKey(defaultValue: '')
  final String slug;
  final String? description;
  final String? iconUrl;

  const Category({
    required this.id,
    required this.name,
    this.slug = '',
    this.description,
    this.iconUrl,
  });

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}

@JsonSerializable()
class ProductImage {
  @_ProductImageIdConverter()
  final String id;
  final String url;
  final String? path;
  @JsonKey(name: 'is_primary')
  final bool isPrimary;
  @JsonKey(name: 'sort_order')
  final int sortOrder;

  const ProductImage({
    required this.id,
    required this.url,
    this.path,
    required this.isPrimary,
    required this.sortOrder,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) =>
      _$ProductImageFromJson(json);

  Map<String, dynamic> toJson() => _$ProductImageToJson(this);
}

class _ProductImageIdConverter implements JsonConverter<String, dynamic> {
  const _ProductImageIdConverter();

  @override
  String fromJson(dynamic value) => value.toString();

  @override
  dynamic toJson(String value) => value;
}
