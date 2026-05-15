import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../router/app_router.dart';

class _SlideData {
  final Color headerBg;
  final IconData headerIcon;
  final String title;
  final String subtitle;
  final List<({IconData icon, Color iconColor, Color bg, String title, String desc})>
      items;

  const _SlideData({
    required this.headerBg,
    required this.headerIcon,
    required this.title,
    required this.subtitle,
    required this.items,
  });
}

const _slides = [
  _SlideData(
    headerBg: AppColors.primaryDark,
    headerIcon: Icons.monetization_on_outlined,
    title: 'Collectez sans toucher le cash.',
    subtitle:
        'Mobile Money uniquement. Le client paie sur son téléphone, vous recevez la confirmation.',
    items: [
      (
        icon: Icons.verified_user_outlined,
        iconColor: AppColors.primary,
        bg: AppColors.primaryLight,
        title: 'Zéro manipulation d\'argent',
        desc:
            'Vous initiez, le client confirme sur MTN/Moov. Traçabilité totale.',
      ),
      (
        icon: Icons.bolt_outlined,
        iconColor: AppColors.info,
        bg: Color(0xFFEFF6FF),
        title: 'Collecte en moins de 30 secondes',
        desc: 'QR ou saisie manuelle, même sans smartphone client.',
      ),
    ],
  ),
  _SlideData(
    headerBg: AppColors.info,
    headerIcon: Icons.shield_outlined,
    title: 'L\'OTP protège votre client.',
    subtitle:
        'Chaque retrait et cotisation sensible envoie un code sur le téléphone du client.',
    items: [
      (
        icon: Icons.sms_outlined,
        iconColor: AppColors.attention,
        bg: Color(0xFFFFFBEB),
        title: 'OTP sur téléphone client uniquement',
        desc: 'Le collecteur ne reçoit jamais l\'OTP. Anti-fraude absolu.',
      ),
      (
        icon: Icons.lock_outline,
        iconColor: Color(0xFF7C3AED),
        bg: Color(0xFFF5F3FF),
        title: 'PIN + biométrie collecteur',
        desc: 'Double vérification avant chaque session terrain.',
      ),
    ],
  ),
  _SlideData(
    headerBg: Color(0xFF7C3AED),
    headerIcon: Icons.radar_outlined,
    title: 'Supervisez toute votre zone.',
    subtitle:
        'Carte agents, performances, litiges et anomalies — tout en temps réel.',
    items: [
      (
        icon: Icons.location_on_outlined,
        iconColor: AppColors.primary,
        bg: AppColors.primaryLight,
        title: 'GPS & check-in agent',
        desc: 'Preuve de présence terrain enregistrée automatiquement.',
      ),
      (
        icon: Icons.bar_chart_outlined,
        iconColor: AppColors.info,
        bg: Color(0xFFEFF6FF),
        title: 'Score PADME automatique',
        desc: 'Calculé chaque nuit. Dossiers PADME générés.',
      ),
    ],
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _page = 0;

  Future<void> _terminer() async {
    await SecureStorage.marquerOnboardingVu();
    if (mounted) context.go(Routes.auth);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView.builder(
        controller: _pageCtrl,
        onPageChanged: (i) => setState(() => _page = i),
        itemCount: _slides.length,
        itemBuilder: (_, i) => _SlidePage(
          data: _slides[i],
          page: _page,
          total: _slides.length,
          onSuivant: () {
            if (_page < _slides.length - 1) {
              _pageCtrl.nextPage(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeInOut,
              );
            } else {
              _terminer();
            }
          },
          onPrecedent: _page > 0
              ? () => _pageCtrl.previousPage(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeInOut,
                  )
              : null,
        ),
      ),
    );
  }
}

class _SlidePage extends StatelessWidget {
  final _SlideData data;
  final int page;
  final int total;
  final VoidCallback onSuivant;
  final VoidCallback? onPrecedent;

  const _SlidePage({
    required this.data,
    required this.page,
    required this.total,
    required this.onSuivant,
    this.onPrecedent,
  });

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final isLast = page == total - 1;

    return Column(
      children: [
        Container(
          height: h * 0.46,
          width: double.infinity,
          color: data.headerBg,
          padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
          child: Stack(
            children: [
              Positioned(
                right: -60,
                top: -60,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(data.headerIcon, color: Colors.white, size: 36),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    data.title,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    data.subtitle,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.85),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    itemCount: data.items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final it = data.items[i];
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: it.bg,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(it.icon, color: it.iconColor, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  it.title,
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  it.desc,
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    color: AppColors.muted,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Row(
                  children: [
                    Row(
                      children: List.generate(
                        total,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 6),
                          width: i == page ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: i == page
                                ? AppColors.primary
                                : const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (onPrecedent != null)
                      TextButton(
                        onPressed: onPrecedent,
                        child: const Text('←'),
                      ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: onSuivant,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 44),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                      child: Text(isLast ? 'COMMENCER' : 'Suivant'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
