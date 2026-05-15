class ApiEndpoints {
  static const inscription = '/auth/inscription';
  static const verifierOtp = '/auth/verifier-otp';
  static const creerPin = '/auth/creer-pin';
  static const connexion = '/auth/connexion';
  static const refresh = '/auth/rafraichir-token';
  static const deconnexion = '/auth/deconnexion';
  static const bioRegister = '/auth/biometrique/enregistrer';
  static const bioLogin = '/auth/biometrique/connexion';
  static const bioDevices = '/auth/biometrique/appareils';

  static const profil = '/utilisateurs/profil';
  static const stats = '/utilisateurs/mes-stats';
  static const mesTontines = '/tontines/mes-tontines';
  static const cotiser = '/transactions/cotiser';
  static const historique = '/transactions/historique';
  static const demanderRetrait = '/retraits/demander';
  static const mesRetraits = '/retraits/mes-retraits';
  static const score = '/score/mon-score';
  static const notifications = '/notifications';
  static const notificationsNonLues = '/notifications/non-lues';
  static const notificationsToutLu = '/notifications/tout-lu';
  static const microCredits = '/micro-credits/mes-credits';
  static const litiges = '/litiges/mes-litiges';
  static const alertes = '/alertes';
  static const qrCollecteur = '/qrcode/mon-qr-collecteur';

  static const checkIn = '/collecteur/check-in';
  static const clientsDuJour = '/collecteur/clients-du-jour';
  static const dashboardIndependant = '/collecteur/dashboard-independant';
  static const verifierQr = '/collecteur-terrain/verifier-qr';
  static const initierCotisationAssistee =
      '/operations-assistees/cotisations/initier';
  static const initierRetraitAssiste = '/operations-assistees/retraits/initier';
}
