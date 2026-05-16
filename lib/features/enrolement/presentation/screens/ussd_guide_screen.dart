import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';

class UssdGuideScreen extends StatelessWidget {
  const UssdGuideScreen({super.key});

  static const _codes = [
    ('Consulter solde', '*155*1#'),
    ('Cotiser MTN', '*155*2*1#'),
    ('Cotiser Moov', '*155*2*2#'),
    ('Historique', '*155*3#'),
    ('Aide', '*155*0#'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fond,
      appBar: AppBar(
        title: const Text('Codes USSD'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.texte,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Communiquez ces codes au client sans smartphone.',
            style: AppTextStyles.corpsSecond,
          ),
          const SizedBox(height: 16),
          ..._codes.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.$1, style: AppTextStyles.titre3),
                          Text(e.$2, style: AppTextStyles.montantPetit),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: e.$2));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${e.$2} copié')),
                        );
                      },
                      icon: const Icon(Icons.copy, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
