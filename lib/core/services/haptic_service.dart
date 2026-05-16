import 'package:flutter/services.dart';

abstract class HapticService {
  /// Succès — paiement confirmé, collecte réussie, enrôlement OK
  static Future<void> succes() => HapticFeedback.mediumImpact();

  /// Erreur — paiement refusé, validation échouée
  static Future<void> erreur() => HapticFeedback.heavyImpact();

  /// Sélection légère — tap sur bouton, chip, toggle
  static Future<void> tap() => HapticFeedback.selectionClick();

  /// Validation légère — scan QR réussi, check-in GPS
  static Future<void> leger() => HapticFeedback.lightImpact();
}
