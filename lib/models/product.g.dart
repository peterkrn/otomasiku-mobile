// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
  id: json['id'] as String,
  name: json['name'] as String,
  slug: json['slug'] as String,
  sku: json['sku'] as String?,
  brand: Brand.fromJson(json['brand'] as Map<String, dynamic>),
  category: Category.fromJson(json['category'] as Map<String, dynamic>),
  series: json['series'] as String?,
  subSeries: json['subSeries'] as String?,
  variant: json['variant'] as String?,
  price: const BigIntStringConverter().fromJson(json['price']),
  originalPrice: const NullableBigIntStringConverter().fromJson(
    json['originalPrice'],
  ),
  stock: (json['stock'] as num).toInt(),
  version: (json['version'] as num).toInt(),
  unit: json['unit'] as String,
  minOrder: (json['minOrder'] as num).toInt(),
  descriptionId: json['descriptionId'] as String?,
  descriptionEn: json['descriptionEn'] as String?,
  images: (json['images'] as List<dynamic>)
      .map((e) => ProductImage.fromJson(e as Map<String, dynamic>))
      .toList(),
  isPublished: json['isPublished'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'slug': instance.slug,
  'sku': instance.sku,
  'brand': instance.brand,
  'category': instance.category,
  'series': instance.series,
  'subSeries': instance.subSeries,
  'variant': instance.variant,
  'price': const BigIntStringConverter().toJson(instance.price),
  'originalPrice': const NullableBigIntStringConverter().toJson(
    instance.originalPrice,
  ),
  'stock': instance.stock,
  'version': instance.version,
  'unit': instance.unit,
  'minOrder': instance.minOrder,
  'descriptionId': instance.descriptionId,
  'descriptionEn': instance.descriptionEn,
  'images': instance.images,
  'isPublished': instance.isPublished,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

Brand _$BrandFromJson(Map<String, dynamic> json) => Brand(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  slug: json['slug'] as String,
);

Map<String, dynamic> _$BrandToJson(Brand instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'slug': instance.slug,
};

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  slug: json['slug'] as String,
);

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'slug': instance.slug,
};

ProductImage _$ProductImageFromJson(Map<String, dynamic> json) => ProductImage(
  url: json['url'] as String,
  isPrimary: json['isPrimary'] as bool,
);

Map<String, dynamic> _$ProductImageToJson(ProductImage instance) =>
    <String, dynamic>{'url': instance.url, 'isPrimary': instance.isPrimary};
