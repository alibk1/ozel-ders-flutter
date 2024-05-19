import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

const firebaseConfig = {
  'apiKey': "AIzaSyAoEBxQyBErpVzHH8-jhyrSgRU5OLTnBrE",
  'authDomain': "ortakozelders.firebaseapp.com",
  'projectId': "ortakozelders",
  'storageBucket': "ortakozelders.appspot.com",
  'messagingSenderId': "619520758342",
  'appId': "1:619520758342:web:12c44b2582dbdcb9b67047",
  'measurementId': "G-MZLW5M94M2"
};

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return FirebaseOptions(
        apiKey: firebaseConfig['apiKey']!,
        authDomain: firebaseConfig['authDomain']!,
        projectId: firebaseConfig['projectId']!,
        storageBucket: firebaseConfig['storageBucket']!,
        messagingSenderId: firebaseConfig['messagingSenderId']!,
        appId: firebaseConfig['appId']!,
        measurementId: firebaseConfig['measurementId'],
      );
    }
    throw UnsupportedError('DefaultFirebaseOptions are not supported for this platform.');
  }
}