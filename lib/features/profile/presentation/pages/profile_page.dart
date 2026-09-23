import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fincontrol/features/auth/bloc/auth_bloc.dart';
import 'package:fincontrol/features/auth/bloc/auth_event.dart';
import 'package:fincontrol/features/auth/bloc/auth_state.dart';
import 'package:fincontrol/features/settings/bloc/theme_cubit.dart';
import 'package:fincontrol/features/settings/bloc/currency_cubit.dart';
import 'package:fincontrol/features/auth/data/repositories/auth_repository.dart';
import 'package:fincontrol/core/widgets/glass_container.dart';
import 'package:fincontrol/features/profile/presentation/pages/setup_pin_page.dart';
import 'package:fincontrol/l10n/app_localizations.dart';
import 'package:fincontrol/features/settings/bloc/language_cubit.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthRepository _authRepo = AuthRepository();
  bool _isUploadingProfilePic = false;

  Map<String, dynamic>? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authRepo.getUser();
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAndUploadImage() async {
    if (_isUploadingProfilePic || _user == null) return;

    setState(() {
      _isUploadingProfilePic = true;
    });

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        await _authRepo.uploadAvatar(pickedFile.path);
        // Reload user to get new avatar URL
        await _loadUser();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingProfilePic = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final mutedTextColor = Theme.of(context).textTheme.bodySmall?.color;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    String displayName = _user?['name'] ?? 'User Name';
    String email = _user?['email'] ?? 'No email provided';
    String uid = _user?['id']?.toString() ?? 'Unknown';
    if (uid.length > 8) uid = uid.substring(0, 8);

    String? photoUrl = _user?['photo_url'];
    if (photoUrl != null && !photoUrl.startsWith('http')) {
      photoUrl = '${_authRepo.baseUrl}$photoUrl';
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.profile,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<AuthBloc>().add(AuthLogoutRequested());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
                    foregroundColor: Colors.redAccent,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.logout, size: 20),
                  label: Text(l10n.logout),
                ),
              ],
            ),
            const SizedBox(height: 32),
            GlassContainer(
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: _isUploadingProfilePic ? null : _pickAndUploadImage,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context).colorScheme.primary,
                                image: photoUrl != null
                                    ? DecorationImage(
                                        image: NetworkImage(photoUrl),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: photoUrl == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Theme.of(context).scaffoldBackgroundColor,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            if (_isUploadingProfilePic)
                              const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'User Name',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: mutedTextColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              displayName,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Divider(color: textColor?.withValues(alpha: 0.1), thickness: 1.5),
                  const SizedBox(height: 24),
                  _buildDetailRow(context, l10n.username, email),
                  const SizedBox(height: 16),
                  _buildDetailRow(context, l10n.accountNo, uid),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionHeader(l10n.accountAndSecurity, textColor),
            GlassContainer(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildListTile(
                    icon: Icons.lock_outline,
                    iconColor: Colors.orangeAccent,
                    title: l10n.appLockPin,
                    subtitle: l10n.appLockPinDesc,
                    textColor: textColor,
                    mutedTextColor: mutedTextColor,
                    trailing: Icon(Icons.chevron_right, color: mutedTextColor),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SetupPinPage()),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            _buildSectionHeader(l10n.preferences, textColor),
            GlassContainer(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  BlocBuilder<CurrencyCubit, CurrencyState>(
                    builder: (context, currencyState) {
                      return _buildListTile(
                        icon: Icons.attach_money,
                        iconColor: Colors.blueAccent,
                        title: l10n.currency,
                        subtitle: l10n.changeBaseCurrency,
                        textColor: textColor,
                        mutedTextColor: mutedTextColor,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              currencyState.selectedCurrency,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.swap_horiz, color: mutedTextColor, size: 20),
                          ],
                        ),
                        onTap: () {
                          context.read<CurrencyCubit>().toggleCurrency();
                        },
                      );
                    },
                  ),
                  _buildDivider(textColor),
                  _buildListTile(
                    icon: Icons.language,
                    iconColor: Colors.lightBlueAccent,
                    title: l10n.language,
                    subtitle: l10n.changeAppLanguage,
                    textColor: textColor,
                    mutedTextColor: mutedTextColor,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('🇺🇸 EN', style: TextStyle(fontWeight: context.read<LanguageCubit>().state.languageCode == 'en' ? FontWeight.bold : FontWeight.normal, color: context.read<LanguageCubit>().state.languageCode == 'en' ? textColor : mutedTextColor)),
                        const SizedBox(width: 8),
                        Container(width: 1, height: 16, color: textColor?.withValues(alpha: 0.2)),
                        const SizedBox(width: 8),
                        Text('🇹🇭 ไทย', style: TextStyle(fontWeight: context.read<LanguageCubit>().state.languageCode == 'th' ? FontWeight.bold : FontWeight.normal, color: context.read<LanguageCubit>().state.languageCode == 'th' ? textColor : mutedTextColor)),
                      ],
                    ),
                    onTap: () {
                      final currentLang = context.read<LanguageCubit>().state.languageCode;
                      context.read<LanguageCubit>().changeLanguage(currentLang == 'en' ? 'th' : 'en');
                    },
                  ),
                  _buildDivider(textColor),
                  _buildListTile(
                    icon: Icons.dark_mode_outlined,
                    iconColor: Colors.deepPurpleAccent,
                    title: l10n.darkMode,
                    subtitle: l10n.darkModeDesc,
                    textColor: textColor,
                    mutedTextColor: mutedTextColor,
                    trailing: Switch(
                      value: isDarkMode,
                      onChanged: (val) {
                        context.read<ThemeCubit>().toggleTheme();
                      },
                      activeThumbColor: Theme.of(context).colorScheme.primary,
                      activeTrackColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            _buildSectionHeader(l10n.support, textColor),
            GlassContainer(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildListTile(
                    icon: Icons.help_outline,
                    iconColor: Colors.greenAccent,
                    title: l10n.helpCenter,
                    subtitle: l10n.getHelpAndSupport,
                    textColor: textColor,
                    mutedTextColor: mutedTextColor,
                    trailing: Icon(Icons.chevron_right, color: mutedTextColor),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Help Center coming soon!')),
                      );
                    },
                  ),
                  _buildDivider(textColor),
                  _buildListTile(
                    icon: Icons.privacy_tip_outlined,
                    iconColor: Colors.redAccent,
                    title: l10n.termsAndPrivacy,
                    subtitle: l10n.readOurPolicies,
                    textColor: textColor,
                    mutedTextColor: mutedTextColor,
                    trailing: Icon(Icons.chevron_right, color: mutedTextColor),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Terms & Privacy coming soon!')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }



  Widget _buildSectionHeader(String title, Color? textColor) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Color? textColor,
    required Color? mutedTextColor,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      leading: Padding(
        padding: const EdgeInsets.only(top: 2.0),
        child: Icon(icon, color: textColor, size: 28),
      ),
      title: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textColor),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: mutedTextColor),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _buildDivider(Color? textColor) {
    return Padding(
      padding: const EdgeInsets.only(left: 70, right: 20),
      child: Divider(color: textColor?.withValues(alpha: 0.1), height: 1, thickness: 1),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }
}
