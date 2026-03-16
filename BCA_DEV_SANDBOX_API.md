
# PT. Bank Central Asia, Tbk

## Panduan Penggunaan

### Sandbox API BCA – Developer BCA

Versi 1.1 – April 2025

# Daftar Isi

1. Fitur Sandbox API BCA...................................................3  
2. Application di Sandbox API BCA...........................................3  
   2.1 Mengelola Application di Sandbox API BCA...........................3  
   2.1.1 Membuat Application di Sandbox API BCA.........................3  
   2.1.2 Merubah Application di Sandbox API BCA.........................6  
   2.2 Mengidentifikasi fitur SNAP dan non SNAP pada Sandbox API BCA.......8  
   2.3 Mendapatkan data Credentials & Keys pada Application................9  
   API Keys..............................................................9  
   OAuth Credentials...................................................10  
   Public Key & Private Key............................................10  
3. Mendapatkan Token......................................................11  
   3.1 Mendapatkan Token pada Layanan SNAP...............................11  
   3.1.1 Membuat Signature-Auth SNAP....................................11  
   3.1.2 Mendapatkan Token Oauth SNAP...................................13  
   3.2 Mendapatkan Token pada Layanan Non-SNAP...........................16  
4. Melakukan Transaksi Layanan API di Sandbox API BCA....................20  
   4.1 Melakukan Transaksi Layanan SNAP...................................20  
   4.1.1 Membuat Signature-Service SNAP..................................20  
   4.1.2 Membuat Request API SNAP.......................................23  
   4.2 Melakukan Transaksi Layanan Non SNAP...............................26  
   4.2.1 Membuat Signature pada Layanan Non SNAP.......................26  
   4.2.2 Membuat Request API Non SNAP...................................29

# 1. Fitur Sandbox API BCA

Sandbox API BCA merupakan salah satu fitur pada Website Developer API BCA sebagai sarana informasi cara penggunaan dan uji coba layanan API BCA. Fitur Sandbox API BCA memberikan simulasi hasil response yang didapatkan dari request API BCA tanpa harus melakukan development terlebih dahulu. Fitur ini dapat diakses oleh seluruh Pengguna yang sudah melakukan registrasi akun pada Website Developer API BCA.

# 2. Application di Sandbox API BCA

Untuk dapat menggunakan Sandbox API BCA, Anda perlu login atau registrasi akun pada Website Developer API BCA terlebih dahulu. Setelah login pada Website Developer API BCA, Anda perlu membuat Application sebagai platform untuk menunjang properti uji coba API BCA. Dengan membuat Application pada Sandbox API BCA, sistem akan membuatkan data Credentials dan Keys untuk Anda melakukan simulasi fitur API BCA pada Sandbox API BCA.

## 2.1 Mengelola Application di Sandbox API BCA

Anda dapat membuat beberapa Application baru atau merubah data Application yang sudah dibuat.

### 2.1.1 Membuat Application di Sandbox API BCA

1) Silakan login akun Website Developer API BCA pada alamat URL berikut https://developer.bca.co.id/id/Login bagi yang sudah pernah mendaftarkan akun sebelumnya. Jika belum mendaftarkan akun sebelumnya, silakan lakukan sign up dengan klik “Registrasi di sini”.

2) Pilih menu “My Application” pada dropdown akun

3) Pilih menu Create Application

4) Input profil application pada field yang disediakan

5) Pilih layanan API BCA yang ingin diuji coba pada application. Untuk mencari layanan secara cepat anda bisa memanfaatkan fitur search atau pilih kategori layanan yang tersedia. Klik “Save Application” untuk menyimpan profil dan membuat Application

6) Application yang berhasil dibuat akan tampil pada halaman My Application

My Applications
Bagaimana cara membuat sandbox baru? ↓
REST tesoneklik →
REST tes sandbox SNAP →
REST Tes Informasi dan Mutasi Rekening →

### 2.1.2 Merubah Application di Sandbox API BCA

