import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart'; // Import your main.dart for accessing MyApp class

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Locale _selectedLocale = const Locale('en', 'US'); // Default locale
  String _selectedTheme = 'system'; // Default theme is 'system' (based on OS)
  bool _notificationsEnabled = true; // Default notification setting

  @override
  void initState() {
    super.initState();
    _loadLocale(); // Load saved locale
    _loadTheme();  // Load saved theme
    _loadNotificationSettings(); // Load saved notification setting
  }

  // Load the saved locale from SharedPreferences
  Future<void> _loadLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString('languageCode');
    String? countryCode = prefs.getString('countryCode');
    if (languageCode != null && countryCode != null) {
      setState(() {
        _selectedLocale = Locale(languageCode, countryCode);
      });
    }
  }

  // Load the saved theme from SharedPreferences
  Future<void> _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? theme = prefs.getString('theme') ?? 'system'; // Default to 'system'
    setState(() {
      _selectedTheme = theme;
    });
  }

  // Load the saved notification setting from SharedPreferences
  Future<void> _loadNotificationSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? notifications = prefs.getBool('notificationsEnabled') ?? true;
    setState(() {
      _notificationsEnabled = notifications;
    });
  }

  // Save and change the language
  void _changeLanguage(Locale locale) async {
    setState(() {
      _selectedLocale = locale;
    });

    // Save the selected locale to SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);
    await prefs.setString('countryCode', locale.countryCode ?? '');

    // Change the locale dynamically
    context.setLocale(locale); // This will change the locale in the app at runtime
  }

  // Save and change the theme
  void _changeTheme(String theme) async {
    setState(() {
      _selectedTheme = theme;
    });

    // Save the selected theme to SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', theme);

    // Apply the selected theme dynamically
    _applyTheme(theme);
  }

  // Apply theme based on user selection
  void _applyTheme(String theme) {
    if (theme == 'dark') {
      MyApp.of(context)?.changeTheme(ThemeMode.dark);
    } else if (theme == 'light') {
      MyApp.of(context)?.changeTheme(ThemeMode.light);
    } else {
      MyApp.of(context)?.changeTheme(ThemeMode.system);
    }
  }

  // Toggle notification settings
  void _toggleNotifications(bool isEnabled) async {
    setState(() {
      _notificationsEnabled = isEnabled;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', isEnabled);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('settings'.tr()), // Localized app bar title
      ),
      body: ListView(
        children: [
          _buildSectionTitle('general'.tr()), // General Section
          _buildLanguageDropdown(),           // Language Selection Dropdown
           _buildThemeDropdown(),              // Theme Selection Dropdown
           _buildSectionTitle('notifications'.tr()), // Notifications Section
          _buildNotificationSettings(),
        ],
      ),
    );
  }

  // Build section title for different settings sections
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Build the language dropdown for selecting the app language
  Widget _buildLanguageDropdown() {
    return ListTile(
      title: Text('language'.tr()), // Localized text for 'Language'
      subtitle: DropdownButton<Locale>(
        value: _selectedLocale,
        onChanged: (Locale? newLocale) {
          if (newLocale != null) {
            _changeLanguage(newLocale);
          }
        },
        items: const [
          DropdownMenuItem(
            value: Locale('en', 'US'),
            child: Text('English'),
          ),
          DropdownMenuItem(
            value: Locale('fr', 'FR'),
            child: Text('Français'),
          ),
          DropdownMenuItem(
            value: Locale('ar', 'TN'),
            child: Text('العربية'),
          ),
        ],
      ),
    );
  }

  // Build the theme dropdown for selecting the app theme
  Widget _buildThemeDropdown() {
    return ListTile(
      title: Text('theme'.tr()), // Localized text for 'Theme'
      subtitle: DropdownButton<String>(
        value: _selectedTheme,
        onChanged: (String? newTheme) {
          if (newTheme != null) {
            _changeTheme(newTheme);
          }
        },
        items: const [
          DropdownMenuItem(
            value: 'system',
            child: Text('System Default'),
          ),
          DropdownMenuItem(
            value: 'light',
            child: Text('Light'),
          ),
          DropdownMenuItem(
            value: 'dark',
            child: Text('Dark'),
          ),
        ],
      ),
    );
  }

  // Placeholder for notification settings, you can add real functionality here
  Widget _buildNotificationSettings() {
    return SwitchListTile(
      title: Text('enableNotifications'.tr()), // Localized text for 'Enable Notifications'
      value: _notificationsEnabled,
      onChanged: (bool value) {
        _toggleNotifications(value);
      },
    );
  }
}
