import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/address.dart';
import '../shipping/shipping_screen.dart';

/// Edit Address Screen for editing shipping addresses
class EditAddressScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? extra;

  const EditAddressScreen({super.key, this.extra});

  @override
  ConsumerState<EditAddressScreen> createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends ConsumerState<EditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _postalCodeController;

  bool _showError = false;
  int? _addressIndex;

  @override
  void initState() {
    super.initState();
    final address = widget.extra?['address'] as Address?;
    _addressIndex = widget.extra?['index'] as int?;

    final nameParts = address?.fullName.split(' ') ?? ['', ''];
    _firstNameController = TextEditingController(text: nameParts.first);
    _lastNameController = TextEditingController(
      text: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '',
    );
    // Remove +62 prefix for editing
    final phone = address?.phone.replaceAll('+62 ', '') ?? '';
    _phoneController = TextEditingController(text: phone);
    _addressController = TextEditingController(text: address?.address ?? '');
    _cityController = TextEditingController(text: address?.city ?? '');
    _postalCodeController = TextEditingController(text: address?.postalCode ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  void _saveAddress() {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();
    final city = _cityController.text.trim();
    final postalCode = _postalCodeController.text.trim();

    if (firstName.isEmpty || phone.isEmpty || address.isEmpty || city.isEmpty) {
      setState(() => _showError = true);
      return;
    }

    setState(() => _showError = false);

    // Update the address in the provider
    if (_addressIndex != null) {
      final addresses = ref.read(addressesProvider);
      final oldAddress = addresses[_addressIndex!];

      final fullName = [firstName, lastName].where((s) => s.isNotEmpty).join(' ');

      final updatedAddress = oldAddress.copyWith(
        fullName: fullName,
        phone: '+62 $phone',
        address: address,
        city: city,
        postalCode: postalCode,
      );

      final newAddresses = List<Address>.from(addresses);
      newAddresses[_addressIndex!] = updatedAddress;

      ref.read(addressesProvider.notifier).state = newAddresses;
    }

    AppToast.show(
      context,
      'Alamat berhasil disimpan',
      isError: false,
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Edit Alamat',
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                // Name row
                Row(
                  children: [
                    Expanded(
                      child: _buildInputField(
                        label: 'Nama Depan',
                        controller: _firstNameController,
                        placeholder: 'Contoh: John',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInputField(
                        label: 'Nama Belakang',
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
                      child: _buildInputField(
                        label: l10n.city,
                        controller: _cityController,
                        placeholder: 'Jakarta Selatan',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInputField(
                        label: l10n.postalCode,
                        controller: _postalCodeController,
                        placeholder: '12920',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),

                // Error message
                if (_showError) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.mitsubishiRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 16,
                          color: AppColors.mitsubishiRed,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Harap isi semua field yang wajib diisi.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.mitsubishiRed,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(l10n),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String placeholder,
    TextInputType keyboardType = TextInputType.text,
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
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: const TextStyle(color: AppColors.textTertiary),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
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
              borderSide: const BorderSide(color: AppColors.mitsubishiRed),
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
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
                  hintStyle: const TextStyle(color: AppColors.textTertiary),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
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
                    borderSide: const BorderSide(color: AppColors.mitsubishiRed),
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
            hintStyle: const TextStyle(color: AppColors.textTertiary),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
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
              borderSide: const BorderSide(color: AppColors.mitsubishiRed),
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
            onPressed: _saveAddress,
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
                  'Simpan Perubahan',
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