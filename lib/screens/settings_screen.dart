import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/user_provider.dart';
import '../services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notifications30min = true;
  bool notifications10min = true;
  bool notificationsLive = true;
  bool customNotifyEnabled = false;
  int customNotifyHr = 0;
  int customNotifyMin = 0;
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      notifications30min = _prefs?.getBool('notifications30min') ?? true;
      notifications10min = _prefs?.getBool('notifications10min') ?? true;
      notificationsLive = _prefs?.getBool('notificationsLive') ?? true;
      customNotifyEnabled = (_prefs != null && _prefs!.containsKey('customNotifyEnabled')) ? _prefs!.getBool('customNotifyEnabled') ?? false : false;
      customNotifyHr = _prefs?.getInt('customNotifyHr') ?? 0;
      customNotifyMin = _prefs?.getInt('customNotifyMin') ?? 0;
    });
  }

  Future<void> _savePrefs() async {
    _prefs?.setInt('customNotifyHr', customNotifyHr);
    _prefs?.setInt('customNotifyMin', customNotifyMin);
    
    // Save notification settings to notification service
    await NotificationService().updateNotificationSettings(
      notify30min: notifications30min,
      notify10min: notifications10min,
      notifyLive: notificationsLive,
      notifyCustom: customNotifyEnabled,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;
    final userHandle = userProvider.userHandle;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 32), // Increased top padding to 48
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Customize your app experience',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          if (userHandle != null)
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 24),
              child: Row(
                children: [
                  Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(userHandle, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600)),
                      const Text('Current Codeforces handle', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
          const Text('Appearance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          Card(
            margin: const EdgeInsets.only(bottom: 16, top: 8),
            child: ListTile(
              leading: Icon(isDark ? Icons.nightlight : Icons.wb_sunny, color: Theme.of(context).colorScheme.primary),
              title: Text(isDark ? 'Dark Mode' : 'Light Mode'),
              subtitle: Text(isDark ? 'Switch to light theme' : 'Switch to dark theme'),
              trailing: Switch(
                value: isDark,
                onChanged: (_) => themeProvider.toggleTheme(),
              ),
              onTap: themeProvider.toggleTheme,
            ),
          ),
          const Text('Notifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          Card(
            margin: const EdgeInsets.only(bottom: 16, top: 8),
            child: Column(
              children: [
                SwitchListTile(
                  value: notifications30min,
                  onChanged: (v) => setState(() { notifications30min = v; _savePrefs(); }),
                  title: const Text('30 Minutes Before'),
                  subtitle: const Text('Get notified 30 minutes before contest'),
                  secondary: Icon(Icons.notifications, color: Theme.of(context).colorScheme.primary),
                ),
                SwitchListTile(
                  value: notifications10min,
                  onChanged: (v) => setState(() { notifications10min = v; _savePrefs(); }),
                  title: const Text('10 Minutes Before'),
                  subtitle: const Text('Get notified 10 minutes before contest'),
                  secondary: Icon(Icons.notifications_active, color: Theme.of(context).colorScheme.primary),
                ),
                SwitchListTile(
                  value: notificationsLive,
                  onChanged: (v) => setState(() { notificationsLive = v; _savePrefs(); }),
                  title: const Text('Live Notification'),
                  subtitle: const Text('Get notified when contest goes live'),
                  secondary: Icon(Icons.campaign, color: Theme.of(context).colorScheme.primary),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Custom Notification Timer', style: TextStyle(fontWeight: FontWeight.w600)),
                          Switch(
                            value: customNotifyEnabled,
                            onChanged: (v) => setState(() { customNotifyEnabled = v; _savePrefs(); }),
                          ),
                        ],
                      ),
                      if (customNotifyEnabled)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Hour picker
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Number box
                                  Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      customNotifyHr.toString().padLeft(2, '0'),
                                      style: TextStyle(fontSize: 32, color: Colors.grey[400], fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Up/down buttons
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 32,
                                        height: 32,
                                        child: OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            padding: EdgeInsets.zero,
                                          ),
                                          onPressed: () => setState(() { customNotifyHr = (customNotifyHr + 1) % 24; _savePrefs(); }),
                                          child: const Icon(Icons.keyboard_arrow_up, size: 18),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      SizedBox(
                                        width: 32,
                                        height: 32,
                                        child: OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            padding: EdgeInsets.zero,
                                          ),
                                          onPressed: () => setState(() { customNotifyHr = (customNotifyHr - 1) < 0 ? 23 : customNotifyHr - 1; _savePrefs(); }),
                                          child: const Icon(Icons.keyboard_arrow_down, size: 18),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 8),
                                  // 'hr' label
                                  Text('hr', style: TextStyle(fontSize: 24, color: Colors.grey[400], fontWeight: FontWeight.w400)),
                                ],
                              ),
                              const SizedBox(width: 24),
                              // Minute picker
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Number box
                                  Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      customNotifyMin.toString().padLeft(2, '0'),
                                      style: TextStyle(fontSize: 32, color: Colors.grey[400], fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Up/down buttons
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 32,
                                        height: 32,
                                        child: OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            padding: EdgeInsets.zero,
                                          ),
                                          onPressed: () => setState(() { customNotifyMin = (customNotifyMin + 1) % 60; _savePrefs(); }),
                                          child: const Icon(Icons.keyboard_arrow_up, size: 18),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      SizedBox(
                                        width: 32,
                                        height: 32,
                                        child: OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            padding: EdgeInsets.zero,
                                          ),
                                          onPressed: () => setState(() { customNotifyMin = (customNotifyMin - 1) < 0 ? 59 : customNotifyMin - 1; _savePrefs(); }),
                                          child: const Icon(Icons.keyboard_arrow_down, size: 18),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 8),
                                  // 'min' label
                                  Text('min', style: TextStyle(fontSize: 24, color: Colors.grey[400], fontWeight: FontWeight.w400)),
                                ],
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                // Test notification button removed
              ],
            ),
          ),
          const Text('Danger Zone', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          Card(
            margin: const EdgeInsets.only(top: 8),
            color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
            child: ListTile(
              leading: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
              title: const Text('Clear User Data'),
              subtitle: const Text('Remove your handle and stats from this device'),
              onTap: userProvider.clearUserData,
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: const [
                Icon(Icons.info_outline, color: Colors.grey),
                SizedBox(height: 8),
                Text('Version 1.0.0', style: TextStyle(fontSize: 14, color: Colors.grey)),
                SizedBox(height: 4),
                Text('Made by λambda', style: TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 