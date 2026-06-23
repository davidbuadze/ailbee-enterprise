import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLocaleStorageKey = '__locale_key__';

class FFLocalizations {
  FFLocalizations(this.locale);

  final Locale locale;

  static FFLocalizations of(BuildContext context) =>
      Localizations.of<FFLocalizations>(context, FFLocalizations)!;

  static List<String> languages() => ['ka', 'en', 'ru'];

  static late SharedPreferences _prefs;
  static Future initialize() async =>
      _prefs = await SharedPreferences.getInstance();
  static Future storeLocale(String locale) =>
      _prefs.setString(_kLocaleStorageKey, locale);
  static Locale? getStoredLocale() {
    final locale = _prefs.getString(_kLocaleStorageKey);
    return locale != null && locale.isNotEmpty ? createLocale(locale) : null;
  }

  String get languageCode => locale.toString();
  String? get languageShortCode =>
      _languagesWithShortCode.contains(locale.toString())
          ? '${locale.toString()}_short'
          : null;
  int get languageIndex => languages().contains(languageCode)
      ? languages().indexOf(languageCode)
      : 0;

  String getText(String key) =>
      (kTranslationsMap[key] ?? {})[locale.toString()] ?? '';

  String getVariableText({
    String? kaText = '',
    String? enText = '',
    String? ruText = '',
  }) =>
      [kaText, enText, ruText][languageIndex] ?? '';

  static const Set<String> _languagesWithShortCode = {
    'ar',
    'az',
    'ca',
    'cs',
    'da',
    'de',
    'dv',
    'en',
    'es',
    'et',
    'fi',
    'fr',
    'gr',
    'he',
    'hi',
    'hu',
    'it',
    'km',
    'ku',
    'mn',
    'ms',
    'no',
    'pt',
    'ro',
    'ru',
    'rw',
    'sv',
    'th',
    'uk',
    'vi',
  };
}

/// Used if the locale is not supported by GlobalMaterialLocalizations.
class FallbackMaterialLocalizationDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const FallbackMaterialLocalizationDelegate();

  @override
  bool isSupported(Locale locale) => _isSupportedLocale(locale);

  @override
  Future<MaterialLocalizations> load(Locale locale) async =>
      SynchronousFuture<MaterialLocalizations>(
        const DefaultMaterialLocalizations(),
      );

  @override
  bool shouldReload(FallbackMaterialLocalizationDelegate old) => false;
}

/// Used if the locale is not supported by GlobalCupertinoLocalizations.
class FallbackCupertinoLocalizationDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalizationDelegate();

  @override
  bool isSupported(Locale locale) => _isSupportedLocale(locale);

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      SynchronousFuture<CupertinoLocalizations>(
        const DefaultCupertinoLocalizations(),
      );

  @override
  bool shouldReload(FallbackCupertinoLocalizationDelegate old) => false;
}

class FFLocalizationsDelegate extends LocalizationsDelegate<FFLocalizations> {
  const FFLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => _isSupportedLocale(locale);

  @override
  Future<FFLocalizations> load(Locale locale) =>
      SynchronousFuture<FFLocalizations>(FFLocalizations(locale));

  @override
  bool shouldReload(FFLocalizationsDelegate old) => false;
}

Locale createLocale(String language) => language.contains('_')
    ? Locale.fromSubtags(
        languageCode: language.split('_').first,
        scriptCode: language.split('_').last,
      )
    : Locale(language);

bool _isSupportedLocale(Locale locale) {
  final language = locale.toString();
  return FFLocalizations.languages().contains(
    language.endsWith('_')
        ? language.substring(0, language.length - 1)
        : language,
  );
}

