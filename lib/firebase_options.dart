// ⚠️  FICHIER STUB — À REMPLACER par la vraie config Firebase.
//
// ÉTAPES :
//   1. Créer un projet Firebase sur https://console.firebase.google.com
//   2. Installer flutterfire CLI :  dart pub global activate flutterfire_cli
//   3. Depuis tontinepro_collecteur/ :  flutterfire configure
//   4. Ce fichier sera regénéré automatiquement avec les vraies clés.
//   5. Télécharger google-services.json → android/app/google-services.json
//   6. Télécharger GoogleService-Info.plist → ios/Runner/GoogleService-Info.plist

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'Plateforme non supportée. Lancez flutterfire configure.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAGmDcAvC4Mveb7-B2DiFYv0wp49azZ1ZA',
    appId: '1:786925071755:android:9e31fb71d1bceabe50538e',
    messagingSenderId: '786925071755',
    projectId: 'tontinebenin-7eb46',
    storageBucket: 'tontinebenin-7eb46.firebasestorage.app',
  );

  // TODO: Remplacer toutes ces valeurs après flutterfire configure

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB7KGHHPeuQx1ZN14Z7QaKz5G7SQ5QktN0',
    appId: '1:786925071755:ios:673f33a74a47bb5f50538e',
    messagingSenderId: '786925071755',
    projectId: 'tontinebenin-7eb46',
    storageBucket: 'tontinebenin-7eb46.firebasestorage.app',
    iosBundleId: 'com.tontinepro.tontineproCollecteur',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'VOTRE_API_KEY_WEB',
    appId: 'VOTRE_APP_ID_WEB',
    messagingSenderId: 'VOTRE_SENDER_ID',
    projectId: 'VOTRE_PROJECT_ID',
    storageBucket: 'VOTRE_PROJECT_ID.appspot.com',
    authDomain: 'VOTRE_PROJECT_ID.firebaseapp.com',
  );
}