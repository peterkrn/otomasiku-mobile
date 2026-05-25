import 'package:json_annotation/json_annotation.dart';

import '../core/utils/bigint_converter.dart';

part 'product.g.dart';

@JsonSerializable()
class Product {
  final String id;
  final String name;
  final String slug;
  final String? sku;
  final Brand brand;
  final Category category;
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
  final List<ProductImage> images;
  final bool isPublished;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Product({
    required this.id,
    required this.name,
    required this.slug,
    this.sku,
    required this.brand,
    required this.category,
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
    required this.images,
    required this.isPublished,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);

  Map<String, dynamic> toJson() => _$ProductToJson(this);

  String get primaryImageUrl =>
      images.firstWhere((i) => i.isPrimary, orElse: () => images.first).url;

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
  final String slug;

  const Brand({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory Brand.fromJson(Map<String, dynamic> json) => _$BrandFromJson(json);

  Map<String, dynamic> toJson() => _$BrandToJson(this);
}

@JsonSerializable()
class Category {
  final int id;
  final String name;
  final String slug;

  const Category({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}

@JsonSerializable()
class ProductImage {
  final String url;
  final bool isPrimary;

  const ProductImage({
    required this.url,
    required this.isPrimary,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) =>
      _$ProductImageFromJson(json);

  Map<String, dynamic> toJson() => _$ProductImageToJson(this);
}

enum ProductCategory {
  inverter,
  plc,
  hmi,
  servo,
}

enum ProductBrand {
  mitsubishi,
  danfoss,
}

enum StockStatus {
  inStock,
  lowStock,
  outOfStock,
  leadTime,
}
