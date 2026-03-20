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

  @override
  String get cartRemoveConfirm => 'Remove this item from cart?';

  @override
  String get cartRemoveTitle => 'Remove Item';

  @override
  String volumeDiscount(String amount) {
    return 'Save $amount';
  }

  @override
  String get pricePerUnit => 'Price per unit';

  @override
  String get tieredPricing => 'Tiered Pricing (B2B)';

  @override
  String get priceNormal => 'Normal price';

  @override
  String get bestDeal => 'Best Deal';

  @override
  String get contactSales => 'Contact sales';

  @override
  String get documents => 'Documents';

  @override
  String get compatible => 'Compatible';

  @override
  String compatibleWith(String name) {
    return 'Products compatible with $name:';
  }

  @override
  String get download => 'Download';

  @override
  String get buy => 'Buy';

  @override
  String get saveToProject => 'Save to Project';

  @override
  String unitsAvailable(int count) {
    return '$count Units Available';
  }

  @override
  String readyToShip(String time) {
    return 'Ready to ship $time';
  }

  @override
  String get rfq => 'RFQ';

  @override
  String get rfqTitle => 'Request for Quote';

  @override
  String get rfqQuantity => 'Desired Quantity';

  @override
  String rfqMinQuantity(int count) {
    return 'Minimum $count units';
  }

  @override
  String get rfqCompanyName => 'Company Name';

  @override
  String get rfqSubmit => 'Submit RFQ';

  @override
  String get rfqSent => 'RFQ sent successfully!';

  @override
  String get addToCompare => 'Add to comparison';

  @override
  String get addedToCompare => 'Added to comparison';

  @override
  String get saveProduct => 'Save Product';

  @override
  String savedToProject(Object project) {
    return 'Saved to: $project';
  }

  @override
  String get newArrival => 'New Arrival';

  @override
  String addedToCart(String name) {
    return '$name added to cart';
  }

  @override
  String insufficientStock(int count) {
    return 'Sorry, insufficient stock. Remaining: $count';
  }

  @override
  String get shipping => 'Shipping';

  @override
  String get paymentSummary => 'Payment Summary';

  @override
  String get volumeDiscountLabel => 'Volume Discount';

  @override
  String get taxLabel => 'VAT (11%)';

  @override
  String get totalPayment => 'Total Payment';

  @override
  String get termsAgree => 'I agree to the Terms and Conditions';

  @override
  String get companyPO => 'Company PO Number (Optional)';

  @override
  String get poPlaceholder => 'PO/2024/001';

  @override
  String get standardShipping => 'Standard Shipping';

  @override
  String get shippingEstimate => 'Est. 3-5 business days';

  @override
  String get freeShipping => 'FREE';

  @override
  String get bcaVirtualAccount => 'BCA Virtual Account';

  @override
  String get bankTransfer => 'Bank Transfer (Auto-verified)';

  @override
  String get paymentHowTo => 'How to Pay:';

  @override
  String get paymentStep1 => 'Click \"Create Invoice\" to get VA number';

  @override
  String get paymentStep2 => 'Transfer via BCA Mobile/ATM';

  @override
  String get paymentStep3 => 'Auto-verified within 5 minutes';

  @override
  String get pleaseAcceptTerms => 'Please check the agreement box';

  @override
  String get paymentCountdown => 'Payment deadline';

  @override
  String get vaNumberLabel => 'BCA Virtual Account Number';

  @override
  String get vaCopied => 'VA number copied successfully';

  @override
  String get payBefore => 'Pay before';

  @override
  String get transferAmount => 'Amount to transfer';

  @override
  String get paymentViaMBanking => 'Via m-Banking';

  @override
  String get paymentViaAtm => 'Via ATM';

  @override
  String get paymentViaInternetBanking => 'Via Internet Banking';

  @override
  String get mbankingStep1 => 'Open BCA m-Banking app';

  @override
  String get mbankingStep2 => 'Select Transfer > Virtual Account';

  @override
  String get mbankingStep3 => 'Enter VA number and confirm';

  @override
  String get mbankingStep4 => 'Enter PIN and confirm payment';

  @override
  String get atmStep1 => 'Insert ATM card and PIN';

  @override
  String get atmStep2 =>
      'Select Other Transactions > Transfer > BCA Virtual Account';

  @override
  String get atmStep3 => 'Enter VA number and press Correct';

  @override
  String get atmStep4 => 'Confirm and select Yes to complete';

  @override
  String get ibankingStep1 => 'Login to KlikBCA (internetbanking.klikbca.com)';

  @override
  String get ibankingStep2 =>
      'Select Fund Transfer > Transfer to BCA Virtual Account';

  @override
  String get ibankingStep3 => 'Enter VA number and click Continue';

  @override
  String get ibankingStep4 => 'Enter KeyBCA APPLI response and confirm';

  @override
  String get paymentSuccessTitle => 'Payment Successful!';

  @override
  String get paymentSuccessSubtitle => 'Your order is being processed';

  @override
  String get viewOrder => 'View Order';

  @override
  String get backToHome => 'Back to Home';

  @override
  String get orderNotFound => 'Order not found';

  @override
  String get orderDetail => 'Order Details';

  @override
  String estimatedDelivery(String date) {
    return 'Estimated delivery: $date';
  }

  @override
  String get statusHistory => 'Status History';

  @override
  String get paymentReceived => 'Payment Received';

  @override
  String get processingSubtitle => 'Stock verification and packaging';

  @override
  String get shipped => 'Shipped';

  @override
  String get shippedSubtitle => 'On the way to destination';

  @override
  String get delivered => 'Delivered';

  @override
  String get orderedItems => 'Ordered Items';

  @override
  String get shippingInfo => 'Shipping Info';

  @override
  String get trackingNote => 'Tracking number will appear after shipment';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get shareOrder => 'Share Order';

  @override
  String get contactSupport => 'Contact Support';

  @override
  String get grandTotalLabel => 'Total Payment';

  @override
  String get profileTitle => 'Profile';

  @override
  String get myOrders => 'My Orders';

  @override
  String get addressBook => 'Shipping Address';

  @override
  String get paymentMethods => 'Payment Methods';

  @override
  String get helpCenter => 'Help Center';

  @override
  String get logoutConfirm => 'Are you sure you want to logout?';

  @override
  String get logoutSuccess => 'Logged out successfully';

  @override
  String get myProjects => 'My Projects';

  @override
  String get activeProjects => 'Active Projects';

  @override
  String get totalItems => 'Total Items';

  @override
  String get totalEstimate => 'Total Estimate';

  @override
  String get checkoutProject => 'Checkout Project';

  @override
  String get requestRFQ => 'Request RFQ';

  @override
  String get createProject => 'Create Project';

  @override
  String get projectName => 'Project Name';

  @override
  String get compareProducts => 'Compare Products';

  @override
  String get addProduct => 'Add Product';

  @override
  String get power => 'Power';

  @override
  String get voltage => 'Voltage';

  @override
  String get warranty => 'Warranty';

  @override
  String get sortRelevance => 'Relevance';

  @override
  String get sortPriceLow => 'Lowest Price';

  @override
  String get sortPriceHigh => 'Highest Price';

  @override
  String get sortNameAsc => 'Name A-Z';

  @override
  String get sortNameDesc => 'Name Z-A';

  @override
  String get productsSelected => 'Products selected';

  @override
  String get applyFilter => 'Apply Filter';

  @override
  String get addFilter => 'Add Filter';

  @override
  String get filterCategory => 'Product Category';

  @override
  String get filterAvailability => 'Stock Availability';

  @override
  String get filterPower => 'Power Range';

  @override
  String get noProductsFound => 'No products found';

  @override
  String get tryDifferentFilters => 'Try different keywords or filters';

  @override
  String unitsInStock(int count) {
    return '$count Units Available';
  }

  @override
  String unitsRemaining(int count) {
    return '$count Units Left';
  }

  @override
  String indentLeadTime(String time) {
    return 'Indent $time';
  }

  @override
  String get addNewAddress => 'Add New Address';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get kecamatan => 'District';

  @override
  String get kelurahan => 'Village';

  @override
  String get deliveryNotes => 'Delivery Notes';

  @override
  String get fillRequiredFields => 'Please fill all required fields';

  @override
  String get primary => 'Primary';

  @override
  String get useAddress => 'Use This Address';

  @override
  String get saveAddress => 'Save Address';

  @override
  String get optional => 'optional';

  @override
  String minQuantityTier(int count) {
    return 'Minimum purchase of $count units for this price tier';
  }

  @override
  String get viewProduct => 'View Product';

  @override
  String get addToCartQuestion => 'Add to Cart?';

  @override
  String get selectAll => 'Select All';

  @override
  String get selectItem => 'Select item';

  @override
  String get noItemSelected => 'Select at least 1 item to checkout';

  @override
  String productSelected(int count) {
    return '$count product selected';
  }

  @override
  String get removeSelection => 'Remove';

  @override
  String get compareProduct => 'Compare';
}
