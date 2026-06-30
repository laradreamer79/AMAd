import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/i18n/lang_provider.dart';
import '../../../core/widgets/app_header.dart';
import '../../account/providers/account_provider.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  bool _faceIdEnabled = false;

  void _confirmLogout(BuildContext context, LangProvider lang) {
    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: lang.direction,
        child: AlertDialog(
          backgroundColor: AppColors.card,
          title: Text(
            lang.t('logout_confirm_title'),
            style: const TextStyle(color: Colors.white),
          ),
          content: Text(
            lang.t('logout_confirm_desc'),
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                lang.t('cancel'),
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<AuthProvider>().lock();
              },
              child: Text(
                lang.t('logout'),
                style: const TextStyle(color: AppColors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LangProvider>();
    final account = context.watch<AccountProvider>();

    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          AppHeader(titleKey: 'profile'),
          Expanded(
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // بطاقة معلومات المستخدم
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'L',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Lara', style: AppTextStyles.cardTypeName),
                                const SizedBox(height: 4),
                                Text(
                                  lang.t('premium_user'),
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  account.accountNumber,
                                  style: AppTextStyles.cardTypeDesc,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    Text(
                      lang.t('settings'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Column(
                        children: [
                          _SettingsTile(
                            icon: Icons.language,
                            label: lang.t('language_setting'),
                            trailing: GestureDetector(
                              onTap: lang.toggle,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.inputFill,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Text(
                                  lang.isRTL ? 'العربية' : 'English',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const Divider(height: 1, color: AppColors.cardBorder),
                          _SettingsTile(
                            icon: Icons.notifications_outlined,
                            label: lang.t('notifications_setting'),
                            trailing: Switch(
                              value: _notificationsEnabled,
                              activeColor: AppColors.primary,
                              onChanged: (v) => setState(() => _notificationsEnabled = v),
                            ),
                          ),
                          const Divider(height: 1, color: AppColors.cardBorder),
                          _SettingsTile(
                            icon: Icons.fingerprint,
                            label: lang.t('face_id_setting'),
                            trailing: Switch(
                              value: _faceIdEnabled,
                              activeColor: AppColors.primary,
                              onChanged: (v) => setState(() => _faceIdEnabled = v),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _confirmLogout(context, lang),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.error.withOpacity(0.4)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.logout, color: AppColors.error, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              lang.t('logout'),
                              style: const TextStyle(
                                color: AppColors.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Center(
                      child: Text(
                        '${lang.t('app_version')} 1.0.0',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget trailing;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: AppTextStyles.value),
          ),
          trailing,
        ],
      ),
    );
  }
}
