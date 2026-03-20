import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../l10n/app_localizations.dart';
import '../../../data/dummy/dummy_addresses.dart';
import '../../../models/address.dart';

/// State provider for addresses
final addressesProvider = StateProvider<List<Address>>((ref) {
  return List.from(dummyAddresses);
});

/// Selected address index provider
final selectedAddressProvider = StateProvider<int>((ref) {
  final addresses = ref.watch(addressesProvider);
  final defaultIndex = addresses.indexWhere((a) => a.isDefault);
  return defaultIndex >= 0 ? defaultIndex : 0;
});

/// Shipping Address Screen - Select, add, or edit addresses
class ShippingScreen extends ConsumerStatefulWidget {
  final bool isSelectable;

  const ShippingScreen({super.key, this.isSelectable = true});

  @override
  ConsumerState<ShippingScreen> createState() => _ShippingScreenState();
}

class _ShippingScreenState extends ConsumerState<ShippingScreen> {
  // Form controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _kecamatanController = TextEditingController();
  final _kelurahanController = TextEditingController();
  final _notesController = TextEditingController();

  bool _showFormError = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _kecamatanController.dispose();
    _kelurahanController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _selectAddress(int index) {
    ref.read(selectedAddressProvider.notifier).state = index;
  }

  void _goToEdit(int index) {
    final addresses = ref.read(addressesProvider);
    if (index >= 0 && index < addresses.length) {
      context.pushNamed(
        AppRoute.editAddress,
        extra: {'address': addresses[index], 'index': index},
      );
    }
  }

  void _saveNewAddress() {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();
    final city = _cityController.text.trim();
    final postalCode = _postalCodeController.text.trim();
    final kecamatan = _kecamatanController.text.trim();
    final kelurahan = _kelurahanController.text.trim();
    final notes = _notesController.text.trim();

    // Check if form has any data
    if (firstName.isEmpty && phone.isEmpty && address.isEmpty && city.isEmpty) {
      return;
    }

    // Validate required fields
    if (firstName.isEmpty || phone.isEmpty || address.isEmpty || city.isEmpty) {
      setState(() => _showFormError = true);
      return;
    }

    setState(() => _showFormError = false);

    // Create new address
    final fullName = [firstName, lastName].where((s) => s.isNotEmpty).join(' ');
    final newAddress = Address(
      id: 'addr-${DateTime.now().millisecondsSinceEpoch}',
      name: 'Alamat Baru',
      fullName: fullName,
      phone: '+62 $phone',
      address: address,
      city: city,
      province: 'DKI Jakarta',
      postalCode: postalCode,
      kecamatan: kecamatan.isNotEmpty ? kecamatan : null,
      kelurahan: kelurahan.isNotEmpty ? kelurahan : null,
      notes: notes.isNotEmpty ? notes : null,
      isDefault: false,
    );

    // Add to list
    final addresses = ref.read(addressesProvider.notifier);
    addresses.state = [...addresses.state, newAddress];

    // Select new address
    ref.read(selectedAddressProvider.notifier).state = addresses.state.length - 1;

    // Clear form
    _clearForm();

    AppToast.show(context, 'Alamat berhasil ditambahkan', isError: false);
  }

  void _clearForm() {
    _firstNameController.clear();
    _lastNameController.clear();
    _phoneController.clear();
    _addressController.clear();
    _cityController.clear();
    _postalCodeController.clear();
    _kecamatanController.clear();
    _kelurahanController.clear();
    _notesController.clear();
    setState(() => _showFormError = false);
  }

