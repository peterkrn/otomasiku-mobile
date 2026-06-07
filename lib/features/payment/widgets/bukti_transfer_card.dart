import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/payment_proof.dart';
import '../../../providers/repository_providers.dart';

class BuktiTransferCard extends ConsumerStatefulWidget {
  final String orderId;
  final int totalAmount;
  final PaymentProof? proof;
  final VoidCallback onUploaded;

  const BuktiTransferCard({
    super.key,
    required this.orderId,
    required this.totalAmount,
    required this.proof,
    required this.onUploaded,
  });

  @override
  ConsumerState<BuktiTransferCard> createState() => _BuktiTransferCardState();
}

class _BuktiTransferCardState extends ConsumerState<BuktiTransferCard> {
  final _bankNameController = TextEditingController();
  final _accountNameController = TextEditingController();
  File? _selectedImage;
  bool _isUploading = false;

  @override
  void dispose() {
    _bankNameController.dispose();
    _accountNameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, maxWidth: 1920, imageQuality: 85);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (_selectedImage == null) return;
    if (_bankNameController.text.trim().isEmpty || _accountNameController.text.trim().isEmpty) {
      AppToast.show(context, l10n.paymentFieldsRequired, isError: true);
      return;
    }

    setState(() => _isUploading = true);
    try {
      await ref.read(paymentProofRepositoryProvider).uploadProof(
        orderId: widget.orderId,
        imageFile: _selectedImage!,
        bankName: _bankNameController.text.trim(),
        accountName: _accountNameController.text.trim(),
        amount: widget.totalAmount,
      );
      if (mounted) {
        AppToast.show(context, l10n.paymentProofUploaded, isError: false);
        widget.onUploaded();
      }
    } catch (e) {
      if (mounted) AppToast.show(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final proof = widget.proof;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: proof == null || proof.isRejected ? _buildUploadForm(l10n, isDark, proof) : _buildStatus(l10n, isDark, proof),
    );
  }

  Widget _buildStatus(AppLocalizations l10n, bool isDark, PaymentProof proof) {
    final Color chipColor;
    final String label;
    final IconData icon;

    if (proof.isApproved) {
      chipColor = Colors.green;
      label = l10n.paymentProofApproved;
      icon = Icons.check_circle;
    } else {
      chipColor = Colors.orange;
      label = l10n.paymentProofPending;
      icon = Icons.hourglass_top;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: chipColor, size: 20),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: chipColor)),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(proof.imageUrl, height: 120, width: double.infinity, fit: BoxFit.cover),
        ),
        const SizedBox(height: 8),
        Text('${l10n.paymentBankName}: ${proof.bankName}', style: TextStyle(fontSize: 13, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
        Text('${l10n.paymentAccountName}: ${proof.accountName}', style: TextStyle(fontSize: 13, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
        Text('${l10n.paymentAmount}: ${CurrencyFormatter.format(proof.amount)}', style: TextStyle(fontSize: 13, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildUploadForm(AppLocalizations l10n, bool isDark, PaymentProof? rejectedProof) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.paymentUploadProof, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        if (rejectedProof != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.paymentProofRejectedReason(rejectedProof.rejectReason ?? '-'),
                    style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        // Image picker
        if (_selectedImage != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(_selectedImage!, height: 120, width: double.infinity, fit: BoxFit.cover),
          ),
          const SizedBox(height: 8),
        ],
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined, size: 18),
                label: Text(l10n.paymentPickImage, style: const TextStyle(fontSize: 13)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt_outlined, size: 18),
                label: Text(l10n.paymentTakePhoto, style: const TextStyle(fontSize: 13)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _bankNameController,
          decoration: InputDecoration(
            labelText: l10n.paymentBankName,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _accountNameController,
          decoration: InputDecoration(
            labelText: l10n.paymentAccountName,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _selectedImage != null && !_isUploading ? _submit : null,
            icon: _isUploading
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.upload_file),
            label: Text(rejectedProof != null ? l10n.paymentReupload : l10n.paymentSubmitProof),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mitsubishiRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }
}
