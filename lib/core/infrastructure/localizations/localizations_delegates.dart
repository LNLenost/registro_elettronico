import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:timetable/timetable.dart';

import 'app_localizations.dart';

class LocalizationsDelegates {
  static LocalizationsDelegates? _instance;
  List<LocalizationsDelegate>? _localizationsDelegates;
  List<Locale>? _supportedLocales;
  Map<String, String>? _supportedLanguages;

  LocalizationsDelegates._() {
    _supportedLanguages = {'en': 'EN', 'it': 'IT', 'ru': 'RU'};
    _supportedLocales = [];
    _supportedLanguages!.forEach((languageCode, countryCode) {
      _supportedLocales!.add(Locale(languageCode, countryCode));
    });
    _localizationsDelegates = [
      // A class which loads the translations from JSON files
      AppLocalizations.delegate,
      // Built-in localization of basic text for Material widgets
      GlobalMaterialLocalizations.delegate,
      // Built-in localization for text direction LTR/RTL
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      TimetableLocalizationsDelegate(),
    ];
  }

  Locale? localeResolutionCallback(
      Locale? locale, Iterable<Locale>? supportedLocales) {
    // Match the device language even when its country is different.
    for (var supportedLocale in supportedLocales!) {
      if (supportedLocale.languageCode == locale?.languageCode) {
        return supportedLocale;
      }
    }
    // If the device language is unsupported, use English.
    return supportedLocales.first;
  }

  bool isSupported(Locale locale) {
    // Include all of your supported language codes here
    return _supportedLanguages!.keys.contains(locale.languageCode);
  }

  static LocalizationsDelegates? get instance {
    if (_instance == null) {
      _instance = LocalizationsDelegates._();
    }
    return _instance;
  }

  List<LocalizationsDelegate>? get localizationsDelegates =>
      _localizationsDelegates;

  List<Locale>? get supportedLocales => _supportedLocales;

  Map<String, String>? get supportedLanguages => _supportedLanguages;
}
