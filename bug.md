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
| 11 | Add to cart error USER_NOT_FOUND → blink ke beranda | Bootstrap belum selesai saat `addItem` dipanggil | Retry `addItem` setelah 2s delay jika `USER_NOT_FOUND`; track `isBootstrapped` state |
| 12 | USER_NOT_FOUND saat app restart dengan session lama | `_init()` tidak memanggil `bootstrap()` | Panggil `_bootstrap()` di `_init()` untuk existing sessions |
| 13 | Alamat checkout tidak bisa diganti, ada alamat template | Auto-create alamat dummy + tidak ada tombol ganti | Hapus auto-create; tambah tombol "Ganti Alamat" + bottom sheet picker |
| 14 | Halaman pembayaran hanya loading (VA null) | Backend staging belum generate VA dari BCA | Tampilkan pesan pending + tombol `[DEBUG] Simulasi Pembayaran Berhasil` di kDebugMode |
| 15 | Splash screen langsung ke login tanpa tombol ditekan | Router redirect tidak eksplisit skip splash untuk unauthenticated | Tambah rule: `if (isSplash && !isAuthenticated) return null` |
| 16 | Pesan error login terlalu spesifik (bocorkan info) | Error code raw ditampilkan langsung | Tampilkan "Email atau password salah." untuk semua error login |
| 17 | User belum login bisa add to cart tanpa pesan | Tidak ada auth check sebelum `addItem` | Cek `isAuthenticated` di `_handleAddToCart`, `_addToCart`, `_buyNow`; tampilkan toast |
| 18 | Fitur ganti/reset password tidak ada | Belum diimplementasi | Tambah "Ganti Password" (dialog) + "Reset via Email" di Settings → Keamanan |
| 19 | Ikon mata tidak ada di field password | `obscureText: true` hardcoded tanpa toggle | Tambah `suffixIcon` toggle visibility di login & register |
| 20 | Avatar di home hardcoded "JD" | Tidak menggunakan data user | `_ProfileAvatar` widget yang watch `authProvider` dan tampilkan inisial nama |
| 21 | Menu "Edit Profile" & "Bahasa" duplikat di profile | Sudah ada di Settings | Hapus dari profile menu |

---

## ⚠️ Remaining (Backend)

| # | Bug | Keterangan |
|---|-----|-----------|
| 1 | Order items kosong di admin dashboard | Admin menampilkan "0 items in this order". Flutter sudah kirim cart ke server dengan benar (totalAmount = 1.800.000 membuktikan server baca cart). Kemungkinan bug di `GET /admin/orders/:id` di repo `otomasiku-api` — perlu dicek apakah `items` di-include dalam response |
| 2 | VA number tidak di-generate | Backend staging tidak generate VA dari BCA setelah `POST /orders`. Perlu endpoint `POST /api/dev/simulate-payment/:orderId` untuk update `paymentStatus = 'paid'` agar dashboard admin juga update |
