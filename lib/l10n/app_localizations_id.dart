// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appName => 'Otomasiku';

  @override
  String get landingEyebrow =>
      'Katalog otomasi industri untuk kebutuhan B2B dan B2C';

  @override
  String get landingHeroBadge =>
      'Pemasok tepercaya untuk kebutuhan otomasi industri';

  @override
  String get landingHeadline =>
      'Produk otomasi industri yang lebih mudah dicari, dibandingkan, dan dipesan.';

  @override
  String get landingSubheadline =>
      'Otomasiku membantu pelanggan industri menemukan produk yang dibutuhkan dengan harga khusus B2B, harga kompetitif untuk pembelian umum, dan dukungan admin saat proses pemesanan.';

  @override
  String get landingViewCatalog => 'Lihat Katalog';

  @override
  String get landingContactAdmin => 'Hubungi Admin';

  @override
  String get landingLanguageLabelId => 'ID';

  @override
  String get landingLanguageLabelEn => 'EN';

  @override
  String get landingTrustSectionTitle => 'Alasan pelanggan percaya';

  @override
  String get landingTrustSectionSubtitle =>
      'Kami menyusun pengalaman belanja yang jelas, sederhana, dan relevan untuk kebutuhan industri.';

  @override
  String get landingTrustOriginalTitle => 'Produk original';

  @override
  String get landingTrustOriginalBody =>
      'Fokus pada produk industri yang jelas identitas brand dan kategorinya.';

  @override
  String get landingTrustB2bPriceTitle => 'Harga khusus B2B';

  @override
  String get landingTrustB2bPriceBody =>
      'Pelanggan bisnis bisa berdiskusi dengan admin untuk kebutuhan pembelian proyek atau volume tertentu.';

  @override
  String get landingTrustCompetitiveTitle => 'Harga kompetitif';

  @override
  String get landingTrustCompetitiveBody =>
      'Untuk kebutuhan pembelian umum, kami menyiapkan penawaran yang tetap relevan untuk pasar otomasi industri.';

  @override
  String get landingTrustVerificationTitle => 'Verifikasi pembayaran manual';

  @override
  String get landingTrustVerificationBody =>
      'Pembayaran dan pengiriman saat ini dipastikan kembali oleh admin agar detail pesanan tetap akurat.';

  @override
  String get landingCatalogSectionTitle => 'Kategori utama';

  @override
  String get landingCatalogSectionSubtitle =>
      'Mulai dari komponen yang paling sering dicari untuk kebutuhan panel, mesin, dan kontrol industri.';

  @override
  String get landingHowTitle => 'Cara pemesanan';

  @override
  String get landingHowSubtitle =>
      'Alur dibuat sederhana agar pelanggan bisa lanjut belanja atau konsultasi tanpa bingung.';

  @override
  String get landingHowStep1Title => 'Jelajahi katalog';

  @override
  String get landingHowStep1Body =>
      'Cari kategori atau produk yang dibutuhkan, lalu buka detail produk untuk melihat informasi utama.';

  @override
  String get landingHowStep2Title => 'Masuk dan siapkan pesanan';

  @override
  String get landingHowStep2Body =>
      'Tambahkan produk ke keranjang, pilih alamat pengiriman, lalu lanjutkan checkout.';

  @override
  String get landingHowStep3Title => 'Bayar dan tunggu verifikasi admin';

  @override
  String get landingHowStep3Body =>
      'Upload bukti transfer QRIS, lalu admin akan memverifikasi pembayaran dan mengatur pengiriman secara manual.';

  @override
  String get landingBrandTitle => 'Brand yang tersedia';

  @override
  String get landingBrandSubtitle =>
      'Saat ini katalog menampilkan brand industri yang sudah dikenal pelanggan kami.';

  @override
  String get landingFooterTitle => 'Butuh bantuan memilih produk?';

  @override
  String get landingFooterSubtitle =>
      'Tim admin dapat membantu Anda mulai dari pencarian produk, konfirmasi pesanan, hingga proses pembayaran.';

  @override
  String get home => 'Beranda';

  @override
  String get homeTitle => 'Katalog Produk';

  @override
  String get search => 'Cari';

  @override
  String get searchHint => 'Cari FR-A820, FX5U, MR-J4...';

  @override
  String get project => 'Proyek';

  @override
  String get cart => 'Keranjang';

  @override
  String get profile => 'Profil';

  @override
  String get login => 'Masuk';

  @override
  String get logout => 'Keluar';

  @override
  String get register => 'Daftar';

  @override
  String get email => 'Email';

  @override
  String get password => 'Kata Sandi';

  @override
  String get forgotPassword => 'Lupa Kata Sandi?';

  @override
  String get welcomeBack => 'Selamat Datang Kembali';

  @override
  String get continueAction => 'Lanjutkan';

  @override
  String get buyNow => 'Beli Sekarang';

  @override
  String get continueToCheckout => 'Lanjut ke Checkout';

  @override
  String get createInvoiceAndPay => 'Buat Invoice & Bayar';

  @override
  String get or => 'atau';

  @override
  String get productCatalog => 'Katalog Produk';

  @override
  String get productDetail => 'Detail Produk';

  @override
  String get addToCart => 'Tambah ke Keranjang';

  @override
  String get checkout => 'Pembayaran';

  @override
  String get orderSummary => 'Ringkasan Pesanan';

  @override
  String get total => 'Total';

  @override
  String get quantity => 'Jumlah';

  @override
  String get price => 'Harga';

  @override
  String get description => 'Deskripsi';

  @override
  String get specifications => 'Spesifikasi';

  @override
  String get stock => 'Stok';

  @override
  String get stockReady => 'Ready Stock';

  @override
  String stockLow(int count) {
    return 'Sisa $count Unit';
  }

  @override
  String get stockEmpty => 'Habis';

  @override
  String stockUnit(int count) {
    return '$count Unit';
  }

  @override
  String get stockIndent => 'Indent';

  @override
  String get available => 'Tersedia';

  @override
  String get outOfStock => 'Stok Habis';

  @override
  String get success => 'Berhasil';

  @override
  String get error => 'Kesalahan';

  @override
  String get errorGeneric => 'Terjadi kesalahan. Silakan coba lagi.';

  @override
  String get errorNetwork => 'Tidak ada koneksi internet.';

  @override
  String get errorBcaCreateVa => 'Gagal membuat Virtual Account. Coba lagi.';

  @override
  String get errorBcaVaExpired => 'Virtual Account sudah kedaluwarsa.';

  @override
  String get cancel => 'Batal';

  @override
  String get confirm => 'Konfirmasi';

  @override
  String get payment => 'Pembayaran';

  @override
  String get paymentTitle => 'Pembayaran';

  @override
  String get paymentWaiting => 'Menunggu Pembayaran';

  @override
  String get paymentSuccess => 'Pembayaran Berhasil!';

  @override
  String get paymentExpiry => 'Batas Waktu Pembayaran';

  @override
  String get paymentVaNumber => 'Nomor Virtual Account';

  @override
  String get paymentCopy => 'Salin';

  @override
  String get paymentCopied => 'Berhasil disalin';

  @override
  String get paymentQrisTitle => 'Pembayaran QRIS';

  @override
  String get paymentScanQris =>
      'Scan kode QRIS menggunakan aplikasi mobile banking atau e-wallet favorit Anda';

  @override
  String get paymentQrisMerchant => 'PT Abadi Bangun Bersama (Otomasiku.com)';

  @override
  String get paymentQrisOnlyDescription =>
      'QRIS PT Abadi Bangun Bersama dipilih otomatis untuk pembayaran pesanan ini.';

  @override
  String get paymentQrisInstruction =>
      'Scan kode QRIS di bawah ini menggunakan aplikasi mobile banking atau e-wallet Anda, lalu upload bukti transfer setelah pembayaran berhasil.';

  @override
  String get paymentConfirmPaid => 'Saya Sudah Bayar';

  @override
  String get paymentPendingTitle => 'Menunggu Verifikasi';

  @override
  String get paymentPendingSubtitle =>
      'Admin akan memverifikasi pembayaran Anda';

  @override
  String get paymentPendingDescription =>
      'Pembayaran Anda akan diverifikasi secara manual oleh admin kami. Silakan tunggu konfirmasi melalui notifikasi.';

  @override
  String get paymentViewOrder => 'Lihat Pesanan';

  @override
  String get paymentBackToShopping => 'Kembali Belanja';

  @override
  String get paymentCheckStatus => 'Cek Status';

  @override
  String get paymentMethod => 'Metode Pembayaran';

  @override
  String get shippingAddress => 'Alamat Pengiriman';

  @override
  String get selectAddress => 'Pilih Alamat';

  @override
  String get changeAddress => 'Ganti Alamat';

  @override
  String get noAddress => 'Belum ada alamat';

  @override
  String get addressName => 'Nama Alamat';

  @override
  String get addressFull => 'Alamat Lengkap';

  @override
  String get city => 'Kota';

  @override
  String get province => 'Provinsi';

  @override
  String get postalCode => 'Kode Pos';

  @override
  String get phone => 'Telepon';

  @override
  String get companyName => 'Nama Perusahaan';

  @override
  String get npwp => 'NPWP';

  @override
  String get orders => 'Pesanan';

  @override
  String get orderHistory => 'Riwayat Pesanan';

  @override
  String get orderNumber => 'Nomor Pesanan';

  @override
  String get orderDate => 'Tanggal Pesanan';

  @override
  String get orderStatus => 'Status Pesanan';

  @override
  String get orderTotal => 'Total Pesanan';

  @override
  String get viewDetails => 'Lihat Detail';

  @override
  String get noProducts => 'Tidak ada produk';

  @override
  String get noOrders => 'Belum ada pesanan';

  @override
  String get noCartItems => 'Keranjang kosong';

  @override
  String get emptyCart => 'Keranjang Kosong';

  @override
  String get clearCart => 'Kosongkan Keranjang';

  @override
  String get cartStartShopping => 'Mulai Belanja';

  @override
  String itemCount(int count) {
    return '$count item';
  }

  @override
  String get subtotal => 'Subtotal';

  @override
  String get shippingCost => 'Ongkos Kirim';

  @override
  String get discount => 'Diskon';

  @override
  String get tax => 'Pajak';

  @override
  String get grandTotal => 'Total Keseluruhan';

  @override
  String get processing => 'Memproses';

  @override
  String get loading => 'Memuat';

  @override
  String get loadingProducts => 'Memuat produk...';

  @override
  String get retry => 'Coba Lagi';

  @override
  String get pullToRefresh => 'Tarik untuk memuat ulang';

  @override
  String productsCount(int count) {
    return '$count produk';
  }

  @override
  String get errorLoadingProducts => 'Gagal memuat produk';

  @override
  String get errorLoadingProductDetail => 'Gagal memuat detail produk';

  @override
  String get errorOffline =>
      'Tidak ada koneksi internet. Periksa jaringan Anda.';

  @override
  String get errorTimeout => 'Permintaan timeout. Silakan coba lagi.';

  @override
  String get errorSessionExpired =>
      'Sesi Anda telah berakhir. Silakan masuk kembali.';

  @override
  String get errorServer =>
      'Kesalahan server. Silakan coba beberapa saat lagi.';

  @override
  String get errorLoadAddress => 'Gagal memuat alamat.';

  @override
  String get errorImageLoad => 'Gagal memuat gambar.';

  @override
  String get notLoggedIn =>
      'Anda belum login. Silakan login untuk melanjutkan.';

  @override
  String get addressSaveFailed => 'Gagal menyimpan alamat. Silakan coba lagi.';

  @override
  String get goToLogin => 'Ke Halaman Login';

  @override
  String get cancelled => 'Dibatalkan';

  @override
  String get errorWeakPassword => 'Kata sandi minimal 6 karakter.';

  @override
  String get errorUnauthorized => 'Anda tidak memiliki akses.';

  @override
  String get errorProductNotFound => 'Produk tidak ditemukan.';

  @override
  String get errorOrderPaid => 'Pesanan sudah dibayar.';

  @override
  String get errorPaymentFailed => 'Pembayaran gagal.';

  @override
  String get errorInvalidAmount => 'Nominal pembayaran tidak valid.';

  @override
  String get errorCartEmpty => 'Keranjang Anda kosong.';

  @override
  String get errorInvalidQuantity => 'Jumlah tidak valid.';

  @override
  String get errorServiceUnavailable => 'Layanan sedang tidak tersedia.';

  @override
  String get pleaseSelectShippingAddress => 'Silakan pilih alamat pengiriman.';

  @override
  String get paymentTimeExpired => 'Waktu pembayaran habis.';

  @override
  String get loadMore => 'Muat lebih banyak';

  @override
  String get back => 'Kembali';

  @override
  String get close => 'Tutup';

  @override
  String get save => 'Simpan';

  @override
  String get edit => 'Ubah';

  @override
  String get delete => 'Hapus';

  @override
  String get add => 'Tambah';

  @override
  String get remove => 'Hapus';

  @override
  String get update => 'Perbarui';

  @override
  String get searchProducts => 'Cari Produk...';

  @override
  String get filter => 'Filter';

  @override
  String get sortBy => 'Urutkan';

  @override
  String get categories => 'Kategori';

  @override
  String get allCategories => 'Semua Kategori';

  @override
  String get inverter => 'Inverter';

  @override
  String get plc => 'PLC';

  @override
  String get hmi => 'HMI';

  @override
  String get servo => 'Servo';

  @override
  String get brand => 'Merek';

  @override
  String get allBrands => 'Semua Merek';

  @override
  String get mitsubishi => 'Mitsubishi';

  @override
  String get danfoss => 'Danfoss';

  @override
  String get virtualAccount => 'Virtual Account';

  @override
  String get bca => 'BCA';

  @override
  String get transferBank => 'Transfer Bank';

  @override
  String get invoice => 'Faktur';

  @override
  String get downloadInvoice => 'Unduh Faktur';

  @override
  String get language => 'Bahasa';

  @override
  String get addToCartShort => 'Tambah';

  @override
  String get added => '✓ Ditambahkan';

  @override
  String get compareMaxError => 'Maksimal 2 produk untuk dibandingkan';

  @override
  String get compare => 'Bandingkan';

  @override
  String get clear => 'Hapus Semua';

  @override
  String get cartRemoveConfirm => 'Hapus item ini dari keranjang?';

  @override
  String get cartRemoveTitle => 'Hapus Item';

  @override
  String volumeDiscount(String amount) {
    return 'Hemat $amount';
  }

  @override
  String get pricePerUnit => 'Harga per unit';

  @override
  String get tieredPricing => 'Harga Bertingkat (B2B)';

  @override
  String get priceNormal => 'Harga normal';

  @override
  String get bestDeal => 'Best Deal';

  @override
  String get contactSales => 'Hubungi sales';

  @override
  String get documents => 'Dokumen';

  @override
  String get compatible => 'Kompatibel';

  @override
  String compatibleWith(String name) {
    return 'Produk yang kompatibel dengan $name:';
  }

  @override
  String get download => 'Unduh';

  @override
  String get buy => 'Beli';

  @override
  String get saveToProject => 'Simpan ke Proyek';

  @override
  String unitsAvailable(int count) {
    return '$count Unit Tersedia';
  }

  @override
  String readyToShip(String time) {
    return 'Siap kirim $time';
  }

  @override
  String get rfq => 'RFQ';

  @override
  String get rfqTitle => 'Request for Quote';

  @override
  String get rfqQuantity => 'Jumlah yang Diinginkan';

  @override
  String rfqMinQuantity(int count) {
    return 'Minimal $count unit';
  }

  @override
  String get rfqCompanyName => 'Nama Perusahaan';

  @override
  String get rfqSubmit => 'Kirim RFQ';

  @override
  String get rfqSent => 'RFQ berhasil dikirim!';

  @override
  String get addToCompare => 'Tambahkan ke perbandingan';

  @override
  String get addedToCompare => 'Ditambahkan ke perbandingan';

  @override
  String get saveProduct => 'Simpan Produk';

  @override
  String savedToProject(Object project) {
    return 'Disimpan ke: $project';
  }

  @override
  String get newArrival => 'New Arrival';

  @override
  String addedToCart(String name) {
    return '$name ditambahkan ke keranjang';
  }

  @override
  String insufficientStock(int count) {
    return 'Maaf, stok tidak mencukupi. Sisa stok: $count';
  }

  @override
  String get shipping => 'Pengiriman';

  @override
  String get paymentSummary => 'Ringkasan Pembayaran';

  @override
  String get volumeDiscountLabel => 'Diskon Volume';

  @override
  String get taxLabel => 'PPN (11%)';

  @override
  String get totalPayment => 'Total Pembayaran';

  @override
  String get termsAgree => 'Saya menyetujui Syarat dan Ketentuan';

  @override
  String get companyPO => 'Nomor PO Perusahaan (Opsional)';

  @override
  String get poPlaceholder => 'PO/2024/001';

  @override
  String get standardShipping => 'Pengiriman Standar';

  @override
  String get shippingEstimate => 'Estimasi 3-5 hari kerja';

  @override
  String get shippingManualDescription =>
      'Pengiriman diatur secara manual oleh admin setelah pembayaran Anda diverifikasi.';

  @override
  String get freeShipping => 'GRATIS';

  @override
  String get bcaVirtualAccount => 'BCA Virtual Account';

  @override
  String get bankTransfer => 'Transfer Bank (Dicek Otomatis)';

  @override
  String get paymentHowTo => 'Cara Pembayaran:';

  @override
  String get paymentStep1 => 'Klik \"Buat Invoice\" untuk mendapat nomor VA';

  @override
  String get paymentStep2 => 'Transfer melalui BCA Mobile/ATM';

  @override
  String get paymentStep3 => 'Otomatis terverifikasi dalam 5 menit';

  @override
  String get pleaseAcceptTerms => 'Silakan centang persetujuan';

  @override
  String get paymentCountdown => 'Batas waktu pembayaran';

  @override
  String get vaNumberLabel => 'Nomor Virtual Account BCA';

  @override
  String get vaCopied => 'Nomor VA berhasil disalin';

  @override
  String get payBefore => 'Bayar sebelum';

  @override
  String get transferAmount => 'Jumlah yang harus ditransfer';

  @override
  String get paymentViaMBanking => 'Via m-Banking';

  @override
  String get paymentViaAtm => 'Via ATM';

  @override
  String get paymentViaInternetBanking => 'Via Internet Banking';

  @override
  String get mbankingStep1 => 'Buka aplikasi m-Banking BCA';

  @override
  String get mbankingStep2 => 'Pilih menu Transfer > Virtual Account';

  @override
  String get mbankingStep3 => 'Masukkan nomor VA dan konfirmasi';

  @override
  String get mbankingStep4 => 'Masukkan PIN dan konfirmasi pembayaran';

  @override
  String get atmStep1 => 'Masukkan kartu ATM dan PIN';

  @override
  String get atmStep2 =>
      'Pilih Transaksi Lainnya > Transfer > BCA Virtual Account';

  @override
  String get atmStep3 => 'Masukkan nomor VA dan tekan Benar';

  @override
  String get atmStep4 => 'Konfirmasi dan pilih Ya untuk menyelesaikan';

  @override
  String get ibankingStep1 => 'Login ke KlikBCA (internetbanking.klikbca.com)';

  @override
  String get ibankingStep2 =>
      'Pilih Transfer Dana > Transfer ke BCA Virtual Account';

  @override
  String get ibankingStep3 => 'Masukkan nomor VA dan klik Lanjutkan';

  @override
  String get ibankingStep4 => 'Masukkan respon KeyBCA APPLI dan konfirmasi';

  @override
  String get paymentSuccessTitle => 'Pembayaran Berhasil!';

  @override
  String get paymentSuccessSubtitle => 'Pesanan Anda sedang diproses';

  @override
  String get viewOrder => 'Lihat Pesanan';

  @override
  String get backToHome => 'Kembali ke Beranda';

  @override
  String get orderNotFound => 'Pesanan tidak ditemukan';

  @override
  String get orderDetail => 'Detail Pesanan';

  @override
  String estimatedDelivery(String date) {
    return 'Estimasi pengiriman: $date';
  }

  @override
  String get statusHistory => 'Riwayat Status';

  @override
  String get paymentReceived => 'Pembayaran Diterima';

  @override
  String get processingSubtitle => 'Verifikasi stok dan packaging';

  @override
  String get shipped => 'Dikirim';

  @override
  String get shippedSubtitle => 'Dalam perjalanan ke alamat tujuan';

  @override
  String get delivered => 'Selesai';

  @override
  String get orderedItems => 'Item Dipesan';

  @override
  String get shippingInfo => 'Info Pengiriman';

  @override
  String get trackingNote => 'Nomor resi akan muncul setelah barang dikirim';

  @override
  String get comingSoon => 'Segera tersedia';

  @override
  String get shareOrder => 'Bagikan Pesanan';

  @override
  String get contactSupport => 'Hubungi Support';

  @override
  String get grandTotalLabel => 'Total Pembayaran';

  @override
  String get profileTitle => 'Profil';

  @override
  String get myOrders => 'Pesanan Saya';

  @override
  String get addressBook => 'Alamat Pengiriman';

  @override
  String get paymentMethods => 'Pembayaran';

  @override
  String get helpCenter => 'Bantuan';

  @override
  String get logoutConfirm => 'Yakin ingin keluar?';

  @override
  String get logoutSuccess => 'Berhasil logout';

  @override
  String get myProjects => 'Proyek Saya';

  @override
  String get activeProjects => 'Proyek Aktif';

  @override
  String get totalItems => 'Total Item';

  @override
  String get totalEstimate => 'Total Estimasi';

  @override
  String get checkoutProject => 'Checkout Proyek';

  @override
  String get requestRFQ => 'Ajukan RFQ';

  @override
  String get createProject => 'Buat Proyek';

  @override
  String get projectName => 'Nama Proyek';

  @override
  String get compareProducts => 'Bandingkan Produk';

  @override
  String get addProduct => 'Tambah Produk';

  @override
  String get power => 'Daya';

  @override
  String get voltage => 'Tegangan';

  @override
  String get warranty => 'Garansi';

  @override
  String get sortRelevance => 'Relevansi';

  @override
  String get sortPriceLow => 'Harga Terendah';

  @override
  String get sortPriceHigh => 'Harga Tertinggi';

  @override
  String get sortNameAsc => 'Nama A-Z';

  @override
  String get sortNameDesc => 'Nama Z-A';

  @override
  String get activeFiltersLabel => 'Filter aktif:';

  @override
  String get noActiveFilters => 'Tidak ada filter aktif';

  @override
  String searchResultsCount(int count) {
    return 'Ditemukan $count produk';
  }

  @override
  String get productsSelected => 'Produk dipilih';

  @override
  String get applyFilter => 'Terapkan Filter';

  @override
  String get addFilter => 'Tambah Filter';

  @override
  String get filterCategory => 'Kategori Produk';

  @override
  String get filterAvailability => 'Ketersediaan Stok';

  @override
  String get filterPower => 'Rentang Daya';

  @override
  String get powerRangeSmall => '≤ 2.2 kW';

  @override
  String get powerRangeMedium => '3.7–15 kW';

  @override
  String get powerRangeLarge => '≥ 18.5 kW';

  @override
  String get noProductsFound => 'Tidak ada produk ditemukan';

  @override
  String get tryDifferentFilters => 'Coba ubah kata kunci atau filter';

  @override
  String unitsInStock(int count) {
    return '$count Unit Tersedia';
  }

  @override
  String unitsRemaining(int count) {
    return 'Sisa $count Unit';
  }

  @override
  String indentLeadTime(String time) {
    return 'Indent $time';
  }

  @override
  String get addNewAddress => 'Tambah Alamat Baru';

  @override
  String get firstName => 'Nama Depan';

  @override
  String get lastName => 'Nama Belakang';

  @override
  String get kecamatan => 'Kecamatan';

  @override
  String get kelurahan => 'Kelurahan';

  @override
  String get deliveryNotes => 'Catatan Pengiriman';

  @override
  String get fillRequiredFields => 'Lengkapi semua field yang wajib diisi';

  @override
  String get primary => 'Utama';

  @override
  String get useAddress => 'Gunakan Alamat Ini';

  @override
  String get saveAddress => 'Simpan Alamat';

  @override
  String get optional => 'opsional';

  @override
  String minQuantityTier(int count) {
    return 'Minimal pembelian $count unit untuk tier harga ini';
  }

  @override
  String get viewProduct => 'Lihat Produk';

  @override
  String get addToCartQuestion => 'Tambahkan ke Keranjang?';

  @override
  String get selectAll => 'Pilih Semua';

  @override
  String get selectItem => 'Pilih item';

  @override
  String get noItemSelected => 'Pilih minimal 1 item untuk checkout';

  @override
  String productSelected(int count) {
    return '$count produk dipilih';
  }

  @override
  String get removeSelection => 'Hapus';

  @override
  String get compareProduct => 'Bandingkan';

  @override
  String get errorInvalidCredentials => 'Email atau password salah.';

  @override
  String get errorDuplicateEntry => 'Email sudah terdaftar. Silakan login.';

  @override
  String get errorRateLimit => 'Terlalu banyak percobaan. Coba lagi nanti.';

  @override
  String get errorUserNotFound => 'Akun tidak ditemukan.';

  @override
  String get errorValidation => 'Data tidak valid. Periksa kembali.';

  @override
  String get loginTitle => 'Selamat Datang!';

  @override
  String get loginSubtitle => 'Masuk untuk melanjutkan';

  @override
  String get registerTitle => 'Daftar Akun';

  @override
  String get registerSubtitle => 'Lengkapi form di bawah ini';

  @override
  String get rememberMe => 'Ingat saya';

  @override
  String get noAccount => 'Belum punya akun?';

  @override
  String get haveAccount => 'Sudah punya akun?';

  @override
  String get agreeTerms => 'Saya setuju dengan Syarat & Ketentuan';

  @override
  String get nameHint => 'Nama Lengkap';

  @override
  String get passwordHint => 'Password';

  @override
  String get confirmPasswordHint => 'Konfirmasi Password';

  @override
  String get emailHint => 'Username / Email';

  @override
  String get loginButton => 'Masuk';

  @override
  String get registerButton => 'Daftar';

  @override
  String get passwordMinLength => 'Password minimal 6 karakter';

  @override
  String fieldRequired(String field) {
    return '$field harus diisi';
  }

  @override
  String get agreeTermsRequired =>
      'Anda harus setuju dengan Syarat & Ketentuan';

  @override
  String get editProfile => 'Edit Profil';

  @override
  String get fullName => 'Nama Lengkap';

  @override
  String get saveProfile => 'Simpan Profil';

  @override
  String get profileUpdated => 'Profil berhasil diperbarui';

  @override
  String get addressLabel => 'Label Alamat';

  @override
  String get recipient => 'Penerima';

  @override
  String get addAddress => 'Tambah Alamat';

  @override
  String get editAddress => 'Edit Alamat';

  @override
  String get deleteAddress => 'Hapus Alamat';

  @override
  String get deleteAddressConfirm => 'Hapus alamat ini?';

  @override
  String get addressDeleted => 'Alamat berhasil dihapus';

  @override
  String get noAddressSaved => 'Belum ada alamat tersimpan';

  @override
  String get setAsDefault => 'Jadikan alamat utama';

  @override
  String get saveChanges => 'Simpan Perubahan';

  @override
  String get noAddresses => 'Tidak ada alamat';

  @override
  String get notificationPermissionTitle => 'Aktifkan Notifikasi';

  @override
  String get notificationPermissionBody =>
      'Dapatkan update status pesanan Anda secara real-time';

  @override
  String get notificationActivate => 'Aktifkan';

  @override
  String get notificationLater => 'Nanti';

  @override
  String get noProjects => 'Belum ada proyek';

  @override
  String get createProjectHint => 'Buat proyek untuk mengelola pembelian B2B';

  @override
  String get chat => 'Chat';

  @override
  String get openingWhatsApp => 'Membuka WhatsApp...';

  @override
  String get clearCompareConfirm => 'Hapus semua produk dari perbandingan?';

  @override
  String get compareCleared => 'Perbandingan dikosongkan';

  @override
  String get checkPaymentStatus => 'Cek Status Pembayaran';

  @override
  String get settings => 'Pengaturan';

  @override
  String get appearance => 'Tampilan';

  @override
  String get security => 'Keamanan';

  @override
  String get darkMode => 'Mode Gelap';

  @override
  String get name => 'Nama';

  @override
  String get changePassword => 'Ganti Password';

  @override
  String get changePasswordSubtitle => 'Ubah password akun Anda';

  @override
  String get resetPasswordViaEmail => 'Reset Password via Email';

  @override
  String resetPasswordSubtitle(String email) {
    return 'Kirim link reset ke $email';
  }

  @override
  String get newPassword => 'Password Baru';

  @override
  String get confirmPassword => 'Konfirmasi Password';

  @override
  String get passwordMinChars => 'Password minimal 8 karakter';

  @override
  String get passwordMismatch => 'Password tidak cocok';

  @override
  String get passwordChanged => 'Password berhasil diubah';

  @override
  String resetLinkSent(String email) {
    return 'Link reset password dikirim ke $email';
  }

  @override
  String get profileSaved => 'Profil berhasil disimpan';

  @override
  String get uploadPhotoSoon => 'Fitur upload foto segera hadir';

  @override
  String get forgotPasswordSubtitle =>
      'Masukkan email Anda dan kami akan mengirim link untuk reset password';

  @override
  String get sendResetLink => 'Kirim Link Reset';

  @override
  String get paymentUploadProof => 'Upload Bukti Transfer';

  @override
  String get paymentProofPending => 'Menunggu Verifikasi Admin';

  @override
  String get paymentProofApproved => 'Pembayaran Dikonfirmasi';

  @override
  String paymentProofRejectedReason(String reason) {
    return 'Ditolak: $reason';
  }

  @override
  String get paymentReupload => 'Upload Ulang';

  @override
  String get paymentBankName => 'Nama Bank';

  @override
  String get paymentBankNameCustom => 'Nama Bank';

  @override
  String get paymentAccountName => 'Nama Rekening Pengirim';

  @override
  String get paymentAmount => 'Nominal Transfer';

  @override
  String get paymentPickImage => 'Galeri';

  @override
  String get paymentTakePhoto => 'Kamera';

  @override
  String get paymentSubmitProof => 'Kirim Bukti Transfer';

  @override
  String get paymentProofUploaded => 'Bukti transfer berhasil dikirim';

  @override
  String get paymentExpiredStockReleased =>
      'Stok untuk pesanan yang kedaluwarsa ini sudah dilepas kembali.';

  @override
  String get paymentExpiredCheckoutAgain =>
      'Silakan checkout lagi jika Anda masih membutuhkan item ini.';

  @override
  String get paymentFieldsRequired => 'Semua kolom wajib diisi';

  @override
  String get paymentLeaveTitle => 'Keluar dari pembayaran?';

  @override
  String get paymentLeaveMessage =>
      'Apakah Anda yakin mau keluar menu pembayaran ini?';

  @override
  String get exitAppTitle => 'Keluar dari aplikasi?';

  @override
  String get exitAppMessage => 'Apakah Anda yakin ingin keluar?';

  @override
  String get leave => 'Keluar';

  @override
  String get productUnavailable => 'Produk ini sedang tidak tersedia';

  @override
  String trackingNumber(String resi) {
    return 'Nomor Resi: $resi';
  }

  @override
  String get paymentConfirmDialogTitle => 'Konfirmasi Pembayaran';

  @override
  String get paymentConfirmDialogBody =>
      'Dengan menekan konfirmasi, tim kami akan memverifikasi pembayaran Anda. Proses verifikasi membutuhkan waktu 1x24 jam.';

  @override
  String get confirmReceived => 'Pesanan Diterima';

  @override
  String get confirmReceivedDialog =>
      'Konfirmasi bahwa pesanan sudah diterima?';

  @override
  String get confirmReceivedSuccess => 'Pesanan berhasil dikonfirmasi';

  @override
  String get productPriceNotSetTitle => 'Harga Belum Tersedia';

  @override
  String get productPriceNotSetBody =>
      'Produk ini belum memiliki harga. Silakan hubungi admin untuk info ketersediaan dan harga.';

  @override
  String get productPriceNotSetContactAdmin => 'Hubungi Admin via WhatsApp';

  @override
  String get contactAdmin => 'Hubungi Admin';
}
