// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Otomasiku';

  @override
  String get home => 'Home';

  @override
  String get homeTitle => 'Product Catalog';

  @override
  String get search => 'Search';

  @override
  String get searchHint => 'Search FR-A820, FX5U, MR-J4...';

  @override
  String get project => 'Project';

  @override
  String get cart => 'Cart';

  @override
  String get profile => 'Profile';

  @override
  String get login => 'Login';

  @override
  String get logout => 'Logout';

  @override
  String get register => 'Register';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get continueAction => 'Continue';

  @override
  String get buyNow => 'Buy Now';

  @override
  String get continueToCheckout => 'Continue to Checkout';

  @override
  String get createInvoiceAndPay => 'Create Invoice & Pay';

  @override
  String get or => 'or';

  @override
  String get productCatalog => 'Product Catalog';

  @override
  String get productDetail => 'Product Detail';

  @override
  String get addToCart => 'Add to Cart';

  @override
  String get checkout => 'Checkout';

  @override
  String get orderSummary => 'Order Summary';

  @override
  String get total => 'Total';

  @override
  String get quantity => 'Quantity';

  @override
  String get price => 'Price';

  @override
  String get description => 'Description';

  @override
  String get specifications => 'Specifications';

  @override
  String get stock => 'Stock';

  @override
  String get stockReady => 'Ready Stock';

  @override
  String stockLow(int count) {
    return '$count Units Left';
  }

  @override
  String get stockEmpty => 'Out of Stock';

  @override
  String stockUnit(int count) {
    return '$count Units';
  }

  @override
  String get stockIndent => 'Indent';

  @override
  String get available => 'Available';

  @override
  String get outOfStock => 'Out of Stock';

  @override
  String get success => 'Success';

  @override
  String get error => 'Error';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorNetwork => 'No internet connection.';

  @override
  String get errorBcaCreateVa => 'Failed to create Virtual Account. Try again.';

  @override
  String get errorBcaVaExpired => 'Virtual Account has expired.';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get payment => 'Payment';

  @override
  String get paymentTitle => 'Payment';

  @override
  String get paymentWaiting => 'Awaiting Payment';

  @override
  String get paymentSuccess => 'Payment Successful!';

  @override
  String get paymentExpiry => 'Payment Deadline';

  @override
  String get paymentVaNumber => 'Virtual Account Number';

  @override
  String get paymentCopy => 'Copy';

  @override
  String get paymentCopied => 'Copied to clipboard';

  @override
  String get paymentCheckStatus => 'Check Status';

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get shippingAddress => 'Shipping Address';

  @override
  String get selectAddress => 'Select Address';

  @override
  String get noAddress => 'No address yet';

  @override
  String get addressName => 'Address Name';

  @override
  String get addressFull => 'Full Address';

  @override
  String get city => 'City';

  @override
  String get province => 'Province';

  @override
  String get postalCode => 'Postal Code';

  @override
  String get phone => 'Phone';

  @override
  String get companyName => 'Company Name';

  @override
  String get npwp => 'NPWP';

  @override
  String get orders => 'Orders';

  @override
  String get orderHistory => 'Order History';

  @override
  String get orderNumber => 'Order Number';

  @override
  String get orderDate => 'Order Date';

  @override
  String get orderStatus => 'Order Status';

  @override
  String get orderTotal => 'Order Total';

  @override
  String get viewDetails => 'View Details';

  @override
  String get noProducts => 'No products';

  @override
  String get noOrders => 'No orders yet';

  @override
  String get noCartItems => 'Cart is empty';

  @override
  String get emptyCart => 'Empty Cart';

  @override
  String get clearCart => 'Clear Cart';

  @override
  String get cartStartShopping => 'Start Shopping';

  @override
  String itemCount(int count) {
    return '$count item';
  }

  @override
  String get subtotal => 'Subtotal';

  @override
  String get shippingCost => 'Shipping Cost';

  @override
  String get discount => 'Discount';

  @override
  String get tax => 'Tax';

  @override
  String get grandTotal => 'Grand Total';

  @override
  String get processing => 'Processing';

  @override
  String get loading => 'Loading';

  @override
  String get retry => 'Retry';

  @override
  String get back => 'Back';

  @override
  String get close => 'Close';

  @override
  String get save => 'Save';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get add => 'Add';

  @override
  String get remove => 'Remove';

  @override
  String get update => 'Update';

  @override
  String get searchProducts => 'Search Products...';

  @override
  String get filter => 'Filter';

  @override
  String get sortBy => 'Sort By';

  @override
  String get categories => 'Categories';

  @override
  String get allCategories => 'All Categories';

  @override
  String get inverter => 'Inverter';

  @override
  String get plc => 'PLC';

  @override
  String get hmi => 'HMI';

  @override
  String get servo => 'Servo';

  @override
  String get brand => 'Brand';

  @override
  String get allBrands => 'All Brands';

  @override
  String get mitsubishi => 'Mitsubishi';

  @override
  String get danfoss => 'Danfoss';

  @override
  String get virtualAccount => 'Virtual Account';

  @override
  String get bca => 'BCA';

  @override
  String get transferBank => 'Bank Transfer';

  @override
  String get invoice => 'Invoice';

  @override
  String get downloadInvoice => 'Download Invoice';

  @override
  String get language => 'Language';

  @override
  String get addToCartShort => 'Add';

  @override
  String get added => '✓ Added';

  @override
  String get compareMaxError => 'Maximum 3 products for comparison';

  @override
  String get compare => 'Compare';

  @override
  String get clear => 'Clear All';
}
