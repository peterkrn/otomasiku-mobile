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
  String get paymentCheckStatus => 'Cek Status';

  @override
  String get paymentMethod => 'Metode Pembayaran';

  @override
  String get shippingAddress => 'Alamat Pengiriman';

  @override
  String get selectAddress => 'Pilih Alamat';

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
  String get retry => 'Coba Lagi';

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
  String get compareMaxError => 'Maksimal 3 produk untuk dibandingkan';

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
}
