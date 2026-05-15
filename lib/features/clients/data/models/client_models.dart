class ClientResume {
  final String id;
  final String nom;
  final String telephone;
  final bool kycVerifie;
  final int solde;
  final int montantJournalierFcfa;
  final int score;
  final bool dejaVisite;

  const ClientResume({
    required this.id,
    required this.nom,
    required this.telephone,
    required this.kycVerifie,
    required this.solde,
    required this.montantJournalierFcfa,
    required this.score,
    required this.dejaVisite,
  });

  factory ClientResume.fromJson(Map<String, dynamic> j) => ClientResume(
        id: j['id'] as String,
        nom: j['nom'] as String? ?? '',
        telephone: j['telephone'] as String? ?? '',
        kycVerifie: j['kycVerifie'] as bool? ?? false,
        solde: (j['solde'] as num?)?.toInt() ?? 0,
        montantJournalierFcfa:
            (j['montantJournalierFcfa'] as num?)?.toInt() ?? 0,
        score: (j['score'] as num?)?.toInt() ?? 0,
        dejaVisite: j['dejaVisite'] as bool? ?? false,
      );
}

class ClientsDuJourStats {
  final int total;
  final int visites;
  final int restantes;

  const ClientsDuJourStats({
    required this.total,
    required this.visites,
    required this.restantes,
  });

  factory ClientsDuJourStats.fromJson(Map<String, dynamic> j) =>
      ClientsDuJourStats(
        total: (j['total'] as num?)?.toInt() ?? 0,
        visites: (j['visites'] as num?)?.toInt() ?? 0,
        restantes: (j['restantes'] as num?)?.toInt() ?? 0,
      );
}

class ClientsDuJourResult {
  final List<ClientResume> clients;
  final ClientsDuJourStats stats;

  const ClientsDuJourResult({required this.clients, required this.stats});
}

class FicheTerrain {
  final String id;
  final String nom;
  final String telephone;
  final int soldeTotal;
  final int score;
  final String? quartier;
  final String? codeQr;
  final List<Map<String, dynamic>> transactions;
  final List<Map<String, dynamic>> tontines;

  const FicheTerrain({
    required this.id,
    required this.nom,
    required this.telephone,
    required this.soldeTotal,
    required this.score,
    this.quartier,
    this.codeQr,
    required this.transactions,
    required this.tontines,
  });

  factory FicheTerrain.fromJson(Map<String, dynamic> j) {
    final client = j['client'] as Map<String, dynamic>? ?? {};
    final profile = j['terrainProfile'] as Map<String, dynamic>?;
    final qr = j['qrPapierClient'] as Map<String, dynamic>?;
    final tontines = (j['tontines'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final txs =
        (j['transactions'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final solde = tontines.fold<int>(
      0,
      (s, t) => s + ((t['soldeActuelFcfa'] as num?)?.toInt() ?? 0),
    );
    final scoreData = j['scoreCredit'] as Map<String, dynamic>?;
    return FicheTerrain(
      id: client['id'] as String? ?? '',
      nom: client['nom'] as String? ?? '',
      telephone: client['telephone'] as String? ?? '',
      soldeTotal: (j['soldeTotal'] as num?)?.toInt() ?? solde,
      score: (scoreData?['score'] as num?)?.toInt() ?? 0,
      quartier: profile?['quartier'] as String?,
      codeQr: qr?['code'] as String?,
      transactions: txs,
      tontines: tontines,
    );
  }
}
