import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util/AppLocalization.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late Locale _selectedLocale;

  @override
  void initState() {
    super.initState();
    // Initialize the selected locale with the current locale
    _selectedLocale = AppLocalization.currentLocale(context);
  }

  // Function to handle language change
  void _changeLanguage(Locale locale) async {
    setState(() {
      _selectedLocale = locale; // Update the selected locale
    });
    // Save the selected locale to SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);
    // Force the app to rebuild with the new locale
    AppLocalization.load(locale);
    setState(() {}); // Rebuild the UI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('English'),
            onTap: () => _changeLanguage(const Locale('en', 'US')),
            selected: _selectedLocale.languageCode == 'en',
          ),
          ListTile(
            title: const Text('French'),
            onTap: () => _changeLanguage(const Locale('fr', 'FR')),
            selected: _selectedLocale.languageCode == 'fr',
          ),
          ListTile(
            title: const Text('Arabic'),
            onTap: () => _changeLanguage(const Locale('ar', 'DZ')),
            selected: _selectedLocale.languageCode == 'ar',
          ),
        ],
      ),
    );
  }
}
