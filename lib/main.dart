import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyBF921Edlni3sWRb8njnOKbK248Y8YKxyE",
          authDomain: "promo-spesa.firebaseapp.com",
          projectId: "promo-spesa",
          storageBucket: "promo-spesa.firebasestorage.app",
          messagingSenderId: "264302392727",
          appId: "1:264302392727:web:91350dc22acb1efdab40d2",
          measurementId: "G-JHD0KJG5QP",
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
  } catch (e) {
    debugPrint('Errore inizializzazione Firebase: $e');
  }
  runApp(const PromoSpesaApp());
}

class PromoSpesaApp extends StatelessWidget {
  const PromoSpesaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PromoSpesa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5), // Blu moderno
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
