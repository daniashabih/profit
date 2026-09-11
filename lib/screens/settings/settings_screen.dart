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
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section: Appearance
            _buildSectionTitle('APPEARANCE'),
            _buildSettingsCard(
              isDark,
              children: [
                SwitchListTile(
                  title: const Text(
                    'Dark Mode',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  subtitle: Text(
                    themeProv.isDarkMode ? 'Deep charcoal aesthetic' : 'Bright clean aesthetic',
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

            // Section: Units & Preferences
            _buildSectionTitle('UNITS & MEASUREMENTS'),
            _buildSettingsCard(
              isDark,
              children: [
                ListTile(
                  leading: const Icon(Icons.straighten_rounded, color: AppColors.primaryLime),
                  title: const Text('Weight Unit', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  trailing: DropdownButton<String>(
                    value: _selectedWeightUnit,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'kg', child: Text('Kilograms (kg)')),
                      DropdownMenuItem(value: 'lbs', child: Text('Pounds (lbs)')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedWeightUnit = val);
                    },
                  ),
                ),
                Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ListTile(
                  leading: const Icon(Icons.height_rounded, color: AppColors.primaryLime),
                  title: const Text('Height Unit', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  trailing: DropdownButton<String>(
                    value: _selectedHeightUnit,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'cm', child: Text('Centimeters (cm)')),
                      DropdownMenuItem(value: 'ft', child: Text('Feet & Inches (ft)')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedHeightUnit = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Section: Notifications
            _buildSectionTitle('NOTIFICATIONS'),
            _buildSettingsCard(
              isDark,
              children: [
                SwitchListTile(
                  title: const Text('Push Reminders', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  subtitle: const Text('Daily workout & nutrition alert'),
                  secondary: const Icon(Icons.notifications_active_outlined, color: AppColors.primaryLime),
                  activeThumbColor: AppColors.primaryLime,
                  value: _pushNotifications,
                  onChanged: (val) => setState(() => _pushNotifications = val),
                ),
                Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                SwitchListTile(
                  title: const Text('Rest Timer Sound', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  subtitle: const Text('Beep when set rest timer completes'),
                  secondary: const Icon(Icons.volume_up_outlined, color: AppColors.primaryLime),
                  activeThumbColor: AppColors.primaryLime,
                  value: _soundEffects,
                  onChanged: (val) => setState(() => _soundEffects = val),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Section: Security & Privacy
            _buildSectionTitle('ACCOUNT & PRIVACY'),
            _buildSettingsCard(
              isDark,
              children: [
                ListTile(
                  leading: const Icon(Icons.lock_outline_rounded, color: AppColors.primaryLime),
                  title: const Text('Change Password', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password reset instructions sent to your email')),
                    );
                  },
                ),
                Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ListTile(
                  leading: const Icon(Icons.security_rounded, color: AppColors.primaryLime),
                  title: const Text('Privacy Policy', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                  onTap: () {},
                ),
                Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ListTile(
                  leading: const Icon(Icons.help_outline_rounded, color: AppColors.primaryLime),
                  title: const Text('Help & Support', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Section: About
            _buildSectionTitle('ABOUT'),
            _buildSettingsCard(
              isDark,
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline_rounded, color: AppColors.primaryLime),
                  title: const Text('About FitFlow', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  subtitle: Text(
                    'Version ${AppConstants.appVersion} • Production Build',
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
