import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_toast.dart';
import '../../data/repositories/address_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/address_provider.dart';

class EditAddressScreen extends ConsumerStatefulWidget {
  final String? addressId;
  const EditAddressScreen({super.key, this.addressId});

  @override
  ConsumerState<EditAddressScreen> createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends ConsumerState<EditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _labelController;
  late final TextEditingController _recipientController;
  late final TextEditingController _phoneController;
  late final TextEditingController _streetController;
  late final TextEditingController _cityController;
  late final TextEditingController _provinceController;
  late final TextEditingController _postalCodeController;

  bool _setAsDefault = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController();
    _recipientController = TextEditingController();
    _phoneController = TextEditingController();
    _streetController = TextEditingController();
    _cityController = TextEditingController();
    _provinceController = TextEditingController();
    _postalCodeController = TextEditingController();

    if (widget.addressId != null) {
      final addresses = ref.read(addressListProvider).valueOrNull ?? [];
      final address = addresses.where((a) => a.id == widget.addressId).firstOrNull;
      if (address != null) {
        _labelController.text = address.label;
        _recipientController.text = address.recipient;
        _phoneController.text = address.phone;
        _streetController.text = address.street;
        _cityController.text = address.city;
        _provinceController.text = address.province;
        _postalCodeController.text = address.postalCode;
        _setAsDefault = address.isDefault;
      }
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _recipientController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.addressId != null;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final input = AddressInput(
        label: _labelController.text.trim(),
        recipient: _recipientController.text.trim(),
        phone: _phoneController.text.trim(),
        street: _streetController.text.trim(),
        city: _cityController.text.trim(),
        province: _provinceController.text.trim(),
        postalCode: _postalCodeController.text.trim(),
        isDefault: _setAsDefault,
      );

      final notifier = ref.read(addressNotifierProvider);
      if (_isEditing) {
        await notifier.updateAddress(widget.addressId!, input);
      } else {
        await notifier.createAddress(input);
      }

      if (mounted) {
        ref.invalidate(addressListProvider);
        AppToast.show(
          context,
          _isEditing ? 'Alamat berhasil disimpan' : 'Alamat berhasil ditambahkan',
          isError: false,
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(context, 'Gagal menyimpan alamat', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(_isEditing ? l10n.editAddress : l10n.addAddress),
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildField(
                  label: l10n.addressLabel,
                  controller: _labelController,
                  placeholder: 'Rumah, Kantor, dll',
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))],
                  validator: (v) => v == null || v.trim().isEmpty
                      ? l10n.fieldRequired(l10n.addressLabel)
                      : v.trim().length > 50
                          ? 'Maksimal 50 karakter'
                          : null,
                ),
                const SizedBox(height: 16),
                _buildField(
                  label: l10n.recipient,
                  controller: _recipientController,
                  placeholder: 'John Doe',
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))],
                  validator: (v) => v == null || v.trim().isEmpty
                      ? l10n.fieldRequired(l10n.recipient)
                      : v.trim().length > 100
                          ? 'Maksimal 100 karakter'
                          : null,
                ),
                const SizedBox(height: 16),
                _buildField(
                  label: l10n.phone,
                  controller: _phoneController,
                  placeholder: '081234567890 atau +6281234567890',
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d+ ]'))],
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return l10n.fieldRequired(l10n.phone);
                    }
                    final phone = v.trim();
                    final isValidPrefix = phone.startsWith('08') || phone.startsWith('+62');
                    final digitsOnly = phone.replaceAll(RegExp(r'\D'), '');
                    if (!isValidPrefix) return 'Mulai dengan 08 atau +62';
                    if (digitsOnly.length < 10 || digitsOnly.length > 15) return '10-15 digit';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildField(
                  label: l10n.addressFull,
                  controller: _streetController,
                  placeholder: 'Jl. Sudirman Kav. 28-30',
                  maxLines: 3,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s\.,/\-–—()]'))],
                  validator: (v) => v == null || v.trim().isEmpty
                      ? l10n.fieldRequired(l10n.addressFull)
                      : v.trim().length > 200
                          ? 'Maksimal 200 karakter'
                          : null,
                ),
                const SizedBox(height: 16),
                _buildField(
                  label: l10n.city,
                  controller: _cityController,
                  placeholder: 'Jakarta Selatan',
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))],
                  validator: (v) => v == null || v.trim().isEmpty
                      ? l10n.fieldRequired(l10n.city)
                      : null,
                ),
                const SizedBox(height: 16),
                _buildField(
                  label: l10n.province,
                  controller: _provinceController,
                  placeholder: 'DKI Jakarta',
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))],
                  validator: (v) => v == null || v.trim().isEmpty
                      ? l10n.fieldRequired(l10n.province)
                      : null,
                ),
                const SizedBox(height: 16),
                _buildField(
                  label: l10n.postalCode,
                  controller: _postalCodeController,
                  placeholder: '12920',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d]'))],
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return l10n.fieldRequired(l10n.postalCode);
                    }
                    if (!RegExp(r'^\d{5}$').hasMatch(v.trim())) return 'Harus 5 digit angka';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    l10n.setAsDefault,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  value: _setAsDefault,
                  activeTrackColor: AppColors.mitsubishiRed.withValues(alpha: 0.4),
                  activeThumbColor: AppColors.mitsubishiRed,
                  onChanged: (v) => setState(() => _setAsDefault = v),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withValues(alpha: 0.3) : const Color(0x1A000000),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mitsubishiRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          _isEditing ? l10n.saveChanges : l10n.save,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String placeholder,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          inputFormatters: inputFormatters,
          validator: validator,
          style: TextStyle(color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary),
            filled: true,
            fillColor: isDark ? AppColors.darkSurfaceVariant : Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.mitsubishiRed),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.error),
            ),
          ),
        ),
      ],
    );
  }
}
