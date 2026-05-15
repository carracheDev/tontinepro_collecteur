import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/home_header.dart';
import '../../../../router/app_router.dart';
import '../../../clients/presentation/providers/clients_provider.dart';
import '../providers/collecte_provider.dart';

class CollecteScreen extends ConsumerStatefulWidget {
  const CollecteScreen({super.key});

  @override
  ConsumerState<CollecteScreen> createState() => _CollecteScreenState();
}

class _CollecteScreenState extends ConsumerState<CollecteScreen> {
  final _montantCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
      ref.read(collecteFormProvider.notifier).initialiser(extra);
      final m = extra?['montant'];
      if (m != null) {
        _montantCtrl.text = m.toString();
        ref.read(collecteFormProvider.notifier).setMontant((m as num).toInt());
      }
    });
  }

  @override
  void dispose() {
    _montantCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(collecteFormProvider);
    final clientsAsync = ref.watch(clientsDuJourProvider);

    return Scaffold(
      backgroundColor: AppColors.fond,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const HomeHeader(
                sousTitre: 'Cotisation Mobile Money assistée',
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (form.clientNom != null)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          'Client : ${form.clientNom}',
                          style: AppTextStyles.titre3,
                        ),
                      )
                    else
                      clientsAsync.when(
                        data: (data) => DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Sélectionner un client',
                            border: OutlineInputBorder(),
                          ),
                          items: data.clients
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(c.nom),
                                ),
                              )
                              .toList(),
                          onChanged: (id) {
                            final c = data.clients.firstWhere((x) => x.id == id);
                            ref
                                .read(collecteFormProvider.notifier)
                                .setClient(c.id, c.nom);
                          },
                        ),
                        loading: () => const LinearProgressIndicator(),
                        error: (_, _) => const SizedBox.shrink(),
                      ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _montantCtrl,
                      label: 'Montant (FCFA)',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (v) => ref
                          .read(collecteFormProvider.notifier)
                          .setMontant(int.tryParse(v) ?? 0),
                    ),
                    const SizedBox(height: 16),
                    Text('Opérateur', style: AppTextStyles.titre3),
                    const SizedBox(height: 8),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'MTN', label: Text('MTN')),
                        ButtonSegment(value: 'MOOV', label: Text('Moov')),
                        ButtonSegment(
                          value: 'CELTIIS',
                          label: Text('Celtiis'),
                        ),
                      ],
                      selected: {form.operateur},
                      onSelectionChanged: (s) => ref
                          .read(collecteFormProvider.notifier)
                          .setOperateur(s.first),
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      label: 'Continuer — biométrie',
                      onPressed: form.clientId == null || form.montant < 100
                          ? null
                          : () => context.push(
                                Routes.collecteBiometrie,
                                extra: {
                                  'clientId': form.clientId,
                                  'clientNom': form.clientNom,
                                  'tontineId': form.tontineId,
                                  'montant': form.montant,
                                  'operateur': form.operateur,
                                },
                              ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
