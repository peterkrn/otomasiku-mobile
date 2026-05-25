# Spec 02 — Models & Repositories

| Field | Value |
|-------|-------|
| **Phase** | 3 — Backend Integration |
| **Priority** | Critical |
| **Status** | ⬜ Draft |
| **Depends On** | 01-infrastructure |

---

## Scope

Update all existing models to match the real API response shapes and create the repository layer that wraps Dio calls into typed return values. Repositories are the only layer that knows about HTTP — providers call repositories, never Dio directly.

---

## New Files

```
lib/data/repositories/
├── auth_repository.dart
├── product_repository.dart
├── cart_repository.dart
├── order_repository.dart
├── address_repository.dart
└── profile_repository.dart
```

## Modified Files

```
lib/models/product.dart          # Add fromJson/toJson, match API shape
lib/models/order.dart            # Add fromJson/toJson, match API shape
lib/models/cart_item.dart        # Add fromJson/toJson, match API shape
lib/models/address.dart          # Add fromJson/toJson, match API shape
lib/models/user_profile.dart     # Add fromJson/toJson, match API shape
lib/models/bca_va_response.dart  # Add fromJson/toJson, match API shape
```

---

## Model Shapes (from API)

### Product
```dart
@JsonSerializable()
class Product {
  final String id;           // uuid
  final String name;
  final String slug;
  final String? sku;
  final Brand brand;         // { id, name, slug }
  final Category category;   // { id, name, slug }
  final String? series;
  final String? subSeries;
  final String? variant;
  final int price;           // parse from String (BigInt)
  final int? originalPrice;  // parse from String (BigInt)
  final int stock;
  final int version;         // optimistic lock version
  final String unit;
  final int minOrder;
  final String? descriptionId;
  final String? descriptionEn;
  final List<ProductImage> images;
  final bool isPublished;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Computed
  String get primaryImageUrl => images.firstWhere((i) => i.isPrimary, orElse: () => images.first).url;
  bool get isOutOfStock => stock == 0;
  bool get isLowStock => stock > 0 && stock <= 5;
}

@JsonSerializable()
class ProductImage {
  final String url;
  final bool isPrimary;
}

@JsonSerializable()
class Brand { final int id; final String name; final String slug; }

@JsonSerializable()
class Category { final int id; final String name; final String slug; }
```

> **Note:** `price` and `originalPrice` come as `String` from API (BigInt serialization). Use a custom `JsonConverter` to parse `String → int`.

### CartItem
```dart
@JsonSerializable()
class CartItem {
  final String id;           // uuid
  final String productId;
  final int quantity;
  final CartProductSnapshot productSnapshot;
  final DateTime createdAt;
}

@JsonSerializable()
class CartProductSnapshot {
  final String name;
  final int price;           // parse from String
  final String primaryImageUrl;
}
```

### Order
```dart
@JsonSerializable()
class Order {
  final String id;
  final String orderNumber;
  final String status;       // pending|confirmed|processing|shipped|done|cancelled
  final String paymentStatus;// unpaid|paid|expired
  final int totalAmount;     // parse from String
  final String? vaNumber;
  final DateTime? vaExpiresAt;
  final OrderAddress shippingAddress;
  final List<OrderItem> items;
  final String? notes;
  final String? resiNumber;
  final DateTime createdAt;
  final DateTime updatedAt;
}

@JsonSerializable()
class OrderItem {
  final String productId;
  final String productName;
  final int quantity;
  final int unitPrice;       // parse from String
  final int subtotal;        // parse from String
}

@JsonSerializable()
class OrderAddress {
  final String recipient;
  final String phone;
  final String street;
  final String city;
  final String province;
  final String postalCode;
}
```

### Address
```dart
@JsonSerializable()
class Address {
  final String id;
  final String label;
  final String recipient;
  final String phone;
  final String street;
  final String city;
  final String province;
  final String postalCode;
  final bool isDefault;
  final DateTime createdAt;
}
```

### UserProfile
```dart
@JsonSerializable()
class UserProfile {
  final String id;
  final String email;
  final String role;         // "customer" | "admin"
  final String? fullName;
  final String? phone;
  final String? companyName;
  final String? avatarUrl;
}
```

---

## Repository Contracts

