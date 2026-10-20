
import 'package:flutter/material.dart';

import 'screens/home_page.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService().initialize();

  runApp(const ShalatKuApp());
}

class ShalatKuApp extends StatelessWidget {
  const ShalatKuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShalatKu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF286B52),
        ),
        scaffoldBackgroundColor: const Color(0xFFEAF2EC),
      ),
      home: const HomePage(),
    );
  }
}
