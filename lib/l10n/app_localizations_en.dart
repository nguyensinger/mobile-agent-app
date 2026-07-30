// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'IT Support Agent';

  @override
  String get loginSubtitle => 'Sign in to receive and handle support tickets';

  @override
  String get serverAddressLabel => 'VM TECH server address';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get signInButton => 'Sign in';

  @override
  String get errorEnterServerAddress => 'Please enter the server address';

  @override
  String get errorEnterEmail => 'Please enter your email';

  @override
  String get errorEnterPassword => 'Please enter your password';

  @override
  String errorConnectionFailed(String error) {
    return 'Could not connect: $error';
  }

  @override
  String get appBarTitle => 'IT Support';

  @override
  String tabMine(int count) {
    return 'Mine ($count)';
  }

  @override
  String tabUnassigned(int count) {
    return 'Unassigned ($count)';
  }

  @override
  String get retryButton => 'Retry';

  @override
  String get emptyMyTickets => 'You have no tickets in progress.';

  @override
  String get emptyUnassignedTickets => 'No tickets waiting to be picked up.';

  @override
  String get priorityLow => 'Low';

  @override
  String get priorityNormal => 'Normal';

  @override
  String get priorityHigh => 'High';

  @override
  String get priorityUrgent => 'Urgent';

  @override
  String get stateNew => 'New';

  @override
  String get stateAssigned => 'Assigned';

  @override
  String get stateInProgress => 'In progress';

  @override
  String get statePaused => 'Paused';

  @override
  String get stateDone => 'Done';

  @override
  String get stateCancelled => 'Cancelled';

  @override
  String get noDeviceLabel => 'No device attached';

  @override
  String hoursLabel(String hours) {
    return '$hours h';
  }

  @override
  String get assignToMeButton => 'Assign to Me';

  @override
  String get startButton => 'Start';

  @override
  String get endButton => 'End';

  @override
  String get markDoneButton => 'Done';

  @override
  String get supportModeDialogTitle => 'Support mode';

  @override
  String get supportModeOnline => 'Online';

  @override
  String get supportModeOnsite => 'Onsite';

  @override
  String get endSessionDialogTitle => 'End session';

  @override
  String get endSessionNoteHint => 'Work performed';

  @override
  String get endSessionResolutionStatusLabel => 'Resolution status';

  @override
  String get endSessionResolutionStatusHint => '-- Select --';

  @override
  String get resolutionStatusResolved => 'Resolved';

  @override
  String get resolutionStatusPartiallyResolved => 'Partially Resolved';

  @override
  String get resolutionStatusNotResolved => 'Not Resolved';

  @override
  String get resolutionStatusEscalated => 'Escalated';

  @override
  String get endSessionNoteRequiredError =>
      'Please describe the work performed.';

  @override
  String get endSessionResolutionRequiredError =>
      'Please select the resolution status.';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get confirmButton => 'Confirm';

  @override
  String get markDoneDialogTitle => 'Mark ticket as done?';

  @override
  String get markDoneDialogContent =>
      'The ticket will be set to Done. Any running session will be closed automatically.';

  @override
  String get noMessagesYet => 'No messages yet.';

  @override
  String get chatInputHint => 'Type a message...';

  @override
  String get ticketFallbackTitle => 'Ticket';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get languageLabel => 'Language';

  @override
  String get logoutButton => 'Log out';

  @override
  String get bookingRequestsTitle => 'Booking Requests';

  @override
  String get bookingRequestsTooltip => 'Booking Requests';

  @override
  String get emptyBookingRequests => 'No pending booking requests.';

  @override
  String get bookingConfirmButton => 'Confirm & Create Ticket';

  @override
  String get bookingConfirmDialogTitle => 'Confirm this booking?';

  @override
  String get bookingConfirmDialogContent =>
      'A customer profile (if needed) and an initial ticket will be created from this request.';
}