1) Klik tombol panah pada Applications yang ingin diubah

My Applications
Bagaimana cara membuat sandbox baru? ↓
REST tesoneklik →
REST tes sandbox SNAP →
REST Tes Informasi dan Mutasi Rekening →

2) Pada halaman Sandbox View klik button “Ubah Aplikasi”

3) Ubah profil Application serta menambah/menghapus layanan API BCA pada Application terkait. Lalu klik Save untuk menyimpan perubahan.

## 2.2 Mengidentifikasi fitur SNAP dan non SNAP pada Sandbox API BCA

Layanan API BCA berbasis SNAP merupakan API BCA yang telah disesuaikan dengan Standar Nasional Open API Pembayaran (SNAP) yang ditetapkan oleh Bank Indonesia (BI). Untuk mengetahui dan membedakan layanan API BCA yang berbasis SNAP dan non SNAP, dapat dilihat pada halaman fitur (https://developer.bca.co.id/id/Fitur-API). Jika icon pada layanan API BCA memiliki logo SNAP, maka layanan API BCA tersebut memiliki format telah berbasis SNAP. Sedangkan layanan API BCA yang tidak memiliki logo SNAP, maka layanan API BCA tersebut merupakan layanan API BCA non SNAP.

Layanan API BCA berbasis SNAP

Layanan API BCA non SNAP

## 2.3 Mendapatkan data Credentials & Keys pada Application

Berikut langkah mendapatkan data Credentials & Keys pada Application:

1) Buka detail aplikasi dengan klik panah pada Applications

2) Pada halaman Sandbox View tampil profil application, pada bagian paling bawah terdapat 3 label dropdown properties dengan penjelasan sebagai berikut:

### API Keys

Berikut penjelasan fungsi API Keys:

| Properties | Layanan SNAP | Layanan Non-SNAP |
|------------|--------------|------------------|
| API Key    | (field ini tidak digunakan pada layanan SNAP) | Parameter X-BCA-KEY pada saat request service. |
| API Secret | (field ini tidak digunakan pada layanan SNAP) | Sebagai material yang akan digunakan dalam melakukan hashing HMAC untuk utilities signature. |

# OAuth Credentials

Oauth Credentials
- Client ID
  77ebe45a-4baf-4e66-a7fd-3a9920819501
- Type
  Confidential
- Javascript Origins
  *
- Description
  17 Nov 2023, 15:41
- Client Secret
  285083ae-46ce-4616-be50-e6ad7252db52

Berikut penjelasan fungsi OAuth Credentials:

| Properties | Layanan SNAP | Layanan Non-SNAP |
|------------|--------------|------------------|
| Client ID  | Sebagai Parameter X-CLIENT-KEY pada saat generate signature asymmetric (signature-auth) dan token OAuth. | Material encode base64 yang akan digunakan untuk utilities get token. |
| Client Secret | Sebagai Parameter X-SIGNATURE pada saat generate signature symmetric (signature-service) untuk request service. | Material encode base64 yang akan digunakan untuk utilities get token. |

# Public Key & Private Key

Public Key & Private Key
- Private Key
  -----BEGIN PRIVATE KEY-----
  MIIEvglBADANBgqhkig9w0BAQEFAAACBKGwggs5kAgEAAolBAQCekStDYufsqv8HH78fzloRa6DjuDMMDD8YxVc3uQYOPxN2lWb2cNs/pG3Nn06cfuqnEvUgvougsUMhVUVf1n670pA2B2eiOQdsYPNx2sSUVPHUgj12HSWn5yNxM29Mi2v1DhZvzdiRMtAw66jTyF9BleCqjq/oW3uHqKWGtepoJvHNtgL29MGJtZEx0ouEOK0uCujK-vMMqKXIUhMZur2Bah99D6vuMnmpmCnNQEvJ4MqhFQHD4uzW6qq1evwvHVbk8wPOq1HBytfBQW/fowdtjKtSRaUf6dShHBrdcHDWiu+5T0B7LcbUY7oKFDk8NGdrHQlRaKigLU2BGFVVAgMBAAECggEUseq4fo+1N6CzX6S8TveTmlu3j6rAfUligERVAg5UQvwOZWBLFZxAp7lzVs6O7Eq0ctghKR/3UE7tbvUoY8ZCupRUrRc2vhW07FWYfeISZizO4adkZVLRsMNHcTSNjK0JGAoZp8Meeg86297nok+hs5r62OyZjx0KGFjX5wB/ziNwBlrc5asxGk4DhwGsSILrpi+3/xTdTeUu1kAnSREHSEgunGW+VFE/IGXiGgqd254m6MW8nRlaKn50DiZd3+YRkbbRUAaZ/GyTdwMZZrptn9H+ZSRMI0Z9sS0pe8LmjM5eqiCjqCLaxej/nEQejm5x3L1