final kTranslationsMap = <Map<String, Map<String, String>>>[
  // AuthPage
  {
    '5sou6g5w': {
      'ka': 'შესვლა',
      'en': '',
      'ru': '',
    },
    'gpdds4j9': {
      'ka': 'შეავსეთ ქვემოთ მოცემული ფორმა',
      'en': '',
      'ru': '',
    },
    'qjhs10lk': {
      'ka': 'ელ-ფოსტა',
      'en': '',
      'ru': '',
    },
    '7cepkvtz': {
      'ka': 'უსაფრთხო კოდი',
      'en': '',
      'ru': '',
    },
    'hp8ayfqo': {
      'ka': 'შესვლა',
      'en': '',
      'ru': '',
    },
    'ljbd85rj': {
      'ka': 'დაგავიწყდათ უსაფრთხოების კოდი?',
      'en': '',
      'ru': '',
    },
    'tuszxyzn': {
      'ka': 'შესასვლელად შეგიძლიათ გამოიყენოთ',
      'en': '',
      'ru': '',
    },
    'idclwh8d': {
      'ka': 'Google',
      'en': '',
      'ru': '',
    },
    'vbw43qbr': {
      'ka': 'Apple',
      'en': '',
      'ru': '',
    },
    'u9y9a6lu': {
      'ka': 'რეგისტრირება',
      'en': '',
      'ru': '',
    },
    'ipyoa6x9': {
      'ka': 'შეავსეთ ქვემოთ მოცემული ფორმა',
      'en': '',
      'ru': '',
    },
    'nl9mazli': {
      'ka': 'ელ-ფოსტა',
      'en': '',
      'ru': '',
    },
    '7ungalw3': {
      'ka': 'უსაფრთხო კოდი',
      'en': '',
      'ru': '',
    },
    'cush4ftd': {
      'ka': 'დაადასტურეთ კოდი',
      'en': '',
      'ru': '',
    },
    'r7v0pq1t': {
      'ka': 'ანგარიშის გახსნა',
      'en': '',
      'ru': '',
    },
    'qn7l4za3': {
      'ka': 'შეგიძლიათ რეგისტრირება ანგარიშით:',
      'en': '',
      'ru': '',
    },
    'ddxkyt6p': {
      'ka': 'Google',
      'en': '',
      'ru': '',
    },
    '5eugru47': {
      'ka': 'Apple',
      'en': '',
      'ru': '',
    },
    'w7r437pq': {
      'ka': 'Home',
      'en': '',
      'ru': '',
    },
  },
  // WiggetPage
  {
    '6n6zecbs': {
      'ka': 'Home',
      'en': '',
      'ru': '',
    },
  },
  // Miscellaneous
  {
    'fk0bthxm': {
      'ka': '',
      'en': '',
      'ru': '',
    },
    'yf896o7q': {
      'ka': '',
      'en': '',
      'ru': '',
    },
    'rakhbxc9': {
      'ka': '',
      'en': '',
      'ru': '',
    },
    'z8rduy3u': {
      'ka': '',
      'en': '',
      'ru': '',
    },
    'fi28mv3z': {
      'ka': '',
      'en': '',
      'ru': '',
    },
    'hmhv5jir': {
      'ka': '',
      'en': '',
      'ru': '',
    },
    '67t4wg5j': {
      'ka': '',
      'en': '',
      'ru': '',
    },
    'vd749m3g': {
      'ka': '',
      'en': '',
      'ru': '',
    },
    '1w431mmi': {
      'ka': '',
      'en': '',
      'ru': '',
    },
    '8k6t9k0n': {
      'ka': '',
      'en': '',
      'ru': '',
    },
    'zpcaz292': {
      'ka': '',
      'en': '',
      'ru': '',
    },
    'xerjonzn': {
      'ka': '',
      'en': '',
      'ru': '',
    },
    '7glbjplq': {
      'ka': '',
      'en': '',
      'ru': '',
    },
    '2qj0b7ts': {
      'ka': '',
      'en': '',
      'ru': '',
    },
    'nlqe3jz4': {
      'ka': '',
      'en': '',
      'ru': '',
    },
    '2wud2rv4': {
      'ka': '',
      'en': '',
      'ru': '',
    },
    '7halxf63': {
      'ka': '',
      'en': '',
      'ru': '',
    },
    'g7edngdg': {
      'ka': '',
      'en': '',
      'ru': '',
    },
    '3scg2pzf': {
      'ka': '',
      'en': '',
      'ru': '',
    },
    'l0571u69': {
      'ka': '',
      'en': '',
      'ru': '',
    },
    'cg27luoz': {
      'ka': '',
      'en': '',
      'ru': '',
    },
    't8riqz3s': {
      'ka': '',
      'en': '',
      'ru': '',
    },
    'ogzzqbyo': {
      'ka': '',
      'en': '',
      'ru': '',
    },
    'bmt75tja': {
      'ka': '',
      'en': '',
      'ru': '',
    },
    '4m7qls12': {
      'ka': '',
      'en': '',
      'ru': '',
    },
  },
].reduce((a, b) => a..addAll(b));
