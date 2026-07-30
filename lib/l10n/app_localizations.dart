import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_vi.dart';

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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
    Locale('vi')
  ];

  /// App title shown on the login screen
  ///
  /// In en, this message translates to:
  /// **'IT Support Agent'**
  String get appTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to receive and handle support tickets'**
  String get loginSubtitle;

  /// No description provided for @serverAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'VM TECH server address'**
  String get serverAddressLabel;

  /// No description provided for @apiKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'API Key'**
  String get apiKeyLabel;

  /// No description provided for @apiKeyHint.
  ///
  /// In en, this message translates to:
  /// **'Your personal API key'**
  String get apiKeyHint;

  /// No description provided for @signInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInButton;

  /// No description provided for @errorEnterServerAddress.
  ///
  /// In en, this message translates to:
  /// **'Please enter the server address'**
  String get errorEnterServerAddress;

  /// No description provided for @errorEnterApiKey.
  ///
  /// In en, this message translates to:
  /// **'Please enter the API key'**
  String get errorEnterApiKey;

  /// No description provided for @errorNotAgent.
  ///
  /// In en, this message translates to:
  /// **'This account is not in the IT Support Agent/Manager group. Please contact your administrator.'**
  String get errorNotAgent;

  /// No description provided for @errorConnectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not connect: {error}'**
  String errorConnectionFailed(String error);

  /// No description provided for @appBarTitle.
  ///
  /// In en, this message translates to:
  /// **'IT Support'**
  String get appBarTitle;

  /// No description provided for @tabMine.
  ///
  /// In en, this message translates to:
  /// **'Mine ({count})'**
  String tabMine(int count);

  /// No description provided for @tabUnassigned.
  ///
  /// In en, this message translates to:
  /// **'Unassigned ({count})'**
  String tabUnassigned(int count);

  /// No description provided for @retryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryButton;

  /// No description provided for @emptyMyTickets.
  ///
  /// In en, this message translates to:
  /// **'You have no tickets in progress.'**
  String get emptyMyTickets;

  /// No description provided for @emptyUnassignedTickets.
  ///
  /// In en, this message translates to:
  /// **'No tickets waiting to be picked up.'**
  String get emptyUnassignedTickets;

  /// No description provided for @priorityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get priorityLow;

  /// No description provided for @priorityNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get priorityNormal;

  /// No description provided for @priorityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get priorityHigh;

  /// No description provided for @priorityUrgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get priorityUrgent;

  /// No description provided for @stateNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get stateNew;

  /// No description provided for @stateAssigned.
  ///
  /// In en, this message translates to:
  /// **'Assigned'**
  String get stateAssigned;

  /// No description provided for @stateInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get stateInProgress;

  /// No description provided for @statePaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get statePaused;

  /// No description provided for @stateDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get stateDone;

  /// No description provided for @stateCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get stateCancelled;

  /// No description provided for @noDeviceLabel.
  ///
  /// In en, this message translates to:
  /// **'No device attached'**
  String get noDeviceLabel;

  /// No description provided for @hoursLabel.
  ///
  /// In en, this message translates to:
  /// **'{hours} h'**
  String hoursLabel(String hours);

  /// No description provided for @assignToMeButton.
  ///
  /// In en, this message translates to:
  /// **'Assign to Me'**
  String get assignToMeButton;

  /// No description provided for @startButton.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startButton;

  /// No description provided for @endButton.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get endButton;

  /// No description provided for @markDoneButton.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get markDoneButton;

  /// No description provided for @supportModeDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Support mode'**
  String get supportModeDialogTitle;

  /// No description provided for @supportModeOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get supportModeOnline;

  /// No description provided for @supportModeOnsite.
  ///
  /// In en, this message translates to:
  /// **'Onsite'**
  String get supportModeOnsite;

  /// No description provided for @endSessionDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'End session'**
  String get endSessionDialogTitle;

  /// No description provided for @endSessionNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Work performed'**
  String get endSessionNoteHint;

  /// No description provided for @endSessionResolutionStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Resolution status'**
  String get endSessionResolutionStatusLabel;

  /// No description provided for @endSessionResolutionStatusHint.
  ///
  /// In en, this message translates to:
  /// **'-- Select --'**
  String get endSessionResolutionStatusHint;

  /// No description provided for @resolutionStatusResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get resolutionStatusResolved;

  /// No description provided for @resolutionStatusPartiallyResolved.
  ///
  /// In en, this message translates to:
  /// **'Partially Resolved'**
  String get resolutionStatusPartiallyResolved;

  /// No description provided for @resolutionStatusNotResolved.
  ///
  /// In en, this message translates to:
  /// **'Not Resolved'**
  String get resolutionStatusNotResolved;

  /// No description provided for @resolutionStatusEscalated.
  ///
  /// In en, this message translates to:
  /// **'Escalated'**
  String get resolutionStatusEscalated;

  /// No description provided for @endSessionNoteRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Please describe the work performed.'**
  String get endSessionNoteRequiredError;

  /// No description provided for @endSessionResolutionRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Please select the resolution status.'**
  String get endSessionResolutionRequiredError;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @confirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmButton;

  /// No description provided for @markDoneDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Mark ticket as done?'**
  String get markDoneDialogTitle;

  /// No description provided for @markDoneDialogContent.
  ///
  /// In en, this message translates to:
  /// **'The ticket will be set to Done. Any running session will be closed automatically.'**
  String get markDoneDialogContent;

  /// No description provided for @noMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet.'**
  String get noMessagesYet;

  /// No description provided for @chatInputHint.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get chatInputHint;

  /// No description provided for @ticketFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Ticket'**
  String get ticketFallbackTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @logoutButton.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logoutButton;

  /// No description provided for @bookingRequestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Booking Requests'**
  String get bookingRequestsTitle;

  /// No description provided for @bookingRequestsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Booking Requests'**
  String get bookingRequestsTooltip;

  /// No description provided for @emptyBookingRequests.
  ///
  /// In en, this message translates to:
  /// **'No pending booking requests.'**
  String get emptyBookingRequests;

  /// No description provided for @bookingConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm & Create Ticket'**
  String get bookingConfirmButton;

  /// No description provided for @bookingConfirmDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm this booking?'**
  String get bookingConfirmDialogTitle;

  /// No description provided for @bookingConfirmDialogContent.
  ///
  /// In en, this message translates to:
  /// **'A customer profile (if needed) and an initial ticket will be created from this request.'**
  String get bookingConfirmDialogContent;
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
      <String>['en', 'fr', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
