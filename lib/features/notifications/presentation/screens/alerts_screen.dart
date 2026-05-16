import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../../data/repositories/notifications_repository.dart';

final notificationsProvider = FutureProvider.autoDispose((ref) async {
  return ref.read(notificationsRepositoryProvider).lister();
});

class AlertsScreen extends ConsumerStatefulWidget {
  const AlertsScreen({super.key});

  @override
  ConsumerState<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends ConsumerState<AlertsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.fond,
      appBar: AppBar(
        title: const Text('Alertes'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.texte,
        bottom: TabBar(
          controller: _tabs,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.muted,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Mes alertes'),
            Tab(text: 'SMS clients'),
          ],
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(notificationsProvider);
          await ref.read(notificationsProvider.future);
        },
        child: async.when(
          loading: () => ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: 5,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (_, _) => const LoadingSkeleton(height: 72, radius: 16),
        ),
        error: (e, _) => EmptyStateWidget(
          icone: Icons.notifications_off_outlined,
          titre: 'Impossible de charger',
          sousTitre: e.toString(),
          labelBouton: 'Réessayer',
          onAction: () => ref.invalidate(notificationsProvider),
        ),
        data: (items) => TabBarView(
          controller: _tabs,
          children: [
            _ListeNotifs(items: items.where((n) => !n.estSmsClient).toList()),
            _ListeSms(items: items.where((n) => n.estSmsClient).toList()),
          ],
        ),
      ),
      ),
    );
  }
}

class _ListeNotifs extends StatelessWidget {
  final List<NotificationItem> items;
  const _ListeNotifs({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Text('Aucune alerte', style: AppTextStyles.corpsSecond),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final n = items[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: AppCard(
            child: ListTile(
              leading: Icon(
                n.lu ? Icons.notifications_none : Icons.notifications_active,
                color: AppColors.primary,
              ),
              title: Text(n.titre, style: AppTextStyles.corps),
              subtitle: Text(
                '${n.date.hour.toString().padLeft(2, '0')}:${n.date.minute.toString().padLeft(2, '0')}',
                style: AppTextStyles.caption,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ListeSms extends StatelessWidget {
  final List<NotificationItem> items;
  const _ListeSms({required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.attention.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            '⚠️ Contenu SMS jamais affiché — type et heure uniquement.',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.attention,
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          Text('Aucun SMS récent', style: AppTextStyles.corpsSecond)
        else
          ...items.map(
            (n) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppCard(
                child: Row(
                  children: [
                    const Icon(Icons.sms, color: AppColors.info),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(n.type, style: AppTextStyles.titre3),
                          Text(
                            '${n.date.day}/${n.date.month} — ${n.date.hour}h${n.date.minute.toString().padLeft(2, '0')}',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
