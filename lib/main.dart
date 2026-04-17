import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/splash_screen.dart';
import 'services/app_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NecHubApp());
}

class NecHubApp extends StatelessWidget {
  const NecHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'NEC HUB',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF7F8F3),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1B8A5A),
            primary: const Color(0xFF1B8A5A),
            secondary: const Color(0xFFF28C28),
            surface: Colors.white,
          ),
          textTheme: ThemeData.light().textTheme.apply(
                bodyColor: const Color(0xFF222B2D),
                displayColor: const Color(0xFF222B2D),
              ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
