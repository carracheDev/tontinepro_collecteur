import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../router/app_router.dart';
import '../providers/enrolement_provider.dart';

class EnrollScreen extends ConsumerWidget {
  const EnrollScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(enrolementProvider);
    final notifier = ref.read(enrolementProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.fond,
      appBar: AppBar(
        title: const Text('Enrôlement client'),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
      ),
      body: Stepper(
        currentStep: state.etape,
        onStepContinue: state.etape < 3
            ? () => notifier.suivant()
            : () async {
                final r = await notifier.soumettre();
                if (r != null && context.mounted) {
                  context.pushReplacement(
                    Routes.enrolementSucces,
                    extra: {
                      'nom': r.nom,
                      'clientId': r.clientId,
                      'codeQr': r.codeQr,
                      'identifiantTerrain': r.identifiantTerrain,
                    },
                  );
                }
              },
        onStepCancel:
            state.etape > 0 ? () => notifier.precedent() : null,
        controlsBuilder: (ctx, details) => Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Row(
            children: [
              if (details.stepIndex > 0)
                TextButton(
                  onPressed: details.onStepCancel,
                  child: const Text('Retour'),
                ),
              const Spacer(),
              AppButton(
                label: details.stepIndex == 3 ? 'Enrôler' : 'Suivant',
                loading: state.loading,
                fullWidth: false,
                onPressed: details.onStepContinue,
              ),
            ],
          ),
        ),
        steps: [
          Step(
            title: const Text('Infos'),
            isActive: state.etape >= 0,
            content: Column(
              children: [
                AppTextField(
                  label: 'Nom complet',
                  onChanged: notifier.setNom,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Téléphone (+229)',
                  keyboardType: TextInputType.phone,
                  prefixText: '+229 ',
                  onChanged: notifier.setTelephone,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Quartier',
                  onChanged: notifier.setQuartier,
                ),
              ],
            ),
          ),
          Step(
            title: const Text('KYC'),
            isActive: state.etape >= 1,
            content: AppTextField(
              label: 'CIP (optionnel)',
              onChanged: notifier.setCip,
            ),
          ),
          Step(
            title: const Text('Tontine'),
            isActive: state.etape >= 2,
            content: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: state.typeTontine,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'PERSONNEL',
                      child: Text('Personnel'),
                    ),
                    DropdownMenuItem(value: 'GROUPE', child: Text('Groupe')),
                    DropdownMenuItem(value: 'PROJET', child: Text('Projet')),
                  ],
                  onChanged: (v) {
                    if (v != null) notifier.setTypeTontine(v);
                  },
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Montant journalier (FCFA)',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (v) =>
                      notifier.setMontant(int.tryParse(v) ?? 500),
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Consentement'),
            isActive: state.etape >= 3,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CheckboxListTile(
                  value: state.consentement,
                  onChanged: (v) => notifier.setConsentement(v ?? false),
                  title: const Text(
                    'Le client consent à l\'enrôlement terrain',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 13),
                  ),
                  activeColor: AppColors.primary,
                ),
                if (state.erreur != null)
                  Text(state.erreur!, style: const TextStyle(color: AppColors.annuler)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
