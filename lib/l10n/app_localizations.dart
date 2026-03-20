import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// Application name
  ///
  /// In id, this message translates to:
  /// **'Otomasiku'**
  String get appName;

  /// No description provided for @home.
  ///
  /// In id, this message translates to:
  /// **'Beranda'**
  String get home;

  /// No description provided for @homeTitle.
  ///
  /// In id, this message translates to:
  /// **'Katalog Produk'**
  String get homeTitle;

  /// No description provided for @search.
  ///
  /// In id, this message translates to:
  /// **'Cari'**
  String get search;

  /// No description provided for @searchHint.
  ///
  /// In id, this message translates to:
  /// **'Cari FR-A820, FX5U, MR-J4...'**
  String get searchHint;

  /// No description provided for @project.
  ///
  /// In id, this message translates to:
  /// **'Proyek'**
  String get project;

  /// No description provided for @cart.
  ///
  /// In id, this message translates to:
  /// **'Keranjang'**
  String get cart;

  /// No description provided for @profile.
  ///
  /// In id, this message translates to:
  /// **'Profil'**
  String get profile;

  /// No description provided for @login.
  ///
  /// In id, this message translates to:
  /// **'Masuk'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In id, this message translates to:
  /// **'Keluar'**
  String get logout;

  /// No description provided for @register.
  ///
  /// In id, this message translates to:
  /// **'Daftar'**
  String get register;

  /// No description provided for @email.
  ///
  /// In id, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In id, this message translates to:
  /// **'Kata Sandi'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In id, this message translates to:
  /// **'Lupa Kata Sandi?'**
  String get forgotPassword;

  /// No description provided for @welcomeBack.
  ///
  /// In id, this message translates to:
  /// **'Selamat Datang Kembali'**
  String get welcomeBack;

  /// No description provided for @continueAction.
  ///
  /// In id, this message translates to:
  /// **'Lanjutkan'**
  String get continueAction;

  /// No description provided for @buyNow.
  ///
  /// In id, this message translates to:
  /// **'Beli Sekarang'**
  String get buyNow;

  /// No description provided for @continueToCheckout.
  ///
  /// In id, this message translates to:
  /// **'Lanjut ke Checkout'**
  String get continueToCheckout;

  /// No description provided for @createInvoiceAndPay.
  ///
  /// In id, this message translates to:
  /// **'Buat Invoice & Bayar'**
  String get createInvoiceAndPay;

  /// No description provided for @or.
  ///
  /// In id, this message translates to:
  /// **'atau'**
  String get or;

  /// No description provided for @productCatalog.
  ///
  /// In id, this message translates to:
  /// **'Katalog Produk'**
  String get productCatalog;

  /// No description provided for @productDetail.
  ///
  /// In id, this message translates to:
  /// **'Detail Produk'**
  String get productDetail;

  /// No description provided for @addToCart.
  ///
  /// In id, this message translates to:
  /// **'Tambah ke Keranjang'**
  String get addToCart;

  /// No description provided for @checkout.
  ///
  /// In id, this message translates to:
  /// **'Pembayaran'**
  String get checkout;

  /// No description provided for @orderSummary.
  ///
  /// In id, this message translates to:
  /// **'Ringkasan Pesanan'**
  String get orderSummary;

  /// No description provided for @total.
  ///
  /// In id, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @quantity.
  ///
  /// In id, this message translates to:
  /// **'Jumlah'**
  String get quantity;

  /// No description provided for @price.
  ///
  /// In id, this message translates to:
  /// **'Harga'**
  String get price;

  /// No description provided for @description.
  ///
  /// In id, this message translates to:
  /// **'Deskripsi'**
  String get description;

  /// No description provided for @specifications.
  ///
  /// In id, this message translates to:
  /// **'Spesifikasi'**
  String get specifications;

  /// No description provided for @stock.
  ///
  /// In id, this message translates to:
  /// **'Stok'**
  String get stock;

  /// No description provided for @stockReady.
  ///
  /// In id, this message translates to:
  /// **'Ready Stock'**
  String get stockReady;

  /// No description provided for @stockLow.
  ///
  /// In id, this message translates to:
  /// **'Sisa {count} Unit'**
  String stockLow(int count);

  /// No description provided for @stockEmpty.
  ///
  /// In id, this message translates to:
  /// **'Habis'**
  String get stockEmpty;

  /// No description provided for @stockUnit.
  ///
  /// In id, this message translates to:
  /// **'{count} Unit'**
  String stockUnit(int count);

  /// No description provided for @stockIndent.
  ///
  /// In id, this message translates to:
  /// **'Indent'**
  String get stockIndent;

  /// No description provided for @available.
  ///
  /// In id, this message translates to:
  /// **'Tersedia'**
  String get available;

  /// No description provided for @outOfStock.
  ///
  /// In id, this message translates to:
  /// **'Stok Habis'**
  String get outOfStock;

  /// No description provided for @success.
  ///
  /// In id, this message translates to:
  /// **'Berhasil'**
  String get success;

  /// No description provided for @error.
  ///
  /// In id, this message translates to:
  /// **'Kesalahan'**
  String get error;

  /// No description provided for @errorGeneric.
  ///
  /// In id, this message translates to:
  /// **'Terjadi kesalahan. Silakan coba lagi.'**
  String get errorGeneric;

  /// No description provided for @errorNetwork.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada koneksi internet.'**
  String get errorNetwork;

  /// No description provided for @errorBcaCreateVa.
  ///
  /// In id, this message translates to:
  /// **'Gagal membuat Virtual Account. Coba lagi.'**
  String get errorBcaCreateVa;

  /// No description provided for @errorBcaVaExpired.
  ///
  /// In id, this message translates to:
  /// **'Virtual Account sudah kedaluwarsa.'**
  String get errorBcaVaExpired;

  /// No description provided for @cancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi'**
  String get confirm;

  /// No description provided for @payment.
  ///
  /// In id, this message translates to:
  /// **'Pembayaran'**
  String get payment;

  /// No description provided for @paymentTitle.
  ///
  /// In id, this message translates to:
  /// **'Pembayaran'**
  String get paymentTitle;

  /// No description provided for @paymentWaiting.
  ///
  /// In id, this message translates to:
  /// **'Menunggu Pembayaran'**
  String get paymentWaiting;

  /// No description provided for @paymentSuccess.
  ///
  /// In id, this message translates to:
  /// **'Pembayaran Berhasil!'**
  String get paymentSuccess;

  /// No description provided for @paymentExpiry.
  ///
  /// In id, this message translates to:
  /// **'Batas Waktu Pembayaran'**
  String get paymentExpiry;

  /// No description provided for @paymentVaNumber.
  ///
  /// In id, this message translates to:
  /// **'Nomor Virtual Account'**
  String get paymentVaNumber;

  /// No description provided for @paymentCopy.
  ///
  /// In id, this message translates to:
  /// **'Salin'**
  String get paymentCopy;

  /// No description provided for @paymentCopied.
  ///
  /// In id, this message translates to:
  /// **'Berhasil disalin'**
  String get paymentCopied;

  /// No description provided for @paymentCheckStatus.
  ///
  /// In id, this message translates to:
  /// **'Cek Status'**
  String get paymentCheckStatus;

  /// No description provided for @paymentMethod.
  ///
  /// In id, this message translates to:
  /// **'Metode Pembayaran'**
  String get paymentMethod;

  /// No description provided for @shippingAddress.
  ///
  /// In id, this message translates to:
  /// **'Alamat Pengiriman'**
  String get shippingAddress;

  /// No description provided for @selectAddress.
  ///
  /// In id, this message translates to:
  /// **'Pilih Alamat'**
  String get selectAddress;

  /// No description provided for @noAddress.
  ///
  /// In id, this message translates to:
  /// **'Belum ada alamat'**
  String get noAddress;

  /// No description provided for @addressName.
  ///
  /// In id, this message translates to:
  /// **'Nama Alamat'**
  String get addressName;

  /// No description provided for @addressFull.
  ///
  /// In id, this message translates to:
  /// **'Alamat Lengkap'**
  String get addressFull;

  /// No description provided for @city.
  ///
  /// In id, this message translates to:
  /// **'Kota'**
  String get city;

  /// No description provided for @province.
  ///
  /// In id, this message translates to:
  /// **'Provinsi'**
  String get province;

  /// No description provided for @postalCode.
  ///
  /// In id, this message translates to:
  /// **'Kode Pos'**
  String get postalCode;

  /// No description provided for @phone.
  ///
  /// In id, this message translates to:
  /// **'Telepon'**
  String get phone;

  /// No description provided for @companyName.
  ///
  /// In id, this message translates to:
  /// **'Nama Perusahaan'**
  String get companyName;

  /// No description provided for @npwp.
  ///
  /// In id, this message translates to:
  /// **'NPWP'**
  String get npwp;

  /// No description provided for @orders.
  ///
  /// In id, this message translates to:
  /// **'Pesanan'**
  String get orders;

  /// No description provided for @orderHistory.
  ///
  /// In id, this message translates to:
  /// **'Riwayat Pesanan'**
  String get orderHistory;

  /// No description provided for @orderNumber.
  ///
  /// In id, this message translates to:
  /// **'Nomor Pesanan'**
  String get orderNumber;

  /// No description provided for @orderDate.
  ///
  /// In id, this message translates to:
  /// **'Tanggal Pesanan'**
  String get orderDate;

  /// No description provided for @orderStatus.
  ///
  /// In id, this message translates to:
  /// **'Status Pesanan'**
  String get orderStatus;

  /// No description provided for @orderTotal.
  ///
  /// In id, this message translates to:
  /// **'Total Pesanan'**
  String get orderTotal;

  /// No description provided for @viewDetails.
  ///
  /// In id, this message translates to:
  /// **'Lihat Detail'**
  String get viewDetails;

  /// No description provided for @noProducts.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada produk'**
  String get noProducts;

  /// No description provided for @noOrders.
  ///
  /// In id, this message translates to:
  /// **'Belum ada pesanan'**
  String get noOrders;

  /// No description provided for @noCartItems.
  ///
  /// In id, this message translates to:
  /// **'Keranjang kosong'**
  String get noCartItems;

  /// No description provided for @emptyCart.
  ///
  /// In id, this message translates to:
  /// **'Keranjang Kosong'**
  String get emptyCart;

  /// No description provided for @clearCart.
  ///
  /// In id, this message translates to:
  /// **'Kosongkan Keranjang'**
  String get clearCart;

  /// No description provided for @cartStartShopping.
  ///
  /// In id, this message translates to:
  /// **'Mulai Belanja'**
  String get cartStartShopping;

  /// No description provided for @itemCount.
  ///
  /// In id, this message translates to:
  /// **'{count} item'**
  String itemCount(int count);

  /// No description provided for @subtotal.
  ///
  /// In id, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @shippingCost.
  ///
  /// In id, this message translates to:
  /// **'Ongkos Kirim'**
  String get shippingCost;

  /// No description provided for @discount.
  ///
  /// In id, this message translates to:
  /// **'Diskon'**
  String get discount;

  /// No description provided for @tax.
  ///
  /// In id, this message translates to:
  /// **'Pajak'**
  String get tax;

  /// No description provided for @grandTotal.
  ///
  /// In id, this message translates to:
  /// **'Total Keseluruhan'**
  String get grandTotal;

  /// No description provided for @processing.
  ///
  /// In id, this message translates to:
  /// **'Diproses'**
  String get processing;

  /// No description provided for @loading.
  ///
  /// In id, this message translates to:
  /// **'Memuat'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In id, this message translates to:
  /// **'Coba Lagi'**
  String get retry;

  /// No description provided for @back.
  ///
  /// In id, this message translates to:
  /// **'Kembali'**
  String get back;

  /// No description provided for @close.
  ///
  /// In id, this message translates to:
  /// **'Tutup'**
  String get close;

  /// No description provided for @save.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get save;

  /// No description provided for @edit.
  ///
  /// In id, this message translates to:
  /// **'Ubah'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get delete;

  /// No description provided for @add.
  ///
  /// In id, this message translates to:
  /// **'Tambah'**
  String get add;

  /// No description provided for @remove.
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get remove;

  /// No description provided for @update.
  ///
  /// In id, this message translates to:
  /// **'Perbarui'**
  String get update;

  /// No description provided for @searchProducts.
  ///
  /// In id, this message translates to:
  /// **'Cari Produk...'**
  String get searchProducts;

  /// No description provided for @filter.
  ///
  /// In id, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @sortBy.
  ///
  /// In id, this message translates to:
  /// **'Urutkan'**
  String get sortBy;

  /// No description provided for @categories.
  ///
  /// In id, this message translates to:
  /// **'Kategori'**
  String get categories;

  /// No description provided for @allCategories.
  ///
  /// In id, this message translates to:
  /// **'Semua Kategori'**
  String get allCategories;

  /// No description provided for @inverter.
  ///
  /// In id, this message translates to:
  /// **'Inverter'**
  String get inverter;

  /// No description provided for @plc.
  ///
  /// In id, this message translates to:
  /// **'PLC'**
  String get plc;

  /// No description provided for @hmi.
  ///
  /// In id, this message translates to:
  /// **'HMI'**
  String get hmi;

  /// No description provided for @servo.
  ///
  /// In id, this message translates to:
  /// **'Servo'**
  String get servo;

  /// No description provided for @brand.
  ///
  /// In id, this message translates to:
  /// **'Merek'**
  String get brand;

  /// No description provided for @allBrands.
  ///
  /// In id, this message translates to:
  /// **'Semua Merek'**
  String get allBrands;

  /// No description provided for @mitsubishi.
  ///
  /// In id, this message translates to:
  /// **'Mitsubishi'**
  String get mitsubishi;

  /// No description provided for @danfoss.
  ///
  /// In id, this message translates to:
  /// **'Danfoss'**
  String get danfoss;

  /// No description provided for @virtualAccount.
  ///
  /// In id, this message translates to:
  /// **'Virtual Account'**
  String get virtualAccount;

  /// No description provided for @bca.
  ///
  /// In id, this message translates to:
  /// **'BCA'**
  String get bca;

  /// No description provided for @transferBank.
  ///
  /// In id, this message translates to:
  /// **'Transfer Bank'**
  String get transferBank;

  /// No description provided for @invoice.
  ///
  /// In id, this message translates to:
  /// **'Faktur'**
  String get invoice;

  /// No description provided for @downloadInvoice.
  ///
  /// In id, this message translates to:
  /// **'Unduh Faktur'**
  String get downloadInvoice;

  /// No description provided for @language.
  ///
  /// In id, this message translates to:
  /// **'Bahasa'**
  String get language;

  /// No description provided for @addToCartShort.
  ///
  /// In id, this message translates to:
  /// **'Tambah'**
  String get addToCartShort;

  /// No description provided for @added.
  ///
  /// In id, this message translates to:
  /// **'✓ Ditambahkan'**
  String get added;

  /// No description provided for @compareMaxError.
  ///
  /// In id, this message translates to:
  /// **'Maksimal 3 produk untuk dibandingkan'**
  String get compareMaxError;

  /// No description provided for @compare.
  ///
  /// In id, this message translates to:
  /// **'Bandingkan'**
  String get compare;

  /// No description provided for @clear.
  ///
  /// In id, this message translates to:
  /// **'Hapus Semua'**
  String get clear;

  /// No description provided for @cartRemoveConfirm.
  ///
  /// In id, this message translates to:
  /// **'Hapus item ini dari keranjang?'**
  String get cartRemoveConfirm;

  /// No description provided for @cartRemoveTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus Item'**
  String get cartRemoveTitle;

  /// No description provided for @volumeDiscount.
  ///
  /// In id, this message translates to:
  /// **'Hemat {amount}'**
  String volumeDiscount(String amount);

  /// No description provided for @pricePerUnit.
  ///
  /// In id, this message translates to:
  /// **'Harga per unit'**
  String get pricePerUnit;

  /// No description provided for @tieredPricing.
  ///
  /// In id, this message translates to:
  /// **'Harga Bertingkat (B2B)'**
  String get tieredPricing;

  /// No description provided for @priceNormal.
  ///
  /// In id, this message translates to:
  /// **'Harga normal'**
  String get priceNormal;

  /// No description provided for @bestDeal.
  ///
  /// In id, this message translates to:
  /// **'Best Deal'**
  String get bestDeal;

  /// No description provided for @contactSales.
  ///
  /// In id, this message translates to:
  /// **'Hubungi sales'**
  String get contactSales;

  /// No description provided for @documents.
  ///
  /// In id, this message translates to:
  /// **'Dokumen'**
  String get documents;

  /// No description provided for @compatible.
  ///
  /// In id, this message translates to:
  /// **'Kompatibel'**
  String get compatible;

  /// No description provided for @compatibleWith.
  ///
  /// In id, this message translates to:
  /// **'Produk yang kompatibel dengan {name}:'**
  String compatibleWith(String name);

  /// No description provided for @download.
  ///
  /// In id, this message translates to:
  /// **'Unduh'**
  String get download;

  /// No description provided for @buy.
  ///
  /// In id, this message translates to:
  /// **'Beli'**
  String get buy;

  /// No description provided for @saveToProject.
  ///
  /// In id, this message translates to:
  /// **'Simpan ke Proyek'**
  String get saveToProject;

  /// No description provided for @unitsAvailable.
  ///
  /// In id, this message translates to:
  /// **'{count} Unit Tersedia'**
  String unitsAvailable(int count);

  /// No description provided for @readyToShip.
  ///
  /// In id, this message translates to:
  /// **'Siap kirim {time}'**
  String readyToShip(String time);

  /// No description provided for @rfq.
  ///
  /// In id, this message translates to:
  /// **'RFQ'**
  String get rfq;

  /// No description provided for @rfqTitle.
  ///
  /// In id, this message translates to:
  /// **'Request for Quote'**
  String get rfqTitle;

  /// No description provided for @rfqQuantity.
  ///
  /// In id, this message translates to:
  /// **'Jumlah yang Diinginkan'**
  String get rfqQuantity;

  /// No description provided for @rfqMinQuantity.
  ///
  /// In id, this message translates to:
  /// **'Minimal {count} unit'**
  String rfqMinQuantity(int count);

  /// No description provided for @rfqCompanyName.
  ///
  /// In id, this message translates to:
  /// **'Nama Perusahaan'**
  String get rfqCompanyName;

  /// No description provided for @rfqSubmit.
  ///
  /// In id, this message translates to:
  /// **'Kirim RFQ'**
  String get rfqSubmit;

  /// No description provided for @rfqSent.
  ///
  /// In id, this message translates to:
  /// **'RFQ berhasil dikirim!'**
  String get rfqSent;

  /// No description provided for @addToCompare.
  ///
  /// In id, this message translates to:
  /// **'Tambahkan ke perbandingan'**
  String get addToCompare;

  /// No description provided for @addedToCompare.
  ///
  /// In id, this message translates to:
  /// **'Ditambahkan ke perbandingan'**
  String get addedToCompare;

  /// No description provided for @saveProduct.
  ///
  /// In id, this message translates to:
  /// **'Simpan Produk'**
  String get saveProduct;

  /// No description provided for @savedToProject.
  ///
  /// In id, this message translates to:
  /// **'Disimpan ke: {project}'**
  String savedToProject(Object project);

  /// No description provided for @newArrival.
  ///
  /// In id, this message translates to:
  /// **'New Arrival'**
  String get newArrival;

  /// No description provided for @addedToCart.
  ///
  /// In id, this message translates to:
  /// **'{name} ditambahkan ke keranjang'**
  String addedToCart(String name);

  /// No description provided for @insufficientStock.
  ///
  /// In id, this message translates to:
  /// **'Maaf, stok tidak mencukupi. Sisa stok: {count}'**
  String insufficientStock(int count);

  /// No description provided for @shipping.
  ///
  /// In id, this message translates to:
  /// **'Pengiriman'**
  String get shipping;

  /// No description provided for @paymentSummary.
  ///
  /// In id, this message translates to:
  /// **'Ringkasan Pembayaran'**
  String get paymentSummary;

  /// No description provided for @volumeDiscountLabel.
  ///
  /// In id, this message translates to:
  /// **'Diskon Volume'**
  String get volumeDiscountLabel;

  /// No description provided for @taxLabel.
  ///
  /// In id, this message translates to:
  /// **'PPN (11%)'**
  String get taxLabel;

  /// No description provided for @totalPayment.
  ///
  /// In id, this message translates to:
  /// **'Total Pembayaran'**
  String get totalPayment;

  /// No description provided for @termsAgree.
  ///
  /// In id, this message translates to:
  /// **'Saya menyetujui Syarat dan Ketentuan'**
  String get termsAgree;

  /// No description provided for @companyPO.
  ///
  /// In id, this message translates to:
  /// **'Nomor PO Perusahaan (Opsional)'**
  String get companyPO;

  /// No description provided for @poPlaceholder.
  ///
  /// In id, this message translates to:
  /// **'PO/2024/001'**
  String get poPlaceholder;

  /// No description provided for @standardShipping.
  ///
  /// In id, this message translates to:
  /// **'Pengiriman Standar'**
  String get standardShipping;

  /// No description provided for @shippingEstimate.
  ///
  /// In id, this message translates to:
  /// **'Estimasi 3-5 hari kerja'**
  String get shippingEstimate;

  /// No description provided for @freeShipping.
  ///
  /// In id, this message translates to:
  /// **'GRATIS'**
  String get freeShipping;

  /// No description provided for @bcaVirtualAccount.
  ///
  /// In id, this message translates to:
  /// **'BCA Virtual Account'**
  String get bcaVirtualAccount;

  /// No description provided for @bankTransfer.
  ///
  /// In id, this message translates to:
  /// **'Transfer Bank (Dicek Otomatis)'**
  String get bankTransfer;

  /// No description provided for @paymentHowTo.
  ///
  /// In id, this message translates to:
  /// **'Cara Pembayaran:'**
  String get paymentHowTo;

  /// No description provided for @paymentStep1.
  ///
  /// In id, this message translates to:
  /// **'Klik \"Buat Invoice\" untuk mendapat nomor VA'**
  String get paymentStep1;

  /// No description provided for @paymentStep2.
  ///
  /// In id, this message translates to:
  /// **'Transfer melalui BCA Mobile/ATM'**
  String get paymentStep2;

  /// No description provided for @paymentStep3.
  ///
  /// In id, this message translates to:
  /// **'Otomatis terverifikasi dalam 5 menit'**
  String get paymentStep3;

  /// No description provided for @pleaseAcceptTerms.
  ///
  /// In id, this message translates to:
  /// **'Silakan centang persetujuan'**
  String get pleaseAcceptTerms;

  /// No description provided for @paymentCountdown.
  ///
  /// In id, this message translates to:
  /// **'Batas waktu pembayaran'**
  String get paymentCountdown;

  /// No description provided for @vaNumberLabel.
  ///
  /// In id, this message translates to:
  /// **'Nomor Virtual Account BCA'**
  String get vaNumberLabel;

  /// No description provided for @vaCopied.
  ///
  /// In id, this message translates to:
  /// **'Nomor VA berhasil disalin'**
  String get vaCopied;

  /// No description provided for @payBefore.
  ///
  /// In id, this message translates to:
  /// **'Bayar sebelum'**
  String get payBefore;

  /// No description provided for @transferAmount.
  ///
  /// In id, this message translates to:
  /// **'Jumlah yang harus ditransfer'**
  String get transferAmount;

  /// No description provided for @paymentViaMBanking.
  ///
  /// In id, this message translates to:
  /// **'Via m-Banking'**
  String get paymentViaMBanking;

  /// No description provided for @paymentViaAtm.
  ///
  /// In id, this message translates to:
  /// **'Via ATM'**
  String get paymentViaAtm;

  /// No description provided for @paymentViaInternetBanking.
  ///
  /// In id, this message translates to:
  /// **'Via Internet Banking'**
  String get paymentViaInternetBanking;

  /// No description provided for @mbankingStep1.
  ///
  /// In id, this message translates to:
  /// **'Buka aplikasi m-Banking BCA'**
  String get mbankingStep1;

  /// No description provided for @mbankingStep2.
  ///
  /// In id, this message translates to:
  /// **'Pilih menu Transfer > Virtual Account'**
  String get mbankingStep2;

  /// No description provided for @mbankingStep3.
  ///
  /// In id, this message translates to:
  /// **'Masukkan nomor VA dan konfirmasi'**
  String get mbankingStep3;

  /// No description provided for @mbankingStep4.
  ///
  /// In id, this message translates to:
  /// **'Masukkan PIN dan konfirmasi pembayaran'**
  String get mbankingStep4;

  /// No description provided for @atmStep1.
  ///
  /// In id, this message translates to:
  /// **'Masukkan kartu ATM dan PIN'**
  String get atmStep1;

  /// No description provided for @atmStep2.
  ///
  /// In id, this message translates to:
  /// **'Pilih Transaksi Lainnya > Transfer > BCA Virtual Account'**
  String get atmStep2;

  /// No description provided for @atmStep3.
  ///
  /// In id, this message translates to:
  /// **'Masukkan nomor VA dan tekan Benar'**
  String get atmStep3;

  /// No description provided for @atmStep4.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi dan pilih Ya untuk menyelesaikan'**
  String get atmStep4;

  /// No description provided for @ibankingStep1.
  ///
  /// In id, this message translates to:
  /// **'Login ke KlikBCA (internetbanking.klikbca.com)'**
  String get ibankingStep1;

  /// No description provided for @ibankingStep2.
  ///
  /// In id, this message translates to:
  /// **'Pilih Transfer Dana > Transfer ke BCA Virtual Account'**
  String get ibankingStep2;

  /// No description provided for @ibankingStep3.
  ///
  /// In id, this message translates to:
  /// **'Masukkan nomor VA dan klik Lanjutkan'**
  String get ibankingStep3;

  /// No description provided for @ibankingStep4.
  ///
  /// In id, this message translates to:
  /// **'Masukkan respon KeyBCA APPLI dan konfirmasi'**
  String get ibankingStep4;

  /// No description provided for @paymentSuccessTitle.
  ///
  /// In id, this message translates to:
  /// **'Pembayaran Berhasil!'**
  String get paymentSuccessTitle;

  /// No description provided for @paymentSuccessSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Pesanan Anda sedang diproses'**
  String get paymentSuccessSubtitle;

  /// No description provided for @viewOrder.
  ///
  /// In id, this message translates to:
  /// **'Lihat Pesanan'**
  String get viewOrder;

  /// No description provided for @backToHome.
  ///
  /// In id, this message translates to:
  /// **'Kembali ke Beranda'**
  String get backToHome;

  /// No description provided for @orderNotFound.
  ///
  /// In id, this message translates to:
  /// **'Pesanan tidak ditemukan'**
  String get orderNotFound;

  /// No description provided for @orderDetail.
  ///
  /// In id, this message translates to:
  /// **'Detail Pesanan'**
  String get orderDetail;

  /// No description provided for @estimatedDelivery.
  ///
  /// In id, this message translates to:
  /// **'Estimasi pengiriman: {date}'**
  String estimatedDelivery(String date);

  /// No description provided for @statusHistory.
  ///
  /// In id, this message translates to:
  /// **'Riwayat Status'**
  String get statusHistory;

  /// No description provided for @paymentReceived.
  ///
  /// In id, this message translates to:
  /// **'Pembayaran Diterima'**
  String get paymentReceived;

  /// No description provided for @processingSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Verifikasi stok dan packaging'**
  String get processingSubtitle;

  /// No description provided for @shipped.
  ///
  /// In id, this message translates to:
  /// **'Dikirim'**
  String get shipped;

  /// No description provided for @shippedSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Dalam perjalanan ke alamat tujuan'**
  String get shippedSubtitle;

  /// No description provided for @delivered.
  ///
  /// In id, this message translates to:
  /// **'Selesai'**
  String get delivered;

  /// No description provided for @orderedItems.
  ///
  /// In id, this message translates to:
  /// **'Item Dipesan'**
  String get orderedItems;

  /// No description provided for @shippingInfo.
  ///
  /// In id, this message translates to:
  /// **'Info Pengiriman'**
  String get shippingInfo;

  /// No description provided for @trackingNote.
  ///
  /// In id, this message translates to:
  /// **'Nomor resi akan muncul setelah barang dikirim'**
  String get trackingNote;

  /// No description provided for @comingSoon.
  ///
  /// In id, this message translates to:
  /// **'Segera tersedia'**
  String get comingSoon;

  /// No description provided for @shareOrder.
  ///
  /// In id, this message translates to:
  /// **'Bagikan Pesanan'**
  String get shareOrder;

  /// No description provided for @contactSupport.
  ///
  /// In id, this message translates to:
  /// **'Hubungi Support'**
  String get contactSupport;

  /// No description provided for @grandTotalLabel.
  ///
  /// In id, this message translates to:
  /// **'Total Pembayaran'**
  String get grandTotalLabel;

  /// No description provided for @profileTitle.
  ///
  /// In id, this message translates to:
  /// **'Profil'**
  String get profileTitle;

  /// No description provided for @myOrders.
  ///
  /// In id, this message translates to:
  /// **'Pesanan Saya'**
  String get myOrders;

  /// No description provided for @addressBook.
  ///
  /// In id, this message translates to:
  /// **'Alamat Pengiriman'**
  String get addressBook;

  /// No description provided for @paymentMethods.
  ///
  /// In id, this message translates to:
  /// **'Pembayaran'**
  String get paymentMethods;

  /// No description provided for @helpCenter.
  ///
  /// In id, this message translates to:
  /// **'Bantuan'**
  String get helpCenter;

  /// No description provided for @logoutConfirm.
  ///
  /// In id, this message translates to:
  /// **'Yakin ingin keluar?'**
  String get logoutConfirm;

  /// No description provided for @logoutSuccess.
  ///
  /// In id, this message translates to:
  /// **'Berhasil logout'**
  String get logoutSuccess;

  /// No description provided for @myProjects.
  ///
  /// In id, this message translates to:
  /// **'Proyek Saya'**
  String get myProjects;

  /// No description provided for @activeProjects.
  ///
  /// In id, this message translates to:
  /// **'Proyek Aktif'**
  String get activeProjects;

  /// No description provided for @totalItems.
  ///
  /// In id, this message translates to:
  /// **'Total Item'**
  String get totalItems;

  /// No description provided for @totalEstimate.
  ///
  /// In id, this message translates to:
  /// **'Total Estimasi'**
  String get totalEstimate;

  /// No description provided for @checkoutProject.
  ///
  /// In id, this message translates to:
  /// **'Checkout Proyek'**
  String get checkoutProject;

  /// No description provided for @requestRFQ.
  ///
  /// In id, this message translates to:
  /// **'Ajukan RFQ'**
  String get requestRFQ;

  /// No description provided for @createProject.
  ///
  /// In id, this message translates to:
  /// **'Buat Proyek'**
  String get createProject;

  /// No description provided for @projectName.
  ///
  /// In id, this message translates to:
  /// **'Nama Proyek'**
  String get projectName;

  /// No description provided for @compareProducts.
  ///
  /// In id, this message translates to:
  /// **'Bandingkan Produk'**
  String get compareProducts;

  /// No description provided for @addProduct.
  ///
  /// In id, this message translates to:
  /// **'Tambah Produk'**
  String get addProduct;

  /// No description provided for @power.
  ///
  /// In id, this message translates to:
  /// **'Daya'**
  String get power;

  /// No description provided for @voltage.
  ///
  /// In id, this message translates to:
  /// **'Tegangan'**
  String get voltage;

  /// No description provided for @warranty.
  ///
  /// In id, this message translates to:
  /// **'Garansi'**
  String get warranty;

  /// No description provided for @sortRelevance.
  ///
  /// In id, this message translates to:
  /// **'Relevansi'**
  String get sortRelevance;

  /// No description provided for @sortPriceLow.
  ///
  /// In id, this message translates to:
  /// **'Harga Terendah'**
  String get sortPriceLow;

  /// No description provided for @sortPriceHigh.
  ///
  /// In id, this message translates to:
  /// **'Harga Tertinggi'**
  String get sortPriceHigh;

  /// No description provided for @sortNameAsc.
  ///
  /// In id, this message translates to:
  /// **'Nama A-Z'**
  String get sortNameAsc;

  /// No description provided for @sortNameDesc.
  ///
  /// In id, this message translates to:
  /// **'Nama Z-A'**
  String get sortNameDesc;

  /// No description provided for @productsSelected.
  ///
  /// In id, this message translates to:
  /// **'Produk dipilih'**
  String get productsSelected;

  /// No description provided for @applyFilter.
  ///
  /// In id, this message translates to:
  /// **'Terapkan Filter'**
  String get applyFilter;

  /// No description provided for @addFilter.
  ///
  /// In id, this message translates to:
  /// **'Tambah Filter'**
  String get addFilter;

  /// No description provided for @filterCategory.
  ///
  /// In id, this message translates to:
  /// **'Kategori Produk'**
  String get filterCategory;

  /// No description provided for @filterAvailability.
  ///
  /// In id, this message translates to:
  /// **'Ketersediaan Stok'**
  String get filterAvailability;

  /// No description provided for @filterPower.
  ///
  /// In id, this message translates to:
  /// **'Rentang Daya'**
  String get filterPower;

  /// No description provided for @noProductsFound.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada produk ditemukan'**
  String get noProductsFound;

  /// No description provided for @tryDifferentFilters.
  ///
  /// In id, this message translates to:
  /// **'Coba ubah kata kunci atau filter'**
  String get tryDifferentFilters;

  /// No description provided for @unitsInStock.
  ///
  /// In id, this message translates to:
  /// **'{count} Unit Tersedia'**
  String unitsInStock(int count);

  /// No description provided for @unitsRemaining.
  ///
  /// In id, this message translates to:
  /// **'Sisa {count} Unit'**
  String unitsRemaining(int count);

  /// No description provided for @indentLeadTime.
  ///
  /// In id, this message translates to:
  /// **'Indent {time}'**
  String indentLeadTime(String time);

  /// No description provided for @addNewAddress.
  ///
  /// In id, this message translates to:
  /// **'Tambah Alamat Baru'**
  String get addNewAddress;

  /// No description provided for @firstName.
  ///
  /// In id, this message translates to:
  /// **'Nama Depan'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In id, this message translates to:
  /// **'Nama Belakang'**
  String get lastName;

  /// No description provided for @kecamatan.
  ///
  /// In id, this message translates to:
  /// **'Kecamatan'**
  String get kecamatan;

  /// No description provided for @kelurahan.
  ///
  /// In id, this message translates to:
  /// **'Kelurahan'**
  String get kelurahan;

  /// No description provided for @deliveryNotes.
  ///
  /// In id, this message translates to:
  /// **'Catatan Pengiriman'**
  String get deliveryNotes;

  /// No description provided for @fillRequiredFields.
  ///
  /// In id, this message translates to:
  /// **'Lengkapi semua field yang wajib diisi'**
  String get fillRequiredFields;

  /// No description provided for @primary.
  ///
  /// In id, this message translates to:
  /// **'Utama'**
  String get primary;

  /// No description provided for @useAddress.
  ///
  /// In id, this message translates to:
  /// **'Gunakan Alamat Ini'**
  String get useAddress;

  /// No description provided for @saveAddress.
  ///
  /// In id, this message translates to:
  /// **'Simpan Alamat'**
  String get saveAddress;

  /// No description provided for @optional.
  ///
  /// In id, this message translates to:
  /// **'opsional'**
  String get optional;

  /// No description provided for @minQuantityTier.
  ///
  /// In id, this message translates to:
  /// **'Minimal pembelian {count} unit untuk tier harga ini'**
  String minQuantityTier(int count);

  /// No description provided for @viewProduct.
  ///
  /// In id, this message translates to:
  /// **'Lihat Produk'**
  String get viewProduct;

  /// No description provided for @addToCartQuestion.
  ///
  /// In id, this message translates to:
  /// **'Tambahkan ke Keranjang?'**
  String get addToCartQuestion;

  /// No description provided for @selectAll.
  ///
  /// In id, this message translates to:
  /// **'Pilih Semua'**
  String get selectAll;

  /// No description provided for @selectItem.
  ///
  /// In id, this message translates to:
  /// **'Pilih item'**
  String get selectItem;

  /// No description provided for @noItemSelected.
  ///
  /// In id, this message translates to:
  /// **'Pilih minimal 1 item untuk checkout'**
  String get noItemSelected;

  /// No description provided for @productSelected.
  ///
  /// In id, this message translates to:
  /// **'{count} produk dipilih'**
  String productSelected(int count);

  /// No description provided for @removeSelection.
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get removeSelection;

  /// No description provided for @compareProduct.
  ///
  /// In id, this message translates to:
  /// **'Bandingkan'**
  String get compareProduct;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