Berikut penjelasan fungsi Public Key dan Private Key:

| Properties | Layanan SNAP | Layanan Non-SNAP |
|------------|--------------|------------------|
| Private Key | Sebagai material yang akan digunakan dalam melakukan hashing HMAC untuk signature-auth. | (field ini tidak digunakan pada layanan Non-SNAP) |
| Public Key | Sebagai material yang digunakan oleh sistem Sandbox API BCA untuk compare signature-auth. | (field ini tidak digunakan pada layanan Non-SNAP) |

# 3. Mendapatkan Token

## 3.1 Mendapatkan Token pada Layanan SNAP

Untuk mendapatkan token pada layanan SNAP, Anda perlu generate signature asymmetric (signature-auth) terlebih dahulu. Silakan ikuti langkah berikut untuk mendapatkan token OAuth SNAP.

### 3.1.1 Membuat Signature-Auth SNAP

Berikut cara untuk membuat signature-auth layanan API SNAP

1) Buka Application yang sudah dibuat, lalu siapkan parameter key yang diperlukan untuk generate signature-auth dengan salin value Client ID dan Private Key di bawah ini.

2) Pilih layanan Utilities Signature SNAP pada kolom “Selected APIs” dan klik “Test”.

3) Tampil halaman fitur sandbox Open API Signature, pastikan pilih endpoint “/signature-auth” pada card.

# Utilities Signature SNAP

POST
/signature-auth

POST
/signature-service

| Parameter | Value | Description | Parameter Type | Data Type |
|-----------|-------|-------------|----------------|-----------|
| X-CLIENT-KEY | | | header | string |
| X-TIMESTAMP | | DateTime with timezone, which follows the ISO-8601 standard | header | string |
| Private_Key | | | header | string |

Send Request →

4) Input parameter yang sudah disiapkan dengan keterangan berikut :

| Parameter | Value |
|-----------|-------|
| X-CLIENT-KEY | Client ID |
| X-TIMESTAMP | Input timestamp dengan format : yyyy-MM-ddTHH:mm:ssTZD. Contoh: 2024-04-30T16:56:00+07:00 |
| Private key | Private Key |

Setelah input parameters silakan klik button “Send Request”.

# Utilities Signature SNAP

POST
/signature-auth

POST
/signature-service

| Parameter | Value | Description | Parameter Type | Data Type |
|-----------|-------|-------------|----------------|-----------|
| X-CLIENT-KEY | a9885d09-2e33-4815-a1 | | header | string |
| X-TIMESTAMP | 2024-04-30T17:00:00+07 | DateTime with timezone, which follows the ISO-8601 standard | header | string |
| Private_Key | -----BEGIN PRIVATE KEY--- | | header | string |

Send Request →

5) Tampil signature pada body response, silakan salin value field signature tersebut tanpa quotation marks/petik dua. Value signature-auth berikut akan digunakan ketika mendapatkan token OAuth SNAP. Silakan kembali ke halaman Sandbox View untuk mendapatkan token Oauth SNAP.

Send Request → Hide Response

Request URL
http://10.20.226.56:8022/api/v1/utilities/signature-auth

