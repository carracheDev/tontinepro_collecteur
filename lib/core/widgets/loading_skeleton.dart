import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/app_colors.dart';

// ─── Brique de base ──────────────────────────────────────
class LoadingSkeleton extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const LoadingSkeleton({
    super.key,
    this.width = double.infinity,
    this.height = 14,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE2EDE7),
      highlightColor: const Color(0xFFF0F9F4),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

// ─── Carte client (liste clients) ───────────────────────
class SkeletonClientCard extends StatelessWidget {
  const SkeletonClientCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE2EDE7),
      highlightColor: const Color(0xFFF0F9F4),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 14,
                        width: 140,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 10,
                        width: 90,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 24,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: List.generate(3, (i) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i < 2 ? 8 : 0),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              )),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Fiche terrain (détail client) ──────────────────────
class SkeletonFicheTerrain extends StatelessWidget {
  const SkeletonFicheTerrain({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE2EDE7),
      highlightColor: const Color(0xFFF0F9F4),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56, height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _bloc(160, 16),
                            const SizedBox(height: 8),
                            _bloc(100, 11),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: List.generate(3, (i) => Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: i < 2 ? 8 : 0),
                        child: _bloc(double.infinity, 52, radius: 12),
                      ),
                    )),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            // Boutons grid
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.8,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: List.generate(6, (_) => _bloc(double.infinity, double.infinity, radius: 14)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bloc(double w, double h, {double radius = 8}) => Container(
    width: w,
    height: h,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}

// ─── Carte tontine ───────────────────────────────────────
class SkeletonTontineCard extends StatelessWidget {
  const SkeletonTontineCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE2EDE7),
      highlightColor: const Color(0xFFF0F9F4),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: _bloc(120, 15)),
                const SizedBox(width: 8),
                _bloc(60, 22, radius: 99),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _bloc(80, 24, radius: 8),
                const SizedBox(width: 8),
                _bloc(90, 24, radius: 8),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _bloc(70, 12),
                _bloc(80, 18),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _bloc(double w, double h, {double radius = 8}) => Container(
    width: w,
    height: h,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}

// ─── Liste générique ─────────────────────────────────────
class SkeletonListe extends StatelessWidget {
  final int nb;
  final Widget Function() builder;

  const SkeletonListe({super.key, this.nb = 4, required this.builder});

  const SkeletonListe.clients({super.key, this.nb = 4})
      : builder = _buildClient;

  static Widget _buildClient() => const SkeletonClientCard();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: nb,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, _) => builder(),
    );
  }
}

// ─── Indicateur de chargement centré (fallback simple) ───
class CentreChargement extends StatelessWidget {
  const CentreChargement({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
        strokeWidth: 2.5,
      ),
    );
  }
}