  void _useSelectedAddress() {
    final selected = ref.read(selectedAddressProvider);
    final addresses = ref.read(addressesProvider);
    if (selected >= 0 && selected < addresses.length) {
      // Pop with selected address info
      context.pop(addresses[selected]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final addresses = ref.watch(addressesProvider);
    final selectedIndex = ref.watch(selectedAddressProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(
          l10n.shippingAddress,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Saved addresses section
            Text(
              l10n.selectAddress,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...addresses.asMap().entries.map((entry) {
              final index = entry.key;
              final address = entry.value;
              final isSelected = index == selectedIndex;
              return _buildAddressCard(address, index, isSelected, l10n);
            }),

            const SizedBox(height: 24),

            // Divider
            Row(
              children: [
                const Expanded(child: Divider(color: AppColors.border)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'ATAU TAMBAH BARU',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
                const Expanded(child: Divider(color: AppColors.border)),
              ],
            ),

            const SizedBox(height: 24),

            // Add new address form
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.addNewAddress,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Name row
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: l10n.firstName,
                          controller: _firstNameController,
                          placeholder: 'Contoh: John',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          label: l10n.lastName,
                          controller: _lastNameController,
                          placeholder: 'Contoh: Doe',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Phone
                  _buildPhoneField(l10n),
                  const SizedBox(height: 16),

                  // Address
                  _buildTextAreaField(
                    label: l10n.addressFull,
                    controller: _addressController,
                    placeholder: 'Jl. Sudirman Kav. 28-30',
                  ),
                  const SizedBox(height: 16),

                  // City & Postal Code
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: l10n.city,
                          controller: _cityController,
                          placeholder: 'Jakarta Selatan',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          label: l10n.postalCode,
                          controller: _postalCodeController,
                          placeholder: '12920',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Kecamatan & Kelurahan
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: l10n.kecamatan,
                          controller: _kecamatanController,
                          placeholder: 'Setiabudi',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          label: l10n.kelurahan,
                          controller: _kelurahanController,
                          placeholder: 'Karet',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Notes
                  _buildTextField(
                    label: l10n.deliveryNotes,
                    controller: _notesController,
                    placeholder: 'Contoh: Titip di pos satpam',
                    isOptional: true,
                    optionalLabel: l10n.optional,
                  ),

                  // Error message
                  if (_showFormError) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.mitsubishiRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, size: 16, color: AppColors.mitsubishiRed),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l10n.fillRequiredFields,
                              style: TextStyle(fontSize: 12, color: AppColors.mitsubishiRed),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 100), // Space for bottom bar
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(l10n),
    );
  }

  Widget _buildAddressCard(
    Address address,
    int index,
    bool isSelected,
    AppLocalizations l10n,
  ) {
    return GestureDetector(
      onTap: () => _selectAddress(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.mitsubishiRed : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Radio circle
            Container(
              width: 20,
              height: 20,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.mitsubishiRed : AppColors.border,
                  width: isSelected ? 5 : 2,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Address info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        address.fullName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (address.isDefault) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDBEAFE),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            l10n.primary,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1D4ED8),
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      GestureDetector(
                        onTap: () => _goToEdit(index),
                        child: Text(
                          l10n.edit,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.mitsubishiRed,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address.phone,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${address.company ?? ''}\n${address.address}, ${address.city}, ${address.postalCode}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String placeholder,
    TextInputType keyboardType = TextInputType.text,
    bool isOptional = false,
    String optionalLabel = 'opsional',
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isOptional ? '$label ($optionalLabel)' : label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 14),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.mitsubishiRed, width: 1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.phone,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                border: Border.all(color: AppColors.border),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
              child: const Text(
                '+62',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            Expanded(
              child: TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: '812 3456 7890',
                  hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 14),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                    borderSide: const BorderSide(color: AppColors.mitsubishiRed, width: 1),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextAreaField({
    required String label,
    required TextEditingController controller,
    required String placeholder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 14),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.mitsubishiRed, width: 1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: widget.isSelectable ? _useSelectedAddress : _saveNewAddress,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mitsubishiRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check, size: 18),
                const SizedBox(width: 8),
                Text(
                  widget.isSelectable ? l10n.useAddress : l10n.saveAddress,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}