Response Body
{ "signature": "UxLzEOERwQqmcAjjr8RSWnaMcYIvoFBqRt/HivSjFxlcnwI09Vhpv8RIz218XAN1FWj/c8HrnCcaCmvtu5VJPSHw7SG10AMc0rdp8YerAdhgKWCdAr+q" }

Response Code
200

### 3.1.2 Mendapatkan Token Oauth SNAP

Berikut cara untuk mendapatkan token pada layanan API SNAP

1) Pada halaman Sandbox View, pilih layanan Utilities SNAP lalu klik “test”.

API yang dipilih • 7 selected
Utilities SNAP Test
Utilities Signature SNAP Test
Mutasi Rekening Test
Menyediakan akses mutasi rekening BCA.

2) Input parameter yang sudah disiapkan dengan keterangan berikut :

| Parameter | Value |
|-----------|-------|
| X-TIMESTAMP | Input timestamp dengan format : yyyy-MM-ddTHH:mm:ssTZD.<br><br>Gunakan value timestamp yang sama pada saat hit ‘signature-auth’.<br><br>Contoh:<br>2024-04-30T16:56:00+07:00 |

body Lihat di dokumentasi*

X-CLIENT-KEY Client ID

X-SIGNATURE Signature pada response Signature-Auth.

* Cara mendapatkan field “body” request token Oauth:
- Masuk ke halaman dokumentasi, lalu pilih section OAuth2.0 (SNAP).
- Salin value body pada contoh snipcode OAuth (SNAP).

3) Setelah input parameters pada tabel di atas, silakan klik button “Send Request”.

POST
/b2b

| Parameter | Value | Description | Parameter Type | Data Type |
|-----------|-------|-------------|----------------|-----------|
| X-TIMESTAMP | 2024-04-30T17:00:00+07 | | header | string |
| body | { "grantType": "client_credentials" } | Your JSON request | body | string |
| | | Parameter content type: application/json | | |
| X-CLIENT-KEY | a9885d09-2e33-4815-a1 | | header | string |
| X-SIGNATURE | fweaCmMcDrWaHKEX3T | | header | string |

Send Request →

4) Tampil response body berisi token, Silakan salin value field “access token” tersebut tanpa quotation marks/petik dua. Value token berikut akan digunakan ketika mendapatkan signature-service SNAP dan melakukan transaksi layanan API BCA berbasis SNAP.

Send Request → Hide Response

Request URL
http://10.20.226.56:8022/openapi/v1.0/access-token/b2b

Response Body
{
"responseCode": "2007300",
"responseMessage": "Successful",
"accessToken": "MajuiXSZ6PtrHAWYrZaNT1buDKBFCXW5XFKzCBz8wDxq36FoQF4ojV",
"tokenType": "Bearer",
"expiresIn": "899"
}

Response Code
200

## 3.2 Mendapatkan Token pada Layanan Non-SNAP

Berikut merupakan langkah – langkah untuk mendapatkan token layanan API non SNAP:

1) Buka Application yang sudah dibuat, lalu siapkan parameter key yang diperlukan untuk generate signature dengan salin value Client ID dan Client Secret.

2) Pilih layanan Utilities pada kolom “Selected APIs” dan klik “Test”.

3) Tampil halaman fitur sandbox Utilities dengan endpoint “/oauth/token”.

Utilities

POST
/oauth/token

POST /oauth/token
*required
| Parameter | Value | Description | Parameter Type | Data Type |
|-----------|-------|-------------|----------------|-----------|
| Content-Type | | | header | string |
| grant_type | | | formData | string |
| Authorization | | | header | string |

Send Request →

4) Input parameter yang sudah disiapkan dengan keterangan berikut :

| Parameter | Value |
|-----------|-------|
| Content-Type | Input dengan value: application/x-www-form-urlencoded |
| Grant_type | Input dengan value: client_credentials |
| Authorization | Input dengan format: Basic<spasi> base64(client_id:client_secret) |

*Encoding base64