### ProductRepository
```dart
abstract class ProductRepository {
  Future<ProductListResponse> getProducts(ProductFilter filter);
  Future<Product> getProductById(String id);
}

class ProductFilter {
  final String? search;
  final String? brand;      // brand slug
  final String? category;   // category slug
  final int page;
  final int pageSize;
  const ProductFilter({this.search, this.brand, this.category, this.page = 1, this.pageSize = 20});
}

class ProductListResponse {
  final List<Product> data;
  final int total;
  final int page;
  final int pageSize;
}
```

### CartRepository
```dart
abstract class CartRepository {
  Future<CartResponse> getCart();
  Future<CartItem> addItem({required String productId, required int quantity, required String idempotencyKey});
  Future<CartItem> updateItem({required String cartItemId, required int quantity});
  Future<void> removeItem(String cartItemId);
  Future<void> clearCart();
}

class CartResponse {
  final List<CartItem> items;
  final int totalItems;
}
```

### OrderRepository
```dart
abstract class OrderRepository {
  Future<OrderListResponse> getOrders({int page = 1, int pageSize = 20});
  Future<Order> getOrderById(String id);
  Future<CreateOrderResult> createOrder({required String addressId, String? notes, required String idempotencyKey});
  Future<List<OrderStatusHistory>> getStatusHistory(String orderId);
}

class CreateOrderResult {
  final String orderId;
  final String orderNumber;
  final int totalAmount;
}

class OrderStatusHistory {
  final String status;
  final DateTime changedAt;
  final String? changedBy;
  final String? notes;
}
```

### AddressRepository
```dart
abstract class AddressRepository {
  Future<List<Address>> getAddresses();
  Future<Address> getAddressById(String id);
  Future<Address> createAddress(AddressInput input);
  Future<Address> updateAddress(String id, AddressInput input);
  Future<void> deleteAddress(String id);
}

class AddressInput {
  final String label, recipient, phone, street, city, province, postalCode;
  final bool isDefault;
}
```

### ProfileRepository
```dart
abstract class ProfileRepository {
  Future<UserProfile> getProfile();
  Future<UserProfile> updateProfile(ProfileInput input);
  Future<String> uploadAvatar(File imageFile);  // returns new avatarUrl
  Future<void> registerDeviceToken(String fcmToken);
  Future<void> removeDeviceToken(String fcmToken);
}

class ProfileInput {
  final String? fullName, phone, companyName;
}
```

### AuthRepository
```dart
abstract class AuthRepository {
  Future<void> bootstrap();  // POST /api/me/bootstrap — ensures profile exists after signup
}
```

---

## BigInt String Converter

All monetary fields from the API come as `String`. Use this converter on every `price`, `originalPrice`, `totalAmount`, `unitPrice`, `subtotal` field:

```dart
class BigIntStringConverter implements JsonConverter<int, dynamic> {
  const BigIntStringConverter();

  @override
  int fromJson(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.parse(value);
    throw FormatException('Cannot parse $value as int');
  }

  @override
  String toJson(int value) => value.toString();
}
```

---

## Provider Wiring

Each repository is provided via Riverpod:

```dart
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(ref.read(apiClientProvider));
});
// Same pattern for cart, order, address, profile, auth repositories
```

---

## Acceptance Criteria

### AC-1: Models parse real API responses
```gherkin
Given a real API response JSON for a product
When Product.fromJson(json) is called
Then all fields are correctly typed
And price is int (not String)
And images list is populated
And no exception is thrown
```

### AC-2: Repository returns typed models
```gherkin
Given the API returns a valid product list response
When productRepository.getProducts(filter) is called
Then a ProductListResponse with typed Product list is returned
And no dynamic types are used
```

### AC-3: Repository throws AppException on error
```gherkin
Given the API returns { "success": false, "error": { "code": "PRODUCT_NOT_FOUND" } }
When productRepository.getProductById(id) is called
Then an ApiException with code "PRODUCT_NOT_FOUND" is thrown
And the exception propagates to the provider's error state
```

### AC-4: Dummy data files are no longer imported
```gherkin
Given all repositories are implemented
Then no file in lib/providers/ imports from lib/data/dummy/
And dummy files remain in place but are unused
```

---

## Verification Checklist

- [ ] `flutter pub run build_runner build` generates `.g.dart` files without errors
- [ ] All `fromJson` methods handle null fields gracefully
- [ ] `BigIntStringConverter` applied to all monetary fields
- [ ] No `dynamic` in any model or repository file
- [ ] Repository interfaces (abstract classes) defined separately from implementations
- [ ] All repositories provided via Riverpod `Provider`
- [ ] `flutter analyze` clean
