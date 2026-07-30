// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'IT Support Agent';

  @override
  String get loginSubtitle =>
      'Connectez-vous pour recevoir et traiter les tickets de support';

  @override
  String get serverAddressLabel => 'Adresse du serveur VM TECH';

  @override
  String get apiKeyLabel => 'Clé API';

  @override
  String get apiKeyHint => 'Votre clé API personnelle';

  @override
  String get signInButton => 'Se connecter';

  @override
  String get errorEnterServerAddress => 'Veuillez saisir l\'adresse du serveur';

  @override
  String get errorEnterApiKey => 'Veuillez saisir la clé API';

  @override
  String get errorNotAgent =>
      'Ce compte n\'appartient pas au groupe IT Support Agent/Manager. Veuillez contacter votre administrateur.';

  @override
  String errorConnectionFailed(String error) {
    return 'Connexion impossible : $error';
  }

  @override
  String get appBarTitle => 'IT Support';

  @override
  String tabMine(int count) {
    return 'Mes tickets ($count)';
  }

  @override
  String tabUnassigned(int count) {
    return 'Non assignés ($count)';
  }

  @override
  String get retryButton => 'Réessayer';

  @override
  String get emptyMyTickets => 'Vous n\'avez aucun ticket en cours.';

  @override
  String get emptyUnassignedTickets =>
      'Aucun ticket en attente de prise en charge.';

  @override
  String get priorityLow => 'Faible';

  @override
  String get priorityNormal => 'Normale';

  @override
  String get priorityHigh => 'Élevée';

  @override
  String get priorityUrgent => 'Urgente';

  @override
  String get stateNew => 'Nouveau';

  @override
  String get stateAssigned => 'Assigné';

  @override
  String get stateInProgress => 'En cours';

  @override
  String get statePaused => 'En pause';

  @override
  String get stateDone => 'Terminé';

  @override
  String get stateCancelled => 'Annulé';

  @override
  String get noDeviceLabel => 'Aucun appareil associé';

  @override
  String hoursLabel(String hours) {
    return '$hours h';
  }

  @override
  String get assignToMeButton => 'M\'assigner';

  @override
  String get startButton => 'Démarrer';

  @override
  String get endButton => 'Terminer';

  @override
  String get markDoneButton => 'Terminé';

  @override
  String get supportModeDialogTitle => 'Mode de support';

  @override
  String get supportModeOnline => 'En ligne';

  @override
  String get supportModeOnsite => 'Sur site';

  @override
  String get endSessionDialogTitle => 'Terminer la session';

  @override
  String get endSessionNoteHint => 'Travail effectué';

  @override
  String get endSessionResolutionStatusLabel => 'Statut de résolution';

  @override
  String get endSessionResolutionStatusHint => '-- Sélectionner --';

  @override
  String get resolutionStatusResolved => 'Résolu';

  @override
  String get resolutionStatusPartiallyResolved => 'Partiellement résolu';

  @override
  String get resolutionStatusNotResolved => 'Non résolu';

  @override
  String get resolutionStatusEscalated => 'Escaladé';

  @override
  String get endSessionNoteRequiredError =>
      'Veuillez décrire le travail effectué.';

  @override
  String get endSessionResolutionRequiredError =>
      'Veuillez sélectionner le statut de résolution.';

  @override
  String get cancelButton => 'Annuler';

  @override
  String get confirmButton => 'Confirmer';

  @override
  String get markDoneDialogTitle => 'Marquer ce ticket comme terminé ?';

  @override
  String get markDoneDialogContent =>
      'Le ticket passera au statut Terminé. Toute session en cours sera automatiquement fermée.';

  @override
  String get noMessagesYet => 'Aucun message pour l\'instant.';

  @override
  String get chatInputHint => 'Écrivez un message...';

  @override
  String get ticketFallbackTitle => 'Ticket';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get languageLabel => 'Langue';

  @override
  String get logoutButton => 'Se déconnecter';

  @override
  String get bookingRequestsTitle => 'Demandes de réservation';

  @override
  String get bookingRequestsTooltip => 'Demandes de réservation';

  @override
  String get emptyBookingRequests =>
      'Aucune demande de réservation en attente.';

  @override
  String get bookingConfirmButton => 'Confirmer et créer un ticket';

  @override
  String get bookingConfirmDialogTitle => 'Confirmer cette réservation ?';

  @override
  String get bookingConfirmDialogContent =>
      'Un profil client (si nécessaire) et un ticket initial seront créés à partir de cette demande.';
}