Untuk melakukan encoding base64 value client_id dan client_secret dapat menggunakan tools online yang tersedia di internet. Input value client_id:client_secret pada field (sertakan tanda titik dua ‘:’ di antara value client_id dan client_secret saat encoding). Lalu klik ‘ENCODE’ untuk trigger encoding.

Tampil value encoded base64 Client_ID:Client_Secret, salin value encoded tersebut.

Y2Y3ZGM0YzltMDMyYS00OGVhLThmMmEtNDhkNGM0MzU4MTIxOmY5NGJhN2Y2LTgwMzAtNDBkMy1iMzliLTdkNjg0NzY4YzNzYmc==

5) Setelah input parameters pada tabel di atas, klik button “Send Request”

Utilities
API Catalogue

POST
/oauth/token

POST /oauth/token
*required

| Parameter | Value | Description | Parameter Type | Data Type |
|-----------|-------|-------------|----------------|-----------|
| Content-Type | application/x-www-form | header | string |
| grant_type | client_credentials | formData | string |
| Authorization | Basic Y2Y3ZGM0YzltMDM | header | string |

Send Request →

6) Tampil response body berisi token, Silakan salin value field access_token tersebut tanpa quotation marks/petik dua. Value token berikut akan digunakan untuk mendapatkan Utilities-Signature dan melakukan transaksi layanan API BCA.

Send Request →

Request URL
http://10.20.226.56:8022/api/oauth/token

Response Body
{
  "access_token": "Zjpjg8CEZhkxwAxHvZutwkoHku12pcmkXhq7EiKWgMiwO97F8fV0ne",
  "token_type": "Bearer",
  "expires_in": 3599,
  "scope": "resource.WRITE resource.READ"
}

Response Code
200

# 4. Melakukan Transaksi Layanan API di Sandbox API BCA

## 4.1 Melakukan Transaksi Layanan SNAP

Untuk melakukan transaksi/uji coba API pada layanan SNAP, Anda perlu melakukan generate signature symmetric (signature-service) terlebih dahulu. Silakan ikuti langkah berikut untuk dapat melakukan transaksi API SNAP pada Sandbox API BCA.

### 4.1.1 Membuat Signature-Service SNAP

1) Buka Application yang sudah dibuat, lalu siapkan parameter key yang diperlukan untuk generate signature-service dengan salin value Client Secret

2) Pilih layanan Utilities Signature SNAP pada kolom “Selected APIs” dan klik “Test”.

3) Tampil halaman fitur sandbox Utilities Signature SNAP, pastikan pilih endpoint “/signature-service”.

# Utilities Signature SNAP

POST /signature-service

| Parameter | Value | Description | Parameter Type | Data Type |
|-----------|-------|-------------|----------------|-----------|
| AccessToken | | | header | string |
| HttpMethod | | | header | string |
| X-TIMESTAMP | | Date Time with timezone, which follows the ISO-8601 standard | header | string |
| X-CLIENT-SECRET | | | header | string |
| body | | | body | string |

4) Input parameter yang sudah disiapkan dengan keterangan berikut :

| Parameter | Value |
|-----------|-------|
| AccessToken | Input value “access token” yang digenerate saat OAuth token sebelumnya |
| HttpMethod | Lihat pada dokumentasi* |
| X-TIMESTAMP | Input timestamp dengan format : yyyy-MM-ddTHH:mm:ssTZD.<br><br>Gunakan value timestamp yang sama pada saat hit signature-auth.<br><br>Contoh:<br>2024-04-30T16:56:00+07:00 |
| X-CLIENT-SECRET | Client Secret |
| body | Lihat pada dokumentasi* |
| EndpointUrl | Lihat pada dokumentasi* |

* Cara mendapatkan field “body” dan “EndpointUrl” request token Oauth:
Buka halaman Dokumentasi, lalu pilih layanan API yang ingin Anda uji coba. Salin value URL dan request body yang dibutuhkan untuk membuat signature-service sesuai keterangan pada gambar. Untuk request body, silakan salin dari dan hingga tanda kurung kurawal tanpa menggunakan tanda petik (''). Dalam contoh ini menggunakan layanan API SNAP Intrabank Transfer.

