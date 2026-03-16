/// Product category enum
enum ProductCategory {
  inverter,
  plc,
  hmi,
  servo,
}

/// Product brand enum
enum ProductBrand {
  mitsubishi,
  danfoss,
}

/// Stock status enum
enum StockStatus {
  inStock,
  lowStock,
  outOfStock,
  leadTime,
}

/// Product model for Otomasiku Marketplace
class Product {
  final String id;
  final String sku;
  final String name;
  final ProductBrand brand;
  final ProductCategory category;
  final String series;
  final String? subSeries;
  final String? variant;
  final int price;
  final int? originalPrice;
  final int? stock;
  final StockStatus stockStatus;
  final String? stockLeadTime;
  final String primaryImage;
  final List<String>? galleryImages;
  final String? description;
  final Map<String, String>? specifications;

  const Product({
    required this.id,
    required this.sku,
    required this.name,
    required this.brand,
    required this.category,
    required this.series,
    this.subSeries,
    this.variant,
    required this.price,
    this.originalPrice,
    this.stock,
    required this.stockStatus,
    this.stockLeadTime,
    required this.primaryImage,
    this.galleryImages,
    this.description,
    this.specifications,
  });

  /// Calculate discount percentage (integer division for money safety)
  int? get discountPercent {
    if (originalPrice == null || originalPrice! == 0) return null;
    return ((originalPrice! - price) * 100) ~/ originalPrice!;
  }

  /// Check if product has discount
  bool get hasDiscount => originalPrice != null && originalPrice! > price;
}
