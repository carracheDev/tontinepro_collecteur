abstract class ApiEndpoints {
  static const String inscription = '/auth/inscription';
  static const String renvoyerOtpInscription = '/auth/renvoyer-otp-inscription';
  static const String verifierOtp = '/auth/verifier-otp';
  static const String creerPin = '/auth/creer-pin';
  static const String connexion = '/auth/connexion';
  static const String rafraichirToken = '/auth/rafraichir-token';
  static const String deconnexion = '/auth/deconnexion';

  static const String profil = '/utilisateurs/profil';

  static const String checkIn = '/collecteur/check-in';
  static const String clientsDuJour = '/collecteur/clients-du-jour';
  static const String carteClients = '/collecteur/carte-clients';
  static const String mesPresences = '/collecteur/mes-presences';
  static const String dashboardIndependant = '/collecteur/dashboard-independant';

  static const String soldeCommission = '/commissions/mon-solde';
  static const String historiqueCommissions = '/commissions/historique';

  static const String cotiser = '/transactions/cotiser';

  static const String monQrCode = '/utilisateurs/mon-qr-code';
  static const String scannerQrCode = '/qrcode/scanner';

  static const String notifications = '/notifications';
  static const String notificationsNonLues = '/notifications/non-lues';

  static const String mesLitiges = '/litiges/mes-litiges';
}
