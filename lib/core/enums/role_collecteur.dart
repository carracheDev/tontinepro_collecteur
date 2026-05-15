enum RoleCollecteur {
  agent('AGENT', 'Agent salarié', 'AGENT'),
  independant('INDEPENDANT', 'Collecteur indépendant', 'INDÉP.'),
  superviseur('SUPERVISEUR', 'Superviseur de zone', 'SUPERVISEUR');

  final String apiValue;
  final String label;
  final String badge;

  const RoleCollecteur(this.apiValue, this.label, this.badge);

  static RoleCollecteur? depuisApi(String? role) {
    if (role == null) return null;
    for (final r in RoleCollecteur.values) {
      if (r.apiValue == role.toUpperCase()) return r;
    }
    return null;
  }

  bool get peutCollecter =>
      this == RoleCollecteur.agent || this == RoleCollecteur.independant;

  bool get peutScanner => peutCollecter;
}
