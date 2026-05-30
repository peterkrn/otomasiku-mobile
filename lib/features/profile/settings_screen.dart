import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../../core/constants/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/locale_provider.dart';

/// Settings screen with theme, language, and edit profile
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _nameController;
  bool _isEditingProfile = false;

  @override
  void initState() {
    super.initState();
    final auth = ref.read(authProvider);
    _nameController = TextEditingController(text: auth.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentLocale = ref.watch(localeProvider);
    final authState = ref.watch(authProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: Text(l10n.settings),
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(l10n.editProfile, isDark),
            const SizedBox(height: 8),
            _buildProfileSection(authState, isDark, l10n),
            const SizedBox(height: 24),

            _buildSectionTitle(l10n.appearance, isDark),
            const SizedBox(height: 8),
            _buildAppearanceSection(isDark, currentLocale, l10n),
            const SizedBox(height: 24),

            _buildSectionTitle(l10n.security, isDark),
            const SizedBox(height: 8),
            _buildPasswordSection(authState, isDark, l10n),
            const SizedBox(height: 96),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
      ),
    );
  }

  Widget _buildProfileSection(AuthState authState, bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: Column(
        children: [
          // Avatar
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.mitsubishiRed,
                  child: Text(
                    _getInitials(authState.name ?? 'U'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.uploadPhotoSoon)),
                      );
                    },
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.mitsubishiRed,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Name field
          TextField(
            controller: _nameController,
            enabled: _isEditingProfile,
            style: TextStyle(color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
            decoration: InputDecoration(
              labelText: l10n.name,
              labelStyle: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Email (read-only)
          TextField(
            controller: TextEditingController(text: authState.email ?? ''),
            enabled: false,
            style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
            decoration: InputDecoration(
              labelText: l10n.email,
              labelStyle: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Edit/Save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                if (_isEditingProfile) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.profileSaved)),
                  );
                }
                setState(() => _isEditingProfile = !_isEditingProfile);
              },
              icon: Icon(_isEditingProfile ? Icons.save : Icons.edit, size: 16),
              label: Text(_isEditingProfile ? l10n.save : l10n.editProfile),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isEditingProfile ? AppColors.success : AppColors.mitsubishiRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordSection(AuthState authState, bool isDark, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: isDark ? 0.2 : 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_outline, color: Colors.orange, size: 20),
            ),
            title: Text(
              l10n.changePassword,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              l10n.changePasswordSubtitle,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showChangePasswordDialog(isDark, l10n),
          ),
          Divider(height: 1, indent: 72, color: isDark ? AppColors.darkBorder : AppColors.border),
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: isDark ? 0.2 : 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.email_outlined, color: Colors.red, size: 20),
            ),
            title: Text(
              l10n.resetPasswordViaEmail,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              l10n.resetPasswordSubtitle(authState.email ?? ''),
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _sendResetEmail(authState.email, l10n),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(bool isDark, AppLocalizations l10n) {
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();
    bool obscureNew = true;
    bool obscureConfirm = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.mitsubishiRed.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_outline, color: AppColors.mitsubishiRed, size: 24),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.changePassword,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: newPassController,
                  obscureText: obscureNew,
                  decoration: InputDecoration(
                    labelText: l10n.newPassword,
                    labelStyle: TextStyle(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.mitsubishiRed, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureNew ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
                        size: 20,
                      ),
                      onPressed: () => setDialogState(() => obscureNew = !obscureNew),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPassController,
                  obscureText: obscureConfirm,
                  decoration: InputDecoration(
                    labelText: l10n.confirmPassword,
                    labelStyle: TextStyle(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.mitsubishiRed, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
                        size: 20,
                      ),
                      onPressed: () => setDialogState(() => obscureConfirm = !obscureConfirm),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
                        ),
                        child: Text(l10n.cancel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final newPass = newPassController.text;
                          final confirmPass = confirmPassController.text;
                          if (newPass.length < 8) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.passwordMinChars)),
                            );
                            return;
                          }
                          if (newPass != confirmPass) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.passwordMismatch)),
                            );
                            return;
                          }
                          Navigator.pop(ctx);
                          try {
                            await Supabase.instance.client.auth.updateUser(
                              UserAttributes(password: newPass),
                            );
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.passwordChanged),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            }
                          } on AuthException catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.message), backgroundColor: AppColors.mitsubishiRed),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mitsubishiRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: Text(l10n.save, style: const TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _sendResetEmail(String? email, AppLocalizations l10n) async {
    if (email == null || email.isEmpty) return;
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.otomasiku.app://login-callback',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.resetLinkSent(email)),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: AppColors.mitsubishiRed),
        );
      }
    }
  }

  Widget _buildAppearanceSection(bool isDark, Locale currentLocale, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: Column(
        children: [
          // Theme toggle
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.indigo.withValues(alpha: isDark ? 0.2 : 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(isDark ? Icons.dark_mode : Icons.light_mode, color: Colors.indigo, size: 20),
            ),
            title: Text(
              l10n.darkMode,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            trailing: Switch(
              value: isDark,
              onChanged: (_) => ref.read(themeProvider.notifier).toggleTheme(),
              activeTrackColor: AppColors.mitsubishiRed,
            ),
          ),
          Divider(height: 1, indent: 72, color: isDark ? AppColors.darkBorder : AppColors.border),
          // Language
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.teal.withValues(alpha: isDark ? 0.2 : 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.language, color: Colors.teal, size: 20),
            ),
            title: Text(
              l10n.language,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            trailing: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'id', label: Text('ID')),
                ButtonSegment(value: 'en', label: Text('EN')),
              ],
              selected: {currentLocale.languageCode},
              onSelectionChanged: (selected) {
                ref.read(localeProvider.notifier).setLocale(selected.first);
              },
              style: const ButtonStyle(visualDensity: VisualDensity.compact),
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }
}
