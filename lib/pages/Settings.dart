import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Locale _selectedLocale = const Locale('en', 'US'); // Default locale

  @override
  void initState() {
    super.initState();
    _loadLocale(); // Load saved locale
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
          const Divider(),
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


  // Placeholder for notification settings, you can add real functionality here
  Widget _buildNotificationSettings() {
    return SwitchListTile(
      title: Text('enableNotifications'.tr()), // Localized text for 'Enable Notifications'
      value: true, // This can be replaced with a real preference
      onChanged: (bool value) {
        // Handle notification setting here
      },
    );
  }
}