5) Setelah input parameters pada tabel di atas, klik button “Send Request”.

6) Tampil response body berisi signature-service, Silakan salin value field “signature” tersebut tanpa quotation marks/petik dua. Signature-service berikut akan digunakan untuk melakukan transaksi layanan API SNAP yang sudah Anda pilih.

Send Request → Hide Response

Request URL
http://10.20.226.56:8022/api/v1/utilities/signature-service

Response Body
{ "signature": "xqGYS0t0RGiTvTlEMOloyKLYf8Xywjb+Xt1XvAHFF+DqUda20TtHGwDjmdNZGg6MepbJgedzL8GEeYN70dfJRO==" }

Response Code
200

### 4.1.2 Membuat Request API SNAP

Setelah berhasil mendapatkan signature-service, silakan ikuti langkah berikut untuk dapat hit service API SNAP pada Sandbox API BCA:

1) Pada Application yang sama, pilih layanan API yang ingin Anda uji coba sesuai pada saat membuat signature-service. Dalam contoh ini menggunakan layanan API SNAP Intrabank Transfer.

API yang dipilih • 8 selected
Mutasi Rekening Test
Inquiry Status Transfer Test
Transfer Sesama BCA Test

2) Input parameter yang sudah disiapkan dengan keterangan berikut :

| Parameter | Value |
|-----------|-------|
| X-TIMESTAMP | Input timestamp dengan format : yyyy-MM-ddTHH:mm:ssTZD.<br><br>Gunakan value timestamp yang sama pada saat hit signature-auth.<br><br>Contoh:<br>2024-04-30T16:56:00+07:00 |
| body | Sama dengan request body saat generate signature-service. Data yang dibutuhkan pada body dapat dilihat pada dokumentasi masing masing layanan yang dicoba |
| X-PARTNER-ID | Lihat pada dokumentasi* |
| CHANNEL-ID | Lihat pada dokumentasi* |
| Authorization | Input Authorization dengan format :<br>“Bearer<spasi>{AccessToken}”<br><br>Contoh :<br>Bearer<br>ENDfQvUL9IPDUGNgodjiCyyUacvqjov31ivm... |
| X-SIGNATURE | signature-service yang di-generate sebelumnya |

* Ambil value Header pada layanan API yang sudah Anda pilih pada halaman dokumentasi di bagian snipcode. Salin sesuai Params yang akan digunakan. Dalam hal ini salin value CHANNEL-ID dan X-PARTNER-ID.

4. SNAP Banking Intrabank Transfer
This service is used to transfer BCA.

Additional Headers:

| Field | Params Type | Data Type | Length Type | Mandatory | Description |
|-------|-------------|-----------|-------------|-----------|-------------|
| CHANNEL-ID | Header | String(5) | Fixed | Y | Channel's identifier using WSID KlikBCA Bians (95051) |
| X-PARTNER-ID | Header | String(32) | Max | Y | Corporate ID |

Payload:

| Field | Data Type | Length Type | Mandatory | Format | Description |
|-------|-----------|-------------|-----------|--------|-------------|
| partnerReferenceNo | String (64) | Max | Y | - | Mandatory in BCA, Transaction identifier on service consumer system<br><br>For transfers that begin with beneficiary account number inquiry using the SNAP Banking Internal Account Inquiry, it is required to use the same partnerReferenceNo |

3) Setelah input parameter yang sudah disiapkan di keterangan tabel di atas klik “Send Request”.

Open API Transfer BCA

| Parameter | Value | Description | Parameter Type | Data Type |
|-----------|-------|-------------|----------------|-----------|
| X-TIMESTAMP | 2024-04-01T15:50:06+07 | header | string |
| body | "20201029000000000000001", "amount": { } | body | string |
| Parameter content type: | application/json | | |
| X-PARTNER-ID | KBBABCINDO | header | string |
| CHANNEL-ID | 95051 | channel identifier | header | string |
| Authorization | Bearer nWiA1C36cwxcl0 | header | string |
| X-SIGNATURE | rd8gdu8aEOPzU4MVYLh | header | string |

