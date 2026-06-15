import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/order.dart';
import '../../../models/payment_proof.dart';
import '../../../providers/order_provider.dart';
import '../../../providers/payment_provider.dart';
import '../../../providers/repository_providers.dart';
import '../../../shared/widgets/app_error_view.dart';
import '../payment_bank_options.dart';
import '../payment_proof_state.dart';

class BuktiTransferCard extends ConsumerStatefulWidget {
  const BuktiTransferCard({
    super.key,
    required this.order,
    required this.isDark,
    this.onUploadSuccess,
  });

  final Order order;
  final bool isDark;
  final VoidCallback? onUploadSuccess;

  @override
  ConsumerState<BuktiTransferCard> createState() => _BuktiTransferCardState();
}

class _BuktiTransferCardState extends ConsumerState<BuktiTransferCard> {
  final _customBankNameController = TextEditingController();
  final _accountNameController = TextEditingController();
  final _amountController = TextEditingController();
  final _picker = ImagePicker();

  File? _selectedImage;
  bool _isSubmitting = false;
  late String _selectedBankName;

  @override
  void initState() {
    super.initState();
    final proof = widget.order.paymentProof;
    final existingBankName = proof?.bankName ?? paymentBankOptions.first;
    _selectedBankName = paymentBankOptions.contains(existingBankName)
        ? existingBankName
        : paymentBankOther;
    _customBankNameController.text =
        paymentBankRequiresCustomName(_selectedBankName)
            ? existingBankName
            : '';
    _accountNameController.text = proof?.accountName ?? '';
    _amountController.text = CurrencyFormatter.formatEditable(
      widget.order.totalAmount.toString(),
    );
  }

  @override
  void dispose() {
    _customBankNameController.dispose();
    _accountNameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final viewState = resolvePaymentProofViewState(widget.order);
    final proof = widget.order.paymentProof;
    final canUpload = canUploadPaymentProof(widget.order);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.paymentUploadProof,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: widget.isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildStatusBanner(l10n, viewState, proof),
          if (proof != null) ...[
            const SizedBox(height: 12),
            _buildSummaryRows(l10n, proof),
          ],
          if (canUpload) ...[
            const SizedBox(height: 16),
            _buildImagePicker(l10n),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedBankName,
              items: paymentBankOptions
                  .map(
                    (bankName) => DropdownMenuItem<String>(
                      value: bankName,
                      child: Text(bankName),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _selectedBankName = value;
                  if (!paymentBankRequiresCustomName(value)) {
                    _customBankNameController.clear();
                  }
                });
              },
              decoration: InputDecoration(
                labelText: l10n.paymentBankName,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            if (paymentBankRequiresCustomName(_selectedBankName)) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _customBankNameController,
                decoration: InputDecoration(
                  labelText: l10n.paymentBankNameCustom,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _accountNameController,
              decoration: InputDecoration(
                labelText: l10n.paymentAccountName,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              readOnly: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
                const RupiahInputFormatter(),
              ],
              decoration: InputDecoration(
                labelText: l10n.paymentAmount,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitProof,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mitsubishiRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        viewState == PaymentProofViewState.rejected
                            ? l10n.paymentReupload
                            : l10n.paymentSubmitProof,
                      ),
              ),
            ),
          ],
          if (!canUpload && proof?.imageUrl.isNotEmpty == true) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                proof!.imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 120,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: widget.isDark
                        ? AppColors.darkSurfaceVariant
                        : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: widget.isDark
                        ? AppColors.darkTextTertiary
                        : AppColors.textTertiary,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBanner(
    AppLocalizations l10n,
    PaymentProofViewState viewState,
    PaymentProof? paymentProof,
  ) {
    Color backgroundColor;
    Color foregroundColor;
    IconData icon;
    String title;

    switch (viewState) {
      case PaymentProofViewState.pendingReview:
        backgroundColor = AppColors.warning.withValues(alpha: 0.12);
        foregroundColor = AppColors.warning;
        icon = Icons.hourglass_top_rounded;
        title = l10n.paymentProofPending;
        break;
      case PaymentProofViewState.approved:
        backgroundColor = AppColors.success.withValues(alpha: 0.12);
        foregroundColor = AppColors.success;
        icon = Icons.verified_rounded;
        title = l10n.paymentProofApproved;
        break;
      case PaymentProofViewState.rejected:
        backgroundColor = AppColors.mitsubishiRed.withValues(alpha: 0.1);
        foregroundColor = AppColors.mitsubishiRed;
        icon = Icons.error_outline_rounded;
        title = l10n.paymentProofRejectedReason(
          paymentProof?.rejectReason ?? '-',
        );
        break;
      case PaymentProofViewState.expired:
        backgroundColor = AppColors.mitsubishiRed.withValues(alpha: 0.1);
        foregroundColor = AppColors.mitsubishiRed;
        icon = Icons.timer_off_outlined;
        title = l10n.paymentTimeExpired;
        break;
      case PaymentProofViewState.uploadRequired:
        backgroundColor = AppColors.mitsubishiRed.withValues(alpha: 0.08);
        foregroundColor = AppColors.mitsubishiRed;
        icon = Icons.upload_file_outlined;
        title = l10n.paymentSubmitProof;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: foregroundColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: foregroundColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRows(AppLocalizations l10n, PaymentProof paymentProof) {
    return Column(
      children: [
        _buildInfoRow(l10n.paymentBankName, paymentProof.bankName),
        const SizedBox(height: 8),
        _buildInfoRow(l10n.paymentAccountName, paymentProof.accountName),
        const SizedBox(height: 8),
        _buildInfoRow(
          l10n.paymentAmount,
          CurrencyFormatter.format(paymentProof.amount),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: widget.isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: widget.isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePicker(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(l10n.paymentPickImage),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.photo_camera_outlined),
                label: Text(l10n.paymentTakePhoto),
              ),
            ),
          ],
        ),
        if (_selectedImage != null) ...[
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              _selectedImage!,
              height: 220,
              width: double.infinity,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final image = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1800,
    );

    if (image == null || !mounted) return;

    setState(() {
      _selectedImage = File(image.path);
    });
  }

  Future<void> _submitProof() async {
    final l10n = AppLocalizations.of(context);
    final bankName = paymentBankRequiresCustomName(_selectedBankName)
        ? _customBankNameController.text.trim()
        : _selectedBankName;
    final accountName = _accountNameController.text.trim();
    final amount = widget.order.totalAmount;

    if (_selectedImage == null ||
        bankName.isEmpty ||
        accountName.isEmpty ||
        amount <= 0) {
      AppToast.show(context, l10n.paymentFieldsRequired, isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ref.read(paymentProofRepositoryProvider).uploadProof(
            orderId: widget.order.id,
            imageFile: _selectedImage!,
            bankName: bankName,
            accountName: accountName,
            amount: amount,
          );

      ref.invalidate(paymentProvider(widget.order.id));
      ref.invalidate(orderDetailProvider(widget.order.id));

      if (!mounted) return;
      AppToast.show(context, l10n.paymentProofUploaded, isError: false);
      widget.onUploadSuccess?.call();
    } catch (e) {
      if (!mounted) return;
      AppToast.show(
        context,
        errorMessageFor(e, l10n.asErrorL10n),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
