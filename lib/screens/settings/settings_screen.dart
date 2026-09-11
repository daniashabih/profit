import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/theme_provider.dart';
import '../../theme/app_colors.dart';
import '../../core/constants/app_constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedWeightUnit = 'kg';
  String _selectedHeightUnit = 'cm';
  String _selectedLanguage = 'English';
  bool _pushNotifications = true;
  bool _soundEffects = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProv = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account & Security
            _buildSectionTitle('ACCOUNT'),
            _buildSettingsCard(
              isDark,
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline_rounded, color: AppColors.primaryLime),
                  title: const Text('Account & Security', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  subtitle: Text(
                    'Email, password and active sessions',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Account settings managed securely by ProFit')),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Appearance
            _buildSectionTitle('APPEARANCE'),
            _buildSettingsCard(
              isDark,
              children: [
                SwitchListTile(
                  title: const Text(
                    'Appearance',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  subtitle: Text(
                    themeProv.isDarkMode ? 'Dark Mode (Electric Lime & Charcoal)' : 'Light Mode (Clean Bright)',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  secondary: const Icon(Icons.dark_mode_outlined, color: AppColors.primaryLime),
                  activeThumbColor: AppColors.primaryLime,
                  activeTrackColor: AppColors.primaryLime.withOpacity(0.4),
                  value: themeProv.isDarkMode,
                  onChanged: (val) => themeProv.toggleTheme(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Preferences (Language & Units)
            _buildSectionTitle('PREFERENCES'),
            _buildSettingsCard(
              isDark,
              children: [
                ListTile(
                  leading: const Icon(Icons.language_rounded, color: AppColors.primaryLime),
                  title: const Text('Language', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  trailing: DropdownButton<String>(
                    value: _selectedLanguage,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'English', child: Text('English')),
                      DropdownMenuItem(value: 'Urdu', child: Text('اردو (Urdu)')),
                      DropdownMenuItem(value: 'Spanish', child: Text('Español')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedLanguage = val);
                    },
                  ),
                ),
                Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ListTile(
                  leading: const Icon(Icons.straighten_rounded, color: AppColors.primaryLime),
                  title: const Text('Units', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  subtitle: Text(
                    '$_selectedWeightUnit, $_selectedHeightUnit',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButton<String>(
                        value: _selectedWeightUnit,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(value: 'kg', child: Text('kg')),
                          DropdownMenuItem(value: 'lbs', child: Text('lbs')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedWeightUnit = val);
                        },
                      ),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: _selectedHeightUnit,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(value: 'cm', child: Text('cm')),
                          DropdownMenuItem(value: 'ft', child: Text('ft')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedHeightUnit = val);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Notifications
            _buildSectionTitle('NOTIFICATIONS'),
            _buildSettingsCard(
              isDark,
              children: [
                SwitchListTile(
                  title: const Text('Push Notifications', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  subtitle: const Text('Workout reminders and trainer messages'),
                  secondary: const Icon(Icons.notifications_active_outlined, color: AppColors.primaryLime),
                  activeThumbColor: AppColors.primaryLime,
                  value: _pushNotifications,
                  onChanged: (val) => setState(() => _pushNotifications = val),
                ),
                Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                SwitchListTile(
                  title: const Text('Sound Effects', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  subtitle: const Text('Rest timer completion beeps'),
                  secondary: const Icon(Icons.volume_up_outlined, color: AppColors.primaryLime),
                  activeThumbColor: AppColors.primaryLime,
                  value: _soundEffects,
                  onChanged: (val) => setState(() => _soundEffects = val),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Privacy & Support
            _buildSectionTitle('LEGAL & SUPPORT'),
            _buildSettingsCard(
              isDark,
              children: [
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.primaryLime),
                  title: const Text('Privacy Policy', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                  onTap: () {},
                ),
                Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ListTile(
                  leading: const Icon(Icons.help_outline_rounded, color: AppColors.primaryLime),
                  title: const Text('Help & Support', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                  onTap: () {},
                ),
                Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ListTile(
                  leading: const Icon(Icons.info_outline_rounded, color: AppColors.primaryLime),
                  title: const Text('About ProFit', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  subtitle: Text(
                    'Version ${AppConstants.appVersion} • ProFit Fitness Ecosystem',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(bool isDark, {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(children: children),
    );
  }
}
