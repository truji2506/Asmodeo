import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/puzzle_page.dart';

void main() async {
  // Asegura que los bindings de Flutter estén inicializados antes de arrancar Firebase
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializa Firebase con las opciones generadas para web/android/ios
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const AsmodeoApp());
}

class AsmodeoApp extends StatelessWidget {
  const AsmodeoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Asmodeo - El Motor de la Creación',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Colores temáticos basados en los fragmentos de Asmodeo
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE53935), // Carmesí como base
          primary: const Color(0xFF2E7D32), // Esmeralda
          secondary: const Color(0xFF00ACC1), // Turquesa
          brightness: Brightness.dark, // El mundo de Midgard es hostil y salvaje
        ),
        useMaterial3: true,
      ),
      home: const PuzzlePage(),
    );
  }
}