Send Request

4) Tampil response body dari layanan API SNAP yang Anda pilih. Pada step ini pengujian API SNAP pada Sandbox API BCA sudah berhasil.

Request URL
http://10.20.226.56:8022/openapi/v1.0/transfer-intrabank/

Response Body
{
  "responseCode": "2001700",
  "responseMessage": "Successful",
  "referenceNo": "202404010000000000001",
  "partnerReferenceNo": "202010290000000000001",
  "amount": {
    "value": "10000.00",
    "currency": "IDR"
  },
  "beneficiaryAccountNo": "888801000157508",
  "currency": "",
  "customerReference": "",
  "sourceAccountNo": "888801000157508",
  "transactionDate": "2020-12-21T10:30:24+07:00",
  "additionalInfo": {
    "beneficiaryEmail": "",
    "economicActivity": "Biaya Hidup Pihak Asing",
    "transactionPurpose": "01"
  }
}

Response Code
200

## 4.2 Melakukan Transaksi Layanan Non SNAP

Untuk melakukan transaksi/uji coba API pada layanan Non SNAP, Anda memerlukan generate utilities-signature terlebih dahulu. Silakan ikuti langkah berikut untuk dapat melakukan transaksi API Non SNAP pada Sandbox API BCA.

### 4.2.1 Membuat Signature pada Layanan Non SNAP

1) Buka Application yang sudah dibuat, lalu siapkan parameter key yang diperlukan untuk generate Utilities-Signature dengan salin value API Secret.

2) Pilih layanan Utilities-Signature pada kolom “Selected APIs” dan klik “Test”.

3) Tampil halaman untuk mendapatkan Utilities-Signature

Utilities-Signature

API Catalogue

| Parameter | Value | Description | Parameter Type | Data Type |
|-----------|-------|-------------|----------------|-----------|
| URI | | The endpoint of the API you want to access including all the query parameter(s) if any | header | string |
| Timestamp | | Your current timestamp in "yyyy-MM-ddTHH:mm:ss.SSSTZD" format. Same value as X-BCA-Timestamp | header | string |
| APISecret | | Your API Secret | header | string |
| HTTPMethod | | HTTP method for the intended API | header | string |
| RequestPayload | | Your JSON request. Leave it blank for GET request | body | string |
| Parameter content type: | application/json | | | |
| AccessToken | | Your valid access token | header | string |

4) Input parameter yang sudah disiapkan dengan keterangan berikut :

| Parameter | Value |
|-----------|-------|
| URI | Lihat pada dokumentasi* |
| Timestamp | Input timestamp dengan format : yyyy-MM-ddTHH:mm:ssTZD.<br/><br/>Contoh:<br/>2024-04-30T16:56:00+07:00 |
| APISecret | API_Secret |
| HTTPMethod | Lihat pada dokumentasi* |
| RequestPayload | Lihat pada dokumentasi* |
| AccessToken | AccessToken yang telah di-generate sebelumnya |

* Buka halaman dokumentasi lalu pilih layanan API non SNAP yang ingin Anda uji coba. Salin value yang dibutuhkan untuk membuat Utilities-Signature sesuai keterangan pada gambar. Untuk request body, silakan salin dari dan hingga tanda kurung kurawal tanpa menggunakan tanda petik (''). Dalam contoh ini menggunakan layanan FIRE Kiriman Uang ke Rekening Bank.

5) Setelah input parameter yang sudah disiapkan di keterangan tabel di atas klik “Send Request”.

6) Tampil response body berisi signature, Silakan salin value field “CalculatedHMAC”. Signature berikut akan digunakan untuk melakukan transaksi layanan API non SNAP yang sudah Anda pilih.

