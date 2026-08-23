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
    'umpx6ba8': {
      'ka': 'ᲡᲘᲡᲢᲔᲛᲐᲨᲘ ᲨᲔᲓᲘᲗ ᲘᲛᲐᲕᲔ ᲐᲜᲒᲐᲠᲘᲨᲘᲗ\nᲠᲝᲛᲔᲚᲘᲪ ᲠᲔᲒᲘᲡᲢᲠᲐᲪᲘᲘᲡᲐᲡ ᲨᲔᲐᲕᲡᲔᲗ',
      'en': '',
      'ru': '',
    },
    'tr31er5q': {
      'ka': 'ელ-ფოსტა',
      'en': '',
      'ru': '',
    },
    'mzy5tpt0': {
      'ka': 'უსაფრთხო კოდი',
      'en': '',
      'ru': '',
    },
    '008m2dsh': {
      'ka': 'შესვლა',
      'en': '',
      'ru': '',
    },
    '0efuy1mu': {
      'ka': 'უსაფრთხოების კოდიᲡ აღდგენა',
      'en': '',
      'ru': '',
    },
    'bq9y4chl': {
      'ka': 'რეგისტრირებული ხართ ანგარიშით',
      'en': '',
      'ru': '',
    },
    'rkdxwj1o': {
      'ka': 'G  Google',
      'en': '',
      'ru': '',
    },
    'oukr4r6t': {
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
  // Dashboard
  {
    'c3lvgtua': {
      'ka': 'ᲣᲯᲠᲐ',
      'en': '',
      'ru': '',
    },
    'vqy9bbx7': {
      'ka': 'Gemma2',
      'en': '',
      'ru': '',
    },
    'g0rhiiuw': {
      'ka': 'HIWORLD',
      'en': '',
      'ru': '',
    },
    'bz2tw4po': {
      'ka': 'Home',
      'en': '',
      'ru': '',
    },
  },
  // CreateAccountPage
  {
    'da1vjewe': {
      'ka': 'ᲡᲐᲠᲔᲒᲘᲡᲢᲠᲐᲪᲘᲝ\nᲤᲝᲠᲛᲐ',
      'en': '',
      'ru': '',
    },
    'wt6p4il3': {
      'ka': 'ელ-ფოსტა',
      'en': '',
      'ru': '',
    },
    '7jyxu5zu': {
      'ka': 'მოიფიქრეთ 6-ნიშნა კოდი',
      'en': '',
      'ru': '',
    },
    'kidckntm': {
      'ka': 'განმეორებით ჩაწერეთ კოდი',
      'en': '',
      'ru': '',
    },
    'dgzpvmjv': {
      'ka': 'დაადასტურეთ ანგარიშის შექმნა',
      'en': '',
      'ru': '',
    },
    '7awg5n72': {
      'ka': 'ან\nრეგისტრირება შეგიძლიათ\nარსებული ანგარიშებითაც:',
      'en': '',
      'ru': '',
    },
    '2oapfisn': {
      'ka': 'G  Google',
      'en': '',
      'ru': '',
    },
    'o4fkbl0k': {
      'ka': 'Apple',
      'en': '',
      'ru': '',
    },
    '0wxkxy72': {
      'ka': 'Home',
      'en': '',
      'ru': '',
    },
  },
  // WelcomePage
  {
    '6vzhuxf6': {
      'ka':
          'ᲡᲐᲡᲙᲝᲚᲝ  ᲞᲠᲝᲒᲠᲐᲛᲐ  ᲣᲤᲐᲡᲝᲐ\nᲛᲝᲡᲬᲐᲕᲚᲔ-ᲛᲐᲡᲬᲐᲕᲚᲔᲑᲚᲔᲑᲘᲡᲐ\nᲓ Ა   Მ Შ Ო Ბ Ლ Ე Ბ Ი Ს Ა Თ Ვ Ი Ს',
      'en': '',
      'ru': '',
    },
    'b3j8cj70': {
      'ka': '12.COM.GE',
      'en': '',
      'ru': '',
    },
    'qgshb0kg': {
      'ka': 'ᲠᲔᲒᲘᲡᲢᲠᲘᲠᲔᲑᲐ ᲐᲐᲓᲕᲘᲚᲔᲑᲡ ᲪᲜᲝᲑᲐᲡ',
      'en': '',
      'ru': '',
    },
    '0gr43n9s': {
      'ka': 'ᲞᲘᲠᲐᲓ ᲡᲘᲕᲠᲪᲔᲨᲘ ᲨᲔᲡᲕᲚᲐ',
      'en': '',
      'ru': '',
    },
    'nharmluf': {
      'ka': 'G Google',
      'en': '',
      'ru': '',
    },
    'xk8lbq47': {
      'ka': 'Apple',
      'en': '',
      'ru': '',
    },
    'c4hf444u': {
      'ka': 'email',
      'en': '',
      'ru': '',
    },
    '4mbulvi7': {
      'ka':
          'ᲡᲐᲒᲐᲜᲛᲐᲜᲐᲗᲚᲔᲑᲚᲝ ᲞᲚᲐᲢᲤᲝᲠᲛᲐ ᲣᲖᲠᲣᲜᲕᲔᲚᲧᲝᲤᲘᲚᲘᲐ\nᲪᲘᲤᲠᲣᲚᲘ  ᲚᲘᲜᲒᲕᲘᲡᲢᲣᲠᲘ  ᲛᲝᲓᲔᲚᲘᲗ Ე. Წ.  ᲮᲔᲚᲝᲕᲜᲣᲠᲘ\nᲘᲜᲢᲔᲚᲔᲥᲢᲘᲗ.  ᲛᲘᲡᲘ ᲛᲗᲐᲕᲐᲠᲘ ᲐᲛᲝᲪᲐᲜᲐᲐ ᲛᲔᲪᲜᲘᲔᲠᲔᲑᲔᲑᲡ\nᲨᲝᲠᲘᲡ ᲐᲠᲡᲔᲑᲣᲚᲘ ᲙᲐᲕᲨᲘᲠᲔᲑᲘᲡ ᲒᲐᲛᲝᲕᲚᲔᲜᲐ, ᲛᲝᲡᲬᲐᲕᲚᲔ-\nᲡᲢᲣᲓᲔᲜᲢᲔᲑᲘᲡ   ᲓᲐᲮᲛᲐᲠᲔᲑᲐ   ᲡᲐᲡᲬᲐᲕᲚᲝ   ᲞᲠᲝᲒᲠᲐᲛᲔᲑᲘᲗ\nᲒᲐᲗᲕᲐᲚᲘᲡᲬᲘᲜᲔᲑᲣᲚᲘ  ᲡᲐᲒᲜᲔᲑᲘᲡ ᲒᲐᲒᲔᲑᲐᲡᲐ ᲓᲐ ᲡᲬᲐᲕᲚᲐᲨᲘ.',
      'en': '',
      'ru': '',
    },
    'of2me6e5': {
      'ka': 'Home',
      'en': '',
      'ru': '',
    },
  },
  // ProfilePage
  {
    'wp70iyt8': {
      'ka': 'David Jerome',
      'en': '',
      'ru': '',
    },
    'lmrfs9r5': {
      'ka': 'David.j@gmail.com',
      'en': '',
      'ru': '',
    },
    'p5vp8xdi': {
      'ka': 'Passenger Documents',
      'en': '',
      'ru': '',
    },
    '0rx16omk': {
      'ka': 'Tracker Notifications',
      'en': '',
      'ru': '',
    },
    'rsl2smc0': {
      'ka': 'Help Center',
      'en': '',
      'ru': '',
    },
    'ei202ub5': {
      'ka': 'Settings',
      'en': '',
      'ru': '',
    },
    'odu2n3b8': {
      'ka': 'Phone Number',
      'en': '',
      'ru': '',
    },
    '6mvduxev': {
      'ka': 'Add Number',
      'en': '',
      'ru': '',
    },
    'kqn6ev4c': {
      'ka': 'Language',
      'en': '',
      'ru': '',
    },
    'xjbhm1mi': {
      'ka': 'English (eng)',
      'en': '',
      'ru': '',
    },
    'z42dyta0': {
      'ka': 'Currency',
      'en': '',
      'ru': '',
    },
    '0scolbsz': {
      'ka': 'US Dollar (\$)',
      'en': '',
      'ru': '',
    },
    'ziw9pq71': {
      'ka': 'Profile Settings',
      'en': '',
      'ru': '',
    },
    'u4fc40gj': {
      'ka': 'Edit Profile',
      'en': '',
      'ru': '',
    },
    'lxq8d1fh': {
      'ka': 'Notification Settings',
      'en': '',
      'ru': '',
    },
    '7l6it1di': {
      'ka': 'Log out of account',
      'en': '',
      'ru': '',
    },
    'fsk0hu0c': {
      'ka': 'Log Out?',
      'en': '',
      'ru': '',
    },
    'i1j5hslx': {
      'ka': 'Home',
      'en': '',
      'ru': '',
    },
  },
  // PdfReaderPage
  {
    's8krifrk': {
      'ka': 'AI',
      'en': '',
      'ru': '',
    },
    '9i0cec4q': {
      'ka': '',
      'en': '',
      'ru': '',
    },
    '92bf7hm8': {
      'ka': 'Option 2',
      'en': '',
      'ru': '',
    },
    '3cmn6eyz': {
      'ka': 'Option 3',
      'en': '',
      'ru': '',
    },
    'qn60dl7p': {
      'ka': 'Back',
      'en': '',
      'ru': '',
    },
    'uzz5malp': {
      'ka': 'Home',
      'en': '',
      'ru': '',
    },
  },
  // Paywall
  {
    '5qauccix': {
      'ka': 'გამოწერის დონეები',
      'en': '',
      'ru': '',
    },
    '4y52njbb': {
      'ka': '12.COM.GE',
      'en': '',
      'ru': '',
    },
    'd78ri8dj': {
      'ka': 'აპლიკაციის გამოწერა',
      'en': '',
      'ru': '',
    },
    '8ylw8anm': {
      'ka': 'Gemma 2B ',
      'en': '',
      'ru': '',
    },
    '81jfft0m': {
      'ka':
          'ავტონომიური ციფრული ინტელექტი თქვენს სმარტფონში ფუნქციონირებს ინტერნეტის ტრაფიკის გარეშე.',
      'en': '',
      'ru': '',
    },
    '72utop8d': {
      'ka': 'გამოწერის აღდგენა',
      'en': '',
      'ru': '',
    },
    'aworuv12': {
      'ka': 'არსებული გამოწერა არ დაგეკარგებათ შეეხეთ აღსადგენად',
      'en': '',
      'ru': '',
    },
    '1837vlb5': {
      'ka': 'Home',
      'en': '',
      'ru': '',
    },
  },
  // SchoolModule
  {
    'ps6trt1f': {
      'ka': '',
      'en': '',
      'ru': '',
    },
    'feqx2qvq': {
      'ka': 'გეგმა, შეხსენება, კალენდარი',
      'en': '',
      'ru': '',
    },
    'ezez9gpi': {
      'ka': 'მოვამზადო საკონტროლოს საკითხები',
      'en': '',
      'ru': '',
    },
    'rxo0sroc': {
      'ka': 'ნინოს - ვაჟას პოეზიის გარჩევა',
      'en': '',
      'ru': '',
    },
    'bepdnxgg': {
      'ka': 'კვირას ფეხბურთს ვთამაშობთ',
      'en': '',
      'ru': '',
    },
    'zzsypaxi': {
      'ka': 'აღნიშნულის შენახვა კალენდარში',
      'en': '',
      'ru': '',
    },
    'tjdl69az': {
      'ka': '',
      'en': '',
      'ru': '',
    },
    'ew28bkur': {
      'ka': '',
      'en': '',
      'ru': '',
    },
    '1cplxs8z': {
      'ka': 'სასკოლო პროგრამა',
      'en': '',
      'ru': '',
    },
    'ccowawu4': {
      'ka': 'კლასგარეშე საკითხავი',
      'en': '',
      'ru': '',
    },
    'z5giokjj': {
      'ka': 'სასკოლო პროგრამა',
      'en': '',
      'ru': '',
    },
    'ct0muu9y': {
      'ka': '7',
      'en': '',
      'ru': '',
    },
    'u639tkbi': {
      'ka': '8',
      'en': '',
      'ru': '',
    },
    'gdyr7sqb': {
      'ka': '9',
      'en': '',
      'ru': '',
    },
    'ifsfjkmz': {
      'ka': '10',
      'en': '',
      'ru': '',
    },
    'rxxsajj4': {
      'ka': '11',
      'en': '',
      'ru': '',
    },
    'eh017yrj': {
      'ka': '',
      'en': '',
      'ru': '',
    },
    'cxzma7x8': {
      'ka': 'სად გამოიყენება ეს რეალურ სამყაროში?',
      'en': '',
      'ru': '',
    },
    'isfeigl1': {
      'ka': 'მითის განადგურება',
      'en': '',
      'ru': '',
    },
    'scbbwpx9': {
      'ka': 'საშინაო ექსპერიმენტი',
      'en': '',
      'ru': '',
    },
    'wecnay7w': {
      'ka':
          'ᲓᲐᲡᲕᲘᲗ ᲙᲘᲗᲮᲕᲔᲑᲘ ᲐᲛ ᲗᲔᲛᲔᲑᲘᲡ ᲒᲐᲡᲐᲦᲠᲛᲐᲕᲔᲑᲚᲐᲓ, ᲐᲜ ᲨᲔᲔᲮᲔᲗ, ᲠᲐᲡᲐᲪ ᲘᲙᲕᲚᲔᲕᲔᲜ ᲡᲮᲕᲐ ᲡᲢᲣᲓᲔᲜᲢᲔᲑᲘ',
      'en': '',
      'ru': '',
    },
    '4kwadtdd': {
      'ka': '',
      'en': '',
      'ru': '',
    },
    '6isen49q': {
      'ka': 'Option 2',
      'en': '',
      'ru': '',
    },
    'dg9toqjr': {
      'ka': 'Option 3',
      'en': '',
      'ru': '',
    },
    '5nqwssry': {
      'ka': 'Home',
      'en': '',
      'ru': '',
    },
  },
  // ChatFAB
  {
    'zgtj2y8o': {
      'ka': '',
      'en': '',
      'ru': '',
    },
  },
  // SchoolChatComponent
  {
    'rytn4s1x': {
      'ka': 'ᲐᲥ ᲨᲔᲔᲮᲔᲗ ᲓᲐ ᲩᲐᲬᲔᲠᲔᲗ ᲗᲥᲕᲔᲜᲘ ᲨᲔᲙᲘᲗᲮᲕᲐ, ᲠᲐᲪ ᲒᲐᲘᲜᲢᲔᲠᲔᲡᲔᲑᲗ',
      'en': '',
      'ru': '',
    },
    'ctm5mo7m': {
      'ka': 'ᲐᲥ ᲨᲔᲔᲮᲔᲗ ᲓᲐ ᲩᲐᲬᲔᲠᲔᲗ ᲗᲥᲕᲔᲜᲘ ᲨᲔᲙᲘᲗᲮᲕᲐ, ᲠᲐᲪ ᲒᲐᲘᲜᲢᲔᲠᲔᲡᲔᲑᲗ',
      'en': '',
      'ru': '',
    },
  },
  // SchoolBottomSheet
  {
    'o7a6v3cs': {
      'ka': 'ᲒᲐᲛᲝᲧᲐᲕᲘᲗ ᲢᲔᲥᲡᲢᲘ ᲐᲜ ᲓᲐᲡᲕᲘᲗ ᲨᲔᲙᲘᲗᲮᲕᲐ ᲐᲛ ᲒᲕᲔᲠᲓᲘᲡ ᲗᲔᲛᲔᲑᲖᲔ',
      'en': '',
      'ru': '',
    },
    '2h9jgtdm': {
      'ka': 'ᲒᲐᲛᲝᲧᲐᲕᲘᲗ ᲢᲔᲥᲡᲢᲘ ᲐᲜ ᲓᲐᲡᲕᲘᲗ ᲨᲔᲙᲘᲗᲮᲕᲐ ᲐᲛ ᲒᲕᲔᲠᲓᲘᲡ ᲗᲔᲛᲔᲑᲖᲔ',
      'en': '',
      'ru': '',
    },
  },
  // LaboratoryGenUIComponent
  {
    '4t9dkhvf': {
      'ka': 'დღის თემები',
      'en': '',
      'ru': '',
    },
  },
  // ConceptBadgeComponent
  {
    'lnovmjjn': {
      'ka': 'conceptTitle',
      'en': '',
      'ru': '',
    },
  },
  // Miscellaneous
  {
    'hu63uzvk': {
      'ka': 'კალენდარის წვდომის ნებართვა თქვენი ჩანაწერების შესანახად',
      'en': '',
      'ru': '',
    },
    'izmo2scg': {
      'ka': 'თქვენი გეგმების ავტომატური ჩანაწერების ნებართვა',
      'en': '',
      'ru': '',
    },
    'ejplmuf1': {
      'ka': 'კალენდარის წარმოების ნებართვა',
      'en': '',
      'ru': '',
    },
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
