import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyC7qmfySJIC15io9iw1_L5iVge7NZT-gGw",
            authDomain: "ailbee.firebaseapp.com",
            projectId: "ailbee",
            storageBucket: "ailbee.firebasestorage.app",
            messagingSenderId: "991527374957",
            appId: "1:991527374957:web:5ab25285c5e8e395392f64",
            measurementId: "G-BZVX7YFV83"));
  } else {
    await Firebase.initializeApp();
  }
}
