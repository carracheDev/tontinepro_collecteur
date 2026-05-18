import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/local_db/sync_service.dart';
import 'core/network/dio_client.dart';
import 'core/services/fcm_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Firebase + FCM (init avant runApp)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FcmService.instance.init();

  // Sync offline : rejoue la file d'attente dès le retour de connexion
  SyncService.instance.demarrer(DioClient.instance);

  runApp(const ProviderScope(child: TontineCollecteurApp()));
}
