enum RoleCollecteur {
  agent('AGENT', 'Agent salarié', 'AGENT'),
  admin('ADMIN', 'Administrateur', 'ADMIN');

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

  bool get peutCollecter => this == RoleCollecteur.agent;

  bool get peutScanner => peutCollecter;
}
