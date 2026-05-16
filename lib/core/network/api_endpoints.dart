abstract class ApiEndpoints {
  // Auth
  static const String inscription = '/auth/inscription';
  static const String renvoyerOtpInscription = '/auth/renvoyer-otp-inscription';
  static const String verifierOtp = '/auth/verifier-otp';
  static const String creerPin = '/auth/creer-pin';
  static const String connexion = '/auth/connexion';
  static const String rafraichirToken = '/auth/rafraichir-token';
  static const String deconnexion = '/auth/deconnexion';

  static const String profil = '/utilisateurs/profil';
  static const String monQrCode = '/utilisateurs/mon-qr-code';

  // Collecteur terrain
  static const String checkIn = '/collecteur/check-in';
  static const String clientsDuJour = '/collecteur/clients-du-jour';
  static const String carteClients = '/collecteur/carte-clients';
  static const String mesPresences = '/collecteur/mes-presences';
  static const String dashboardIndependant =
      '/collecteur/dashboard-independant';
  static String contactWhatsApp(String clientId) =>
      '/collecteur/contact-whatsapp/$clientId';

  // Opérations assistées
  static const String enrolerClientSansSmartphone =
      '/operations-assistees/clients-sans-smartphone';
  static String ficheTerrain(String clientId) =>
      '/operations-assistees/clients/$clientId/fiche-terrain';
  static const String initierCotisation =
      '/operations-assistees/cotisations/initier';
  static const String initierRetrait = '/operations-assistees/retraits/initier';
  static String statutOperation(String id) =>
      '/operations-assistees/$id/statut';

  // Micro-crédits
  static const String demanderMicroCredit = '/micro-credits/demander';

  // Tontines
  static const String mesTontines = '/tontines/mes-tontines';

  // Commissions
  static const String soldeCommission = '/commissions/mon-solde';
  static const String historiqueCommissions = '/commissions/historique';

  // QR
  static const String monCodeQr = '/qrcode/mon-code';
  static String scannerQrCode(String code) => '/qrcode/scanner/$code';

  // Notifications
  static const String notifications = '/notifications';
  static const String notificationsNonLues = '/notifications/non-lues';

  // Litiges
  static const String mesLitiges = '/litiges/mes-litiges';
  static const String litigesEnCours = '/litiges/en-cours/liste';

  // Supervision / analytics
  static const String analyticsKpis = '/analytics/kpis';
  static const String performanceCollecteurs =
      '/analytics/performance-collecteurs';
  static const String scoresParZone = '/analytics/scores-par-zone';

  // Zones
  static const String zones = '/zones';
}
