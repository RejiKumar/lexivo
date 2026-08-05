// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Lexivo';

  @override
  String get navDocuments => 'Documents';

  @override
  String get navScan => 'Scan';

  @override
  String get navNotifications => 'Notifications';

  @override
  String get navAccount => 'Account';

  @override
  String get signInTitle => 'Sign in';

  @override
  String get signUpTitle => 'Create account';

  @override
  String get signUpAction => 'Sign up';

  @override
  String get createAnAccount => 'Create an account';

  @override
  String get alreadyHaveAccount => 'Already have an account';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailHint => 'you@lexivo.app';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => 'Your password';

  @override
  String get passwordHintSignUp => 'At least 6 characters';

  @override
  String get displayNameLabel => 'Display name';

  @override
  String get displayNameHintOptional => 'Optional';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get accountTitle => 'Account';

  @override
  String get accountSettings => 'Account settings';

  @override
  String get saveAction => 'Save';

  @override
  String get accountUpdated => 'Account updated';

  @override
  String get signOutAction => 'Sign out';

  @override
  String get signedIn => 'Signed in';

  @override
  String signedInAs(String email) {
    return 'Signed in as $email';
  }

  @override
  String get libraryEmptyTitle => 'No documents yet';

  @override
  String get libraryEmptyDescription =>
      'Scan or upload a document to get started.';

  @override
  String get libraryScanAction => 'Scan document';

  @override
  String get untitledDocument => 'Untitled';

  @override
  String get librarySelectDocumentTitle => 'Select a document';

  @override
  String get librarySelectDocumentDescription =>
      'Choose a document from the list to preview actions.';

  @override
  String get libraryOpenDocument => 'Open document';

  @override
  String get libraryDocumentActions => 'Document actions';

  @override
  String get libraryCloseAction => 'Close';

  @override
  String get chatTitle => 'Ask the document';

  @override
  String get backAction => 'Back';

  @override
  String get exportAction => 'Export';

  @override
  String get chatEmptyTitle => 'Ask anything';

  @override
  String get chatEmptyDescription =>
      'Send a question about this document to get a grounded answer with citations.';

  @override
  String get chatInputHint => 'Ask a question…';

  @override
  String get sendAction => 'Send';

  @override
  String get chatContextTitle => 'Context';

  @override
  String get chatContextEmptyTitle => 'No citations yet';

  @override
  String get chatContextEmptyDescription =>
      'Answers with source snippets will appear here.';

  @override
  String chatCitationFallback(String index) {
    return 'Citation $index';
  }

  @override
  String get chatCitationDetailsTitle => 'Citation';

  @override
  String get chatDoneAction => 'Done';

  @override
  String get upgradeSoftTitle => 'Update available';

  @override
  String get upgradeForceTitle => 'Update required';

  @override
  String get upgradeSoftBody => 'A new version of Lexivo is available.';

  @override
  String get upgradeForceBody => 'Please update Lexivo to continue.';

  @override
  String get upgradeLaterAction => 'Later';

  @override
  String get upgradeUpdateAction => 'Update';

  @override
  String get upgradeReloadAction => 'Reload';
}