{
    "FormNumber": "7632605701245868",
    "HashedRequestPayload": "9781566e7029a50d5e69694d0b7acb09c6368275f8f6253e8ecd27e62eb05b2f",
    "SortedURI": "/fire/transactions/to-account",
    "CalculatedHMAC": "5f64dfa0fd275cfd27a684fca4893f9584a95f54030e830c5534e98b48e93059"
}

Response Code
200

### 4.2.2 Membuat Request API Non SNAP

1) Siapkan parameter key yang diperlukan untuk request API dengan salin value API Key.

API Keys
API Secret
API Key
bdcef2d4-5f42-4ae1-9005-ddd3b1c40102
Javascript Orighits
*
Description
21 Apr 2025, 15:44
API Secret
7a8e7cec-de3a-499c-8486-cda483f67b20

2) Pilih layanan API non SNAP yang sudah dipilih pada saat membuat Utilities-signature. Dalam contoh di bawah ini menggunakan layanan API Fire Kiriman Uang ke Rekening Bank.

API yang dipilih • 5 selected
Kiriman Uang ke Rekening Bank
layanan transfer dana ke rekening bank baik di BCA maupun bank lain
Test
Utilities Test
Utilities-Signature Test

3) Tampil halaman fitur Kiriman Uang ke Rekening Bank

Kiriman Uang ke Rekening Bank

POST
/

POST /
Parameter Value Description Parameter Type Data Type
*required
X-BCA-Timestamp header string
X-BCA-Signature header string
Authorization header string
X-BCA-Key header string
body body undefined

4) Input parameter yang sudah disiapkan dengan keterangan berikut :

| Parameter | Value |
|-----------|-------|
| X-BCA-Timestamp | Input timestamp dengan format : yyyy-MM-ddTHH:mm:ssTZD.<br>Gunakan value timestamp yang sama pada saat uji coba Utilities-Signature.<br>Contoh:<br>2024-04-30T16:56:00+07:00 |
| X-BCA-SIGNATURE | Input value “CalculatedHMAC” saat generate Utilities-Signature |
| Authorization | Gunakan format :<br>“Bearer<spasi>{AccessToken}”<br>AccessToken yang telah digenerate sebelumnya<br>Contoh :<br>Bearer ENDfQvUL9IPdjiCyyUacvqjovvbrcf31m.. |
| X-BCA-KEY | API_Key |
| body | Sama dengan request body saat generate utilities-signature |

5. Setelah input parameter yang sudah disiapkan pada keterangan tabel di atas, klik “Send Request”.

| Parameter | Value | Description | Parameter Type | Data Type |
|-----------|-------|-------------|----------------|-----------|
| X-BCA-Timestamp | 2024-05-06T10:20:00+07 | | header | string |
| X-BCA-Signature | 5f64dfa0fd275cfd27a684 | | header | string |
| Authorization | Bearer Y0FbGPUAHp7m | | header | string |
| X-BCA-Key | b934b68d-45ef-4846-a11 | | header | string |
| body | { "Authentication":{} } | | body | undefined |
| Parameter content type: | application/json | | | |

6. Tampil response body dari layanan API Non SNAP yang Anda pilih. Pada step ini pengujian API non SNAP pada Sandbox API BCA sudah berhasil.

Request URL
https://sandbox.bca.co.id/fire/transactions/to-account/

Response Body
{
"BeneficiaryDetails": {
"Name": "RAFI ZULFIKAR MUSTAQIM",
"AccountNumber": "0106666011",
"ServerBeneAccountName": "RAFI ZULFIKAR MUSTAQIM"
},
"TransactionDetails": {
"CurrencyID": "IDR",
"Amount": "100000",
"Description1": "",
"Description2": "",
"FormNumber": "56559859607940",
"ReferenceNumber": "IDPYID01000INA17030000057",
"ReleaseDateTime": "2024-05-17T19:49:19.348+07:00"
},
"StatusTransaction": "0000",
"StatusMessage": "Success"
}

Response Code
200