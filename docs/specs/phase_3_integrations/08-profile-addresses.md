# Spec 08 — Profile & Addresses: View/Edit Profile, Address CRUD

| Field | Value |
|-------|-------|
| **Phase** | 3 — Backend Integration |
| **Priority** | Medium |
| **Status** | ⬜ Draft |
| **Depends On** | 01, 02, 03 |
| **API Endpoints** | `GET /api/me`, `PATCH /api/me`, `GET /api/addresses`, `POST /api/addresses`, `PUT /api/addresses/:id`, `DELETE /api/addresses/:id` |

---

## Scope

Wire profile view/edit and address CRUD screens to real API. Replace dummy user and address data.

---

## Modified Files

```
lib/providers/auth_provider.dart      # Add profile state (already has auth state)
lib/features/profile/                 # Wire profile screen to real API
lib/features/addresses/               # Wire address screens to real API
```

---

## Acceptance Criteria

### AC-1: Profile screen shows real user data
```gherkin
Given the user navigates to the profile screen
When the screen loads
Then GET /api/me is called
And the screen shows: full name, email, company name, phone, avatar
And if avatarUrl is null, a default avatar placeholder is shown
```

### AC-2: Edit profile saves changes
```gherkin
Given the user is on the edit profile screen
When the user updates their name/phone/company and taps "Simpan"
Then PATCH /api/me is called with the changed fields only
On success:
  - Profile state is updated in authProvider
  - A snackbar shows "Profil berhasil diperbarui"
  - Navigate back to profile screen
On failure:
  - Show localized error
  - Stay on edit screen
```

### AC-3: Address list loads from API
```gherkin
Given the user navigates to the addresses screen
When the screen loads
Then GET /api/addresses is called
And all active addresses are displayed
And the default address has a "Utama" badge
And an "Tambah Alamat" button is visible
```

### AC-4: Add new address
```gherkin
Given the user taps "Tambah Alamat"
When the user fills in all required fields and taps "Simpan"
Then POST /api/addresses is called
On success:
  - Navigate back to address list
  - New address appears in the list
  - If isDefault = true, previous default is visually updated
On failure (VALIDATION_ERROR):
  - Show field-level errors from error.details
```

### AC-5: Edit address
```gherkin
Given the user taps "Edit" on an address
When the user modifies fields and taps "Simpan"
Then PUT /api/addresses/:id is called
On success: navigate back, list refreshes
```

### AC-6: Delete address
```gherkin
Given the user taps "Hapus" on an address
Then a confirmation dialog appears: "Hapus alamat ini?"
When the user confirms
Then DELETE /api/addresses/:id is called
And the address is removed from the list
If the deleted address was the default
Then no address is marked as default
```

### AC-7: Empty address state
```gherkin
Given the user has no saved addresses
When the address list loads
Then an empty state is shown: "Belum ada alamat tersimpan"
And a "Tambah Alamat" button is visible
```

---

## Provider Design

```dart
// Profile — part of authProvider state (already loaded on login)
// Refresh on profile screen open via ref.invalidate

final addressListProvider = FutureProvider.autoDispose<List<Address>>((ref) {
  return ref.read(addressRepositoryProvider).getAddresses();
});

// Address mutations — called directly from screens, invalidate addressListProvider on success
// createAddress(), updateAddress(), deleteAddress()
```

---

## Form Validation (client-side, before API call)

| Field | Rule |
|-------|------|
| Label | Required, max 50 chars |
| Recipient | Required, max 100 chars |
| Phone | Required, starts with 08 or +62, 10-15 digits |
| Street | Required, max 200 chars |
| City | Required |
| Province | Required |
| Postal Code | Required, exactly 5 digits |

---

## Verification Checklist

- [ ] Profile screen shows real data from GET /api/me
- [ ] Edit profile PATCH only sends changed fields
- [ ] Address list loads from API
- [ ] Add address → POST → list refreshes
- [ ] Edit address → PUT → list refreshes
- [ ] Delete address → confirmation dialog → DELETE → removed from list
- [ ] Empty address state shown correctly
- [ ] Client-side form validation before API call
- [ ] `dummy_user.dart` and `dummy_addresses.dart` no longer imported
- [ ] `flutter analyze` clean
