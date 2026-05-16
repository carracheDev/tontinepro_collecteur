import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';

class CarteTerrainScreen extends StatelessWidget {
  final List<dynamic> clients;
  const CarteTerrainScreen({super.key, required this.clients});

  @override
  Widget build(BuildContext context) {
    final visites = clients.where(_dejaVisite).length;

    return Scaffold(
      backgroundColor: AppColors.fond,
      appBar: AppBar(
        title: const Text('Carte terrain'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.texte,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Positions rafraichies')),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          Container(
            height: 260,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFDCFCE7), AppColors.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            clipBehavior: Clip.antiAlias,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    Positioned.fill(child: CustomPaint(painter: _GridPainter())),
                    for (final c in clients)
                      Positioned(
                        left: constraints.maxWidth * _left(c),
                        top: constraints.maxHeight * _top(c),
                        child: _MapPin(client: c),
                      ),
                    Positioned(
                      left: constraints.maxWidth / 2 - 19,
                      top: constraints.maxHeight / 2 - 19,
                      child: const _MePin(),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _StatCard(valeur: '$visites', label: 'Visites')),
              const SizedBox(width: 8),
              Expanded(
                child: _StatCard(
                  valeur: '${clients.length - visites}',
                  label: 'A visiter',
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(child: _StatCard(valeur: '500m', label: 'Rayon max')),
            ],
          ),
          const SizedBox(height: 14),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Carte terrain simulee', style: AppTextStyles.titre3),
                const SizedBox(height: 6),
                Text(
                  'Vue de votre zone de collecte. Les pins indiquent la position approximative de vos clients.',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ...clients.map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                padding: EdgeInsets.zero,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _couleur(c).withValues(alpha: 0.14),
                    child: Text(
                      Formatters.initiales(_nom(c)),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w800,
                        color: _couleur(c),
                      ),
                    ),
                  ),
                  title: Text(_nom(c), style: AppTextStyles.corps),
                  subtitle: Text(_telephone(c), style: AppTextStyles.caption),
                  trailing: _StatusBadge(visite: _dejaVisite(c)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _nom(dynamic c) {
    final nom = (c.nom as String?)?.trim() ?? '';
    return nom.isEmpty ? 'Client' : nom;
  }
  static String _telephone(dynamic c) => (c.telephone as String?) ?? '';
  static bool _dejaVisite(dynamic c) => (c.dejaVisite as bool?) ?? false;

  static double _left(dynamic c) =>
      ((_nom(c).hashCode.abs() % 70) + 10) / 100;

  static double _top(dynamic c) =>
      ((_telephone(c).hashCode.abs() % 60) + 15) / 100;

  static Color _couleur(dynamic c) {
    if (_telephone(c).trim().isEmpty) return AppColors.annuler;
    return _dejaVisite(c) ? AppColors.primary : AppColors.attention;
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.28)
      ..strokeWidth = 1;
    for (var x = 0.0; x <= size.width; x += size.width / 5) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y <= size.height; y += size.height / 4) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MapPin extends StatelessWidget {
  final dynamic client;
  const _MapPin({required this.client});

  @override
  Widget build(BuildContext context) {
    final nom = CarteTerrainScreen._nom(client);
    return Transform.rotate(
      angle: -pi / 4,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: CarteTerrainScreen._couleur(client),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
            bottomRight: Radius.circular(8),
          ),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Transform.rotate(
          angle: pi / 4,
          child: Center(
            child: Text(
              Formatters.initiales(nom),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MePin extends StatelessWidget {
  const _MePin();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
      ),
      child: const Center(
        child: Text(
          'Moi',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String valeur;
  final String label;

  const _StatCard({required this.valeur, required this.label});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Column(
        children: [
          Text(valeur, style: AppTextStyles.montantPetit),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool visite;
  const _StatusBadge({required this.visite});

  @override
  Widget build(BuildContext context) {
    final color = visite ? AppColors.primary : AppColors.attention;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        visite ? 'Visite' : 'A visiter',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}
