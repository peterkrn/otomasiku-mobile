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
  /// **'Memproses'**
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
