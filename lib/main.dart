import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app/shell.dart';
import 'app/theme.dart';

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
      title: 'Asmodeo · El Motor de la Creación',
      debugShowCheckedModeBanner: false,
      theme: asmodeoTheme(),
      // Nueva experiencia (wireframes definitivos). El prototipo anterior
      // sigue en lib/pages/puzzle_page.dart por si se necesita.
      home: const AsmodeoShell(),
    );
  }
}
