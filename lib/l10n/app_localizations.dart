import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_fr.dart';
import 'app_localizations_mg.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('fr'),
    Locale('mg')
  ];

  /// No description provided for @appTitle.
  ///
  /// In fr, this message translates to:
  /// **'MeteoMada'**
  String get appTitle;

  /// No description provided for @searchCity.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher une ville'**
  String get searchCity;

  /// No description provided for @cityName.
  ///
  /// In fr, this message translates to:
  /// **'Nom de ville ou région...'**
  String get cityName;

  /// No description provided for @currentWeather.
  ///
  /// In fr, this message translates to:
  /// **'Météo actuelle'**
  String get currentWeather;

  /// No description provided for @forecast7Days.
  ///
  /// In fr, this message translates to:
  /// **'Prévisions 7 jours'**
  String get forecast7Days;

  /// No description provided for @marineConditions.
  ///
  /// In fr, this message translates to:
  /// **'Conditions marines'**
  String get marineConditions;

  /// No description provided for @cycloneAlerts.
  ///
  /// In fr, this message translates to:
  /// **'Alertes cyclones'**
  String get cycloneAlerts;

  /// No description provided for @noAlerts.
  ///
  /// In fr, this message translates to:
  /// **'Aucune alerte active'**
  String get noAlerts;

  /// No description provided for @noHistory.
  ///
  /// In fr, this message translates to:
  /// **'Aucun historique'**
  String get noHistory;

  /// No description provided for @favorites.
  ///
  /// In fr, this message translates to:
  /// **'Favoris'**
  String get favorites;

  /// No description provided for @noFavorites.
  ///
  /// In fr, this message translates to:
  /// **'Aucune ville favorite'**
  String get noFavorites;

  /// No description provided for @addFavorite.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une ville'**
  String get addFavorite;

  /// No description provided for @agriculturalCalendar.
  ///
  /// In fr, this message translates to:
  /// **'Calendrier cultural'**
  String get agriculturalCalendar;

  /// No description provided for @settings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get language;

  /// No description provided for @french.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get french;

  /// No description provided for @malagasy.
  ///
  /// In fr, this message translates to:
  /// **'Malagasy'**
  String get malagasy;

  /// No description provided for @notifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @cycloneAlertsNotif.
  ///
  /// In fr, this message translates to:
  /// **'Alertes cyclone'**
  String get cycloneAlertsNotif;

  /// No description provided for @rainAlertsNotif.
  ///
  /// In fr, this message translates to:
  /// **'Alertes pluie'**
  String get rainAlertsNotif;

  /// No description provided for @about.
  ///
  /// In fr, this message translates to:
  /// **'À propos'**
  String get about;

  /// No description provided for @version.
  ///
  /// In fr, this message translates to:
  /// **'Version 1.0.0'**
  String get version;

  /// No description provided for @loading.
  ///
  /// In fr, this message translates to:
  /// **'Chargement...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de chargement'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get retry;

  /// No description provided for @emptyData.
  ///
  /// In fr, this message translates to:
  /// **'Aucune donnée disponible'**
  String get emptyData;

  /// No description provided for @today.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get today;

  /// No description provided for @tomorrow.
  ///
  /// In fr, this message translates to:
  /// **'Demain'**
  String get tomorrow;

  /// No description provided for @seeding.
  ///
  /// In fr, this message translates to:
  /// **'Semis'**
  String get seeding;

  /// No description provided for @harvest.
  ///
  /// In fr, this message translates to:
  /// **'Récolte'**
  String get harvest;

  /// No description provided for @region.
  ///
  /// In fr, this message translates to:
  /// **'Région'**
  String get region;

  /// No description provided for @activeAlerts.
  ///
  /// In fr, this message translates to:
  /// **'Alertes actives'**
  String get activeAlerts;

  /// No description provided for @history.
  ///
  /// In fr, this message translates to:
  /// **'Historique'**
  String get history;

  /// No description provided for @filterByRegion.
  ///
  /// In fr, this message translates to:
  /// **'Filtrer par région'**
  String get filterByRegion;

  /// No description provided for @allRegions.
  ///
  /// In fr, this message translates to:
  /// **'Toutes les régions'**
  String get allRegions;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['fr', 'mg'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'fr':
      return AppLocalizationsFr();
    case 'mg':
      return AppLocalizationsMg();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
