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
  String get landingEyebrow =>
      'Industrial automation catalog for B2B and B2C needs';

  @override
  String get landingHeroBadge =>
      'A trusted supplier for industrial automation needs';

  @override
  String get landingHeadline =>
      'Industrial automation products that are easier to find, compare, and order.';

  @override
  String get landingSubheadline =>
      'Otomasiku helps industrial customers find what they need with B2B pricing support, competitive pricing for general purchases, and admin assistance during ordering.';

  @override
  String get landingViewCatalog => 'View Catalog';

  @override
  String get landingContactAdmin => 'Contact Admin';

  @override
  String get landingLanguageLabelId => 'ID';

  @override
  String get landingLanguageLabelEn => 'EN';

  @override
  String get landingTrustSectionTitle => 'Why customers trust us';

  @override
  String get landingTrustSectionSubtitle =>
      'We are shaping a shopping experience that feels clear, simple, and relevant for industrial purchasing.';

  @override
  String get landingTrustOriginalTitle => 'Original products';

  @override
  String get landingTrustOriginalBody =>
      'We focus on industrial products with clear brand and category identity.';

  @override
  String get landingTrustB2bPriceTitle => 'B2B pricing support';

  @override
  String get landingTrustB2bPriceBody =>
      'Business customers can coordinate with admin for project purchases or larger-volume needs.';

  @override
  String get landingTrustCompetitiveTitle => 'Competitive pricing';

  @override
  String get landingTrustCompetitiveBody =>
      'For general purchases, we aim to keep pricing relevant and competitive for the industrial automation market.';

  @override
  String get landingTrustVerificationTitle => 'Manual payment verification';

  @override
  String get landingTrustVerificationBody =>
      'Payments and shipping are currently reconfirmed by admin so order details stay accurate.';

  @override
  String get landingCatalogSectionTitle => 'Main categories';

  @override
  String get landingCatalogSectionSubtitle =>
      'Start with the components most often needed for industrial panels, machinery, and control systems.';

  @override
  String get landingHowTitle => 'How ordering works';

  @override
  String get landingHowSubtitle =>
      'The flow is kept simple so customers can keep moving without second-guessing the next step.';

  @override
  String get landingHowStep1Title => 'Browse the catalog';

  @override
  String get landingHowStep1Body =>
      'Search by category or product, then open the product detail page to review the key information.';

  @override
  String get landingHowStep2Title => 'Sign in and prepare the order';

  @override
  String get landingHowStep2Body =>
      'Add products to cart, choose a shipping address, and continue to checkout.';

  @override
  String get landingHowStep3Title => 'Pay and wait for admin verification';

  @override
  String get landingHowStep3Body =>
      'Upload your QRIS transfer proof, then admin will verify the payment and arrange shipping manually.';

  @override
  String get landingBrandTitle => 'Available brands';

  @override
  String get landingBrandSubtitle =>
      'The catalog currently highlights industrial brands already familiar to many customers.';

  @override
  String get landingFooterTitle => 'Need help choosing a product?';

  @override
  String get landingFooterSubtitle =>
      'Our admin team can help with product selection, order confirmation, and the payment process.';

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
  String get paymentQrisTitle => 'QRIS Payment';

  @override
  String get paymentScanQris =>
      'Scan the QRIS code using your mobile banking app or e-wallet';

  @override
  String get paymentQrisMerchant => 'PT Abadi Bangun Bersama (Otomasiku.com)';

  @override
  String get paymentQrisOnlyDescription =>
      'QRIS for PT Abadi Bangun Bersama is pre-selected for this order.';

  @override
  String get paymentQrisInstruction =>
      'Scan the QRIS code below using your mobile banking app or e-wallet, then upload your transfer proof after the payment succeeds.';

  @override
  String get paymentConfirmPaid => 'I Have Paid';

  @override
  String get paymentPendingTitle => 'Awaiting Verification';

  @override
  String get paymentPendingSubtitle => 'Admin will verify your payment';

  @override
  String get paymentPendingDescription =>
      'Your payment will be verified manually by our admin. Please wait for confirmation via notification.';

  @override
  String get paymentViewOrder => 'View Order';

  @override
  String get paymentBackToShopping => 'Continue Shopping';

  @override
  String get paymentCheckStatus => 'Check Status';

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get shippingAddress => 'Shipping Address';

  @override
  String get selectAddress => 'Select Address';

  @override
  String get changeAddress => 'Change Address';

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
  String get loadingProducts => 'Loading products...';

  @override
  String get retry => 'Retry';

  @override
  String get pullToRefresh => 'Pull to refresh';

  @override
  String productsCount(int count) {
    return '$count products';
  }

  @override
  String get errorLoadingProducts => 'Failed to load products';

  @override
  String get errorLoadingProductDetail => 'Failed to load product details';

  @override
  String get errorOffline =>
      'No internet connection. Please check your network.';

  @override
  String get errorTimeout => 'Request timed out. Please try again.';

  @override
  String get errorSessionExpired =>
      'Your session has expired. Please log in again.';

  @override
  String get errorServer => 'Server error. Please try again later.';

  @override
  String get errorLoadAddress => 'Failed to load addresses.';

  @override
  String get errorImageLoad => 'Failed to load image.';

  @override
  String get notLoggedIn => 'You are not logged in. Please log in to continue.';

  @override
  String get addressSaveFailed => 'Failed to save address. Please try again.';

  @override
  String get goToLogin => 'Go to Login';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get errorWeakPassword => 'Password must be at least 6 characters.';

  @override
  String get errorUnauthorized => 'You do not have access.';

  @override
  String get errorProductNotFound => 'Product not found.';

  @override
  String get errorOrderPaid => 'Order has already been paid.';

  @override
  String get errorPaymentFailed => 'Payment failed.';

  @override
  String get errorInvalidAmount => 'Invalid payment amount.';

  @override
  String get errorCartEmpty => 'Your cart is empty.';

  @override
  String get errorInvalidQuantity => 'Invalid quantity.';

  @override
  String get errorServiceUnavailable => 'Service is currently unavailable.';

  @override
  String get pleaseSelectShippingAddress => 'Please select a shipping address.';

  @override
  String get paymentTimeExpired => 'Payment time has expired.';

  @override
  String get loadMore => 'Load more';

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
  String get compareMaxError => 'Unable to add product to comparison';

  @override
  String get compare => 'Compare';

  @override
  String get clear => 'Clear All';

  @override
  String get compareEmptyHint => 'Add products to start comparing';

  @override
  String get compareAddProduct => 'Add Product';

  @override
  String get compareSpecProduct => 'PRODUCT';

  @override
  String get compareSpecSeries => 'SERIES';

  @override
  String get compareSpecVariant => 'VARIANT';

  @override
  String get compareSpecUnit => 'UNIT';

  @override
  String get compareSpecMinOrder => 'MIN ORDER';

  @override
  String get compareSpecStock => 'STOCK';

  @override
  String get compareSpecPrice => 'PRICE';

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
  String get shippingManualDescription =>
      'Shipping is arranged manually by our admin after your payment has been verified.';

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
  String get loggingOut => 'Logging out...';

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
  String get activeFiltersLabel => 'Active filters:';

  @override
  String get noActiveFilters => 'No active filters';

  @override
  String searchResultsCount(int count) {
    return 'Found $count products';
  }

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
  String get powerRangeSmall => '≤ 2.2 kW';

  @override
  String get powerRangeMedium => '3.7–15 kW';

  @override
  String get powerRangeLarge => '≥ 18.5 kW';

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

  @override
  String get errorInvalidCredentials => 'Invalid email or password.';

  @override
  String get errorDuplicateEntry => 'Email already registered. Please login.';

  @override
  String get errorRateLimit => 'Too many attempts. Try again later.';

  @override
  String get errorUserNotFound => 'Account not found.';

  @override
  String get errorValidation => 'Invalid data. Please check again.';

  @override
  String get loginTitle => 'Welcome!';

  @override
  String get loginSubtitle => 'Login to continue';

  @override
  String get registerTitle => 'Create Account';

  @override
  String get registerSubtitle => 'Complete the form below';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get haveAccount => 'Already have an account?';

  @override
  String get agreeTerms => 'I agree to the Terms & Conditions';

  @override
  String get nameHint => 'Full Name';

  @override
  String get passwordHint => 'Password';

  @override
  String get confirmPasswordHint => 'Confirm Password';

  @override
  String get emailHint => 'Username / Email';

  @override
  String get loginButton => 'Login';

  @override
  String get registerButton => 'Register';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String fieldRequired(String field) {
    return '$field is required';
  }

  @override
  String get agreeTermsRequired => 'You must agree to the Terms & Conditions';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get fullName => 'Full Name';

  @override
  String get saveProfile => 'Save Profile';

  @override
  String get profileUpdated => 'Profile updated successfully';

  @override
  String get addressLabel => 'Address Label';

  @override
  String get recipient => 'Recipient';

  @override
  String get addAddress => 'Add Address';

  @override
  String get editAddress => 'Edit Address';

  @override
  String get deleteAddress => 'Delete Address';

  @override
  String get deleteAddressConfirm => 'Delete this address?';

  @override
  String get addressDeleted => 'Address deleted successfully';

  @override
  String get noAddressSaved => 'No saved addresses';

  @override
  String get setAsDefault => 'Set as default';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get noAddresses => 'No addresses';

  @override
  String get notificationPermissionTitle => 'Enable Notifications';

  @override
  String get notificationPermissionBody =>
      'Get real-time updates on your order status';

  @override
  String get notificationActivate => 'Activate';

  @override
  String get notificationLater => 'Later';

  @override
  String get noProjects => 'No projects yet';

  @override
  String get createProjectHint => 'Create a project to manage B2B purchases';

  @override
  String get chat => 'Chat';

  @override
  String get openingWhatsApp => 'Opening WhatsApp...';

  @override
  String get clearCompareConfirm => 'Remove all products from comparison?';

  @override
  String get compareCleared => 'Comparison cleared';

  @override
  String get checkPaymentStatus => 'Check Payment Status';

  @override
  String get settings => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get security => 'Security';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get name => 'Name';

  @override
  String get changePassword => 'Change Password';

  @override
  String get changePasswordSubtitle => 'Change your account password';

  @override
  String get resetPasswordViaEmail => 'Reset Password via Email';

  @override
  String resetPasswordSubtitle(String email) {
    return 'Send reset link to $email';
  }

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get passwordMinChars => 'Password must be at least 8 characters';

  @override
  String get passwordMismatch => 'Passwords do not match';

  @override
  String get passwordChanged => 'Password changed successfully';

  @override
  String resetLinkSent(String email) {
    return 'Reset password link sent to $email';
  }

  @override
  String get profileSaved => 'Profile saved successfully';

  @override
  String get uploadPhotoSoon => 'Photo upload feature coming soon';

  @override
  String get forgotPasswordSubtitle =>
      'Enter your email and we\'ll send you a link to reset your password';

  @override
  String get sendResetLink => 'Send Reset Link';

  @override
  String get paymentUploadProof => 'Upload Transfer Proof';

  @override
  String get paymentProofPending => 'Awaiting Admin Verification';

  @override
  String get paymentProofApproved => 'Payment Confirmed';

  @override
  String paymentProofRejectedReason(String reason) {
    return 'Rejected: $reason';
  }

  @override
  String get paymentReupload => 'Re-upload';

  @override
  String get paymentBankName => 'Bank Name';

  @override
  String get paymentBankNameCustom => 'Bank Name';

  @override
  String get paymentAccountName => 'Sender Account Name';

  @override
  String get paymentAmount => 'Transfer Amount';

  @override
  String get paymentPickImage => 'Gallery';

  @override
  String get paymentTakePhoto => 'Camera';

  @override
  String get paymentSubmitProof => 'Submit Transfer Proof';

  @override
  String get paymentProofUploaded => 'Transfer proof submitted successfully';

  @override
  String get paymentExpiredStockReleased =>
      'Stock has been released for this expired order.';

  @override
  String get paymentExpiredCheckoutAgain =>
      'Please checkout again if you still need these items.';

  @override
  String get paymentFieldsRequired => 'All fields are required';

  @override
  String get paymentLeaveTitle => 'Leave payment?';

  @override
  String get paymentLeaveMessage =>
      'Are you sure you want to leave this payment screen?';

  @override
  String get exitAppTitle => 'Exit the app?';

  @override
  String get exitAppMessage => 'Are you sure you want to exit?';

  @override
  String get leave => 'Leave';

  @override
  String get productUnavailable => 'This product is currently unavailable';

  @override
  String trackingNumber(String resi) {
    return 'Tracking No: $resi';
  }

  @override
  String get paymentConfirmDialogTitle => 'Confirm Payment';

  @override
  String get paymentConfirmDialogBody =>
      'By confirming, our team will verify your payment. The verification process takes up to 1x24 hours.';

  @override
  String get confirmReceived => 'Order Received';

  @override
  String get confirmReceivedDialog =>
      'Confirm that the order has been received?';

  @override
  String get confirmReceivedSuccess => 'Order confirmed successfully';

  @override
  String get productPriceNotSetTitle => 'Price Not Available';

  @override
  String get productPriceNotSetBody =>
      'This product does not have a price yet. Please contact admin for availability and pricing.';

  @override
  String get productPriceNotSetContactAdmin => 'Contact Admin via WhatsApp';

  @override
  String get contactAdmin => 'Contact Admin';

  @override
  String get loginSubtitle2 =>
      'Sign in to your account to access the product catalog and special offers.';

  @override
  String get registerNow => 'Register Now';

  @override
  String get loginWithGoogle => 'Sign in with Google';

  @override
  String get errorInvalidEmail => 'Invalid email format';

  @override
  String get registerSuccessTitle => 'Registration Successful!';

  @override
  String registerSuccessBody(String email) {
    return 'A confirmation link has been sent to $email. Please check your email and click the confirmation link to activate your account.';
  }

  @override
  String get addressSaved => 'Address saved successfully';

  @override
  String get addressAdded => 'Address added successfully';

  @override
  String get paymentVaTransferFrom => 'Transfer from any BCA account';

  @override
  String get paymentAccountHolder => 'Account Holder';

  @override
  String get paymentType => 'Type';

  @override
  String get paymentAutoVerify =>
      'Payment will be verified automatically. Make sure the transferred amount matches the total bill so the order can be processed.';

  @override
  String get supportNeedHelp => 'Need help?';

  @override
  String get supportContactPhone => 'Contact us at 021-1234-5678';

  @override
  String get notificationOrderUpdates => 'Order Updates';

  @override
  String get notificationOrderUpdatesDesc =>
      'Notifications for order status changes';

  @override
  String get notificationPaymentDesc => 'Payment confirmation';

  @override
  String get languageLabelId => 'ID';

  @override
  String get languageLabelEn => 'EN';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get privacyPolicySubtitle => 'Read our privacy policy';
}
