import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class AppLocalization {
  static late Map<String, dynamic> _localizedStrings;
  static String? translate(String key) {
    return _localizedStrings[key];
  }

  // Static method to retrieve the current locale
  static Locale currentLocale(BuildContext context) {
    return Localizations.localeOf(context);
  }

  static Future<void> load(Locale locale) async {
    String jsonString =
        await rootBundle.loadString('lib/l10n/intl_${locale.languageCode}.arb');
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    _localizedStrings =
        jsonMap.map((key, value) => MapEntry(key, value.toString()));
  }

  static List<Locale> get supportedLocales {
    return [
      const Locale('en', 'US'), // English
      const Locale('fr', 'FR'), // French
      const Locale('ar', 'TN'), // Arabic
      // Add more supported locales as needed
    ];
  }

  // Define a delegate for the AppLocalization class
  static const LocalizationsDelegate<AppLocalization> delegate =
      _AppLocalizationDelegate();
}

// Delegate class to be used by MaterialApp
class _AppLocalizationDelegate extends LocalizationsDelegate<AppLocalization> {
  const _AppLocalizationDelegate();

  @override
  bool isSupported(Locale locale) {
    // Include supported locales here if needed
    return ['en', 'fr', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalization> load(Locale locale) async {
    AppLocalization localization = AppLocalization();
    await AppLocalization.load(locale);

    return localization;
  }

  @override
  bool shouldReload(_AppLocalizationDelegate old) => false;
}
