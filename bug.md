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

---
## ⚠️ Remaining (Backend)

| # | Bug | Keterangan |
|---|-----|-----------|
| 1 | Order items kosong di admin dashboard | Admin menampilkan "0 items in this order". Flutter sudah kirim cart ke server dengan benar (totalAmount = 1.800.000 membuktikan server baca cart). Kemungkinan bug di `GET /admin/orders/:id` di repo `otomasiku-api` — perlu dicek apakah `items` di-include dalam response |
