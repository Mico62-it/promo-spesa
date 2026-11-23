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
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F766E), // Verde petrolio / smeraldo elegante
          primary: const Color(0xFF0F766E),
          secondary: const Color(0xFFF97316), // Arancione caldo per badge sconti
          surface: const Color(0xFFF8FAFC), // Grigio/bianco pulito
          surfaceTint: Colors.transparent,
        ),
        scaffoldBackgroundColor: const Color(0xFFF1F5F9), // Sfondo moderno e morbido
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF0F172A),
          titleTextStyle: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0F766E),
            foregroundColor: Colors.white,
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: Colors.grey.shade200, width: 1.2),
          ),
          color: Colors.white,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
