import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/favorite_service.dart';
import 'services/theme_service.dart';
import 'services/auth_service.dart';

import 'screens/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeService()),
        ChangeNotifierProvider(create: (_) => AuthService()),

      ],
      child: const GwaliorDarshan(),
    ),
  );
}

class GwaliorDarshan extends StatelessWidget {
  const GwaliorDarshan({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeService>(context);

    return FutureBuilder(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        final prefs = snapshot.data!;
        final onboardingSeen = prefs.getBool("onboarding_seen") ?? false;

        return MaterialApp(
          title: 'Gwalior Darshan',
          debugShowCheckedModeBanner: false,
          themeMode: theme.currentTheme,

          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: const Color(0xFF1746A2),
            fontFamily: 'Poppins',
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1746A2),
              secondary: Color(0xFFFFC93C),
            ),
          ),

          darkTheme: ThemeData(
            brightness: Brightness.dark,
            fontFamily: 'Poppins',
            colorScheme: const ColorScheme.dark(
              primary: Colors.white,
              secondary: Color(0xFFFFC93C),
            ),
          ),

          home: onboardingSeen ? const SplashScreen() : const OnboardingScreen(),
        );
      },
    );
  }
}
