# Bug Tracker — Otomasiku Mobile

## ✅ Resolved

| # | Bug | Root Cause | Fix |
|---|-----|-----------|-----|
| 1 | Total bayar di payment_success = 0 | `CreateOrderResult.totalAmount` tidak di-pass ke payment screen | `totalAmount` di-pass via query param: checkout → payment → payment_success |
| 2 | Total tidak sync antara APK dan dashboard admin | Client menghitung PPN 11% sendiri, server tidak | Hapus kalkulasi PPN di client; gunakan `totalAmount` dari server |
| 3 | Dari checkout → muncul halaman cart kosong sebentar sebelum ke payment | `clearCart()` dipanggil sebelum navigate | Navigate dulu, baru `clearCart()` (fire-and-forget); tambah flag `_isNavigating` |
| 4 | Stock berkurang saat produk masuk keranjang | `displayStock = product.stock - cartQuantity` di product_card & product_detail | Hapus pengurangan; stock hanya berkurang di server saat order confirmed |
| 5 | Halaman pembayaran error "terjadi kesalahan" | `Order.shippingAddress` & `items` non-nullable tapi API tidak mengembalikannya di status endpoint | Buat `shippingAddress` dan `items` nullable di model `Order` |
| 6 | Checkout tidak masuk ke dashboard admin | `FakeOrderRepository` di-inject via Riverpod override saat `kDebugMode` | Hapus override; gunakan `OrderRepositoryImpl` real |
| 7 | Register tidak menampilkan dialog konfirmasi email | `_updateFromSession()` selalu set `isAuthenticated = true` meski session null | Cek `session != null` sebelum set authenticated |
| 8 | User baru tidak bisa pakai fitur setelah register | `_onAuthenticated` tidak dipanggil setelah register; cart tidak di-load | Panggil `_onAuthenticated`, `_loadProfile()` setelah register berhasil |
| 9 | Nama user tidak muncul di profile setelah register | `fullName` dari form tidak di-sync ke backend profile | `PATCH /me` dengan `fullName` setelah register; sync dari Supabase metadata saat login |
| 10 | Gradle build gagal (corrupt cache) | Disk penuh saat build → Gradle cache corrupt | Hapus `~/.gradle/caches`, kill Java processes, rebuild |
| 11 | Cart loading lambat (spinner polos) | Tidak ada skeleton/shimmer saat load cart | Shimmer skeleton `CartItemShimmer` menggantikan `CircularProgressIndicator` |
| 12 | Item baru di cart tampil kosong/loading | Optimistic update pakai snapshot kosong (`name: '', price: 0`) | `addItem()` menerima `CartProductSnapshot` dari caller yang sudah punya data produk |
| 13 | Validation error "email/password required" tidak terlihat | `errorStyle: TextStyle(fontSize: 0, height: 0)` menyembunyikan error | Error style diubah ke visible (coral red, fontSize 12) |
| 14 | Dialog "Ganti Password" warna pink dan tidak estetik | Material 3 `ColorScheme.fromSeed(red)` menghasilkan pink surfaces | Override `surfaceContainer` variants ke putih; redesign dialog jadi custom `Dialog` |
| 15 | Banner "Lihat Detail" → gagal memuat detail produk | Hardcoded SKU `'MIT-PLC-001'` bukan valid product ID (int) | Banner cari produk dari cache by category; fallback ke search |
| 16 | Banner tidak bisa slide, hanya 1 static | Hanya 1 banner hardcoded | Carousel 3 banner, auto-slide 4s, infinite loop, swipeable |
| 17 | Klik produk → red screen `_elements.contains(element)` | `StatefulShellRoute` + `pushNamed` ke route luar tanpa `parentNavigatorKey` | Tambah `_rootNavigatorKey` + `parentNavigatorKey` ke semua route di luar shell |
| 18 | Banner `goNamed` → red screen `_dependents.isEmpty` | `goNamed` dari dalam shell ke route luar menghancurkan shell | Ubah ke `pushNamed` |
| 19 | Back button di beberapa halaman langsung keluar app | `context.pop()` tanpa cek `canPop()` di route luar shell | Pattern `canPop ? pop : goNamed(home)` di shipping, checkout, compare, address, payment methods |
| 20 | Logout tidak langsung keluar (harus 2x) | `logout()` async tapi dipanggil tanpa `await`; auth state belum berubah saat navigate | `await logout()` sebelum navigate; tambah loading indicator di dialog |
| 21 | Bandingkan produk max 2, tidak bisa tambah lagi | Hardcoded `productIds.length < 2` | Hapus limit; `toggle()` selalu return true |
| 22 | Halaman compare kepotong, tidak bisa scroll | `OverflowBox` memblokir scroll; `showAddColumn` false saat ≥2 produk | Hapus `OverflowBox`; nested `SingleChildScrollView`; `showAddColumn` selalu true |
| 23 | Compare column overflow (garis kuning-hitam) | Height 250px tidak cukup untuk konten | Naikkan ke 270px + `clipBehavior: Clip.hardEdge` |
| 24 | "Simpan ke Proyek" menampilkan proyek dummy | `ProjectNotifier` auto-load `dummyProjects` saat init | Hapus auto-load; mulai kosong; user buat sendiri |
| 25 | "Simpan ke Proyek" hanya text field tanpa list | Tidak ada UI untuk pilih proyek existing | Bottom sheet dengan list proyek + tombol buat baru |
| 26 | Reset password link di email tidak buka app | `resetPasswordForEmail` tanpa `redirectTo` | Tambah `redirectTo: 'io.otomasiku.app://login-callback'`; tambah `onAuthStateChange` listener untuk `passwordRecovery` event |
| 27 | Tidak ada halaman set password baru setelah klik link email | Belum ada screen dan route | Buat `ResetPasswordScreen` + route `/reset-password` |
| 28 | "Ingat saya" tidak berfungsi | `_rememberMe` tidak digunakan; session selalu persist | Simpan flag di secure storage; cek saat init → sign out jika false |
| 29 | Nomor pesanan tidak cocok dengan dashboard admin | `order.g.dart` hanya baca `orderNumber` (camelCase); API kirim `order_number` (snake_case) | Fallback parsing: `json['orderNumber'] ?? json['order_number']` |
| 30 | Jumlah transfer di payment screen kurang jelas | Hanya teks besar tanpa konteks | Redesign: highlight box + tombol copy nominal + catatan info |
| 31 | RFQ hanya toast "dikirim" tanpa aksi nyata | Tidak ada integrasi | Redirect ke WhatsApp (081252078076) dengan template pesan |
| 32 | Info pengiriman di detail pesanan berantakan | Satu blok teks `\n`-separated | Redesign: structured rows dengan icon per bagian (penerima, alamat, telepon) |

---
## ⚠️ Remaining (Backend)

| # | Bug | Keterangan |
|---|-----|-----------|
| 1 | Order items kosong di admin dashboard | Admin menampilkan "0 items in this order". Flutter sudah kirim cart ke server dengan benar (totalAmount = 1.800.000 membuktikan server baca cart). Kemungkinan bug di `GET /admin/orders/:id` di repo `otomasiku-api` — perlu dicek apakah `items` di-include dalam response |
