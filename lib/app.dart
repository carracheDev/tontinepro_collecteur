import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/services/fcm_service.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/offline_banner.dart';
import 'router/app_router.dart';

class TontineCollecteurApp extends ConsumerWidget {
  const TontineCollecteurApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    // Injecter le callback de navigation FCM dès que le router est disponible
    FcmService.instance.setNavigationCallback((route, {extra}) {
      router.push(route, extra: extra);
    });

    return MaterialApp.router(
      title: 'TontinePro Collecteur',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
      builder: (context, child) => OfflineBanner(
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
