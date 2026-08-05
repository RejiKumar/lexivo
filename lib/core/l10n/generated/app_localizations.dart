import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// Application / brand title
  ///
  /// In en, this message translates to:
  /// **'Lexivo'**
  String get appTitle;

  /// Primary nav: document library
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get navDocuments;

  /// Primary nav: document scan
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get navScan;

  /// Primary nav: notifications inbox
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get navNotifications;

  /// Primary nav: account settings
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get navAccount;

  /// Sign-in screen title and primary CTA
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInTitle;

  /// Sign-up screen title
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get signUpTitle;

  /// Sign-up primary button
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUpAction;

  /// Link from sign-in to sign-up
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get createAnAccount;

  /// Link from sign-up to sign-in
  ///
  /// In en, this message translates to:
  /// **'Already have an account'**
  String get alreadyHaveAccount;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// Email field hint
  ///
  /// In en, this message translates to:
  /// **'you@lexivo.app'**
  String get emailHint;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// Sign-in password hint
  ///
  /// In en, this message translates to:
  /// **'Your password'**
  String get passwordHint;

  /// Sign-up password hint
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get passwordHintSignUp;

  /// Display name field label
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get displayNameLabel;

  /// Optional display name hint
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get displayNameHintOptional;

  /// Validation: empty email
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// Validation: empty password
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// Validation: password length
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// Account settings screen title
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountTitle;

  /// Navigate to account settings
  ///
  /// In en, this message translates to:
  /// **'Account settings'**
  String get accountSettings;

  /// Save account changes
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveAction;

  /// Success snackbar after account save
  ///
  /// In en, this message translates to:
  /// **'Account updated'**
  String get accountUpdated;

  /// Sign out button
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOutAction;

  /// Authenticated status without email
  ///
  /// In en, this message translates to:
  /// **'Signed in'**
  String get signedIn;

  /// Authenticated status with email
  ///
  /// In en, this message translates to:
  /// **'Signed in as {email}'**
  String signedInAs(String email);

  /// Document library empty-state title
  ///
  /// In en, this message translates to:
  /// **'No documents yet'**
  String get libraryEmptyTitle;

  /// Document library empty-state description
  ///
  /// In en, this message translates to:
  /// **'Scan or upload a document to get started.'**
  String get libraryEmptyDescription;

  /// CTA to open document scan
  ///
  /// In en, this message translates to:
  /// **'Scan document'**
  String get libraryScanAction;

  /// Fallback title when a document has no name
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get untitledDocument;

  /// Detail pane placeholder when nothing is selected
  ///
  /// In en, this message translates to:
  /// **'Select a document'**
  String get librarySelectDocumentTitle;

  /// Detail pane placeholder description
  ///
  /// In en, this message translates to:
  /// **'Choose a document from the list to preview actions.'**
  String get librarySelectDocumentDescription;

  /// Open selected document OCR flow
  ///
  /// In en, this message translates to:
  /// **'Open document'**
  String get libraryOpenDocument;

  /// Title for document action overlay
  ///
  /// In en, this message translates to:
  /// **'Document actions'**
  String get libraryDocumentActions;

  /// Dismiss document actions overlay
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get libraryCloseAction;

  /// RAG chat screen title
  ///
  /// In en, this message translates to:
  /// **'Ask the document'**
  String get chatTitle;

  /// Navigate back
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backAction;

  /// Open document export
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get exportAction;

  /// RAG chat empty conversation title
  ///
  /// In en, this message translates to:
  /// **'Ask anything'**
  String get chatEmptyTitle;

  /// RAG chat empty conversation description
  ///
  /// In en, this message translates to:
  /// **'Send a question about this document to get a grounded answer with citations.'**
  String get chatEmptyDescription;

  /// RAG chat composer hint
  ///
  /// In en, this message translates to:
  /// **'Ask a question…'**
  String get chatInputHint;

  /// Send chat message
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get sendAction;

  /// Citations / context side panel title
  ///
  /// In en, this message translates to:
  /// **'Context'**
  String get chatContextTitle;

  /// Empty citations panel title
  ///
  /// In en, this message translates to:
  /// **'No citations yet'**
  String get chatContextEmptyTitle;

  /// Empty citations panel description
  ///
  /// In en, this message translates to:
  /// **'Answers with source snippets will appear here.'**
  String get chatContextEmptyDescription;

  /// Fallback citation chip label
  ///
  /// In en, this message translates to:
  /// **'Citation {index}'**
  String chatCitationFallback(String index);

  /// Citation detail sheet/dialog title
  ///
  /// In en, this message translates to:
  /// **'Citation'**
  String get chatCitationDetailsTitle;

  /// Dismiss citation detail overlay
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get chatDoneAction;

  /// Soft-update prompt title
  ///
  /// In en, this message translates to:
  /// **'Update available'**
  String get upgradeSoftTitle;

  /// Force-update blocking prompt title
  ///
  /// In en, this message translates to:
  /// **'Update required'**
  String get upgradeForceTitle;

  /// Fallback soft-update body when server message is empty
  ///
  /// In en, this message translates to:
  /// **'A new version of Lexivo is available.'**
  String get upgradeSoftBody;

  /// Fallback force-update body when server message is empty
  ///
  /// In en, this message translates to:
  /// **'Please update Lexivo to continue.'**
  String get upgradeForceBody;

  /// Dismiss soft-update prompt
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get upgradeLaterAction;

  /// Open store listing to update the app
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get upgradeUpdateAction;

  /// Reload web app for the latest version
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get upgradeReloadAction;
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
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
