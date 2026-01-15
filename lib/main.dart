import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber_cm/navigation_menu.dart';
import 'package:uber_cm/onboarding_screen.dart';
import 'package:uber_cm/providers/user_provider.dart';
import 'package:uber_cm/services/appwrite_service.dart';
import 'package:uber_cm/settingscreen.dart';
import 'package:uber_cm/driver_placeholder_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()..initUser()),
        // Tu pourras ajouter un RideProvider plus tard ici
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getInitialScreen() async {
    final appwrite = AppwriteService();
    try {
      final user = await appwrite.account.get();
      final profile = await appwrite.getUserProfile(user.$id);
      final role = profile?.data['role'] ?? 'client';

      if (role == 'chauffeur') {
        return const DriverPlaceholderScreen();
      } else {
        return const NavigationMenu();
      }
    } catch (e) {
      debugPrint("Utilisateur non connecté ou erreur : $e");
      return const UberOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Uber CM',
          themeMode: currentMode,

          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorSchemeSeed: Colors.orange,
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.black),
            ),
          ),

          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorSchemeSeed: Colors.orange,
            scaffoldBackgroundColor: const Color(0xFF121212),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF121212),
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.white),
            ),
          ),

          home: FutureBuilder<Widget>(
            future: _getInitialScreen(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                  backgroundColor: currentMode == ThemeMode.dark
                      ? const Color(0xFF121212)
                      : Colors.white,
                  // AJOUT DU CONST ICI
                  body: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.local_taxi,
                          size: 80,
                          color: Colors.orange,
                        ),
                        SizedBox(height: 20),
                        CircularProgressIndicator(color: Colors.orange),
                      ],
                    ),
                  ),
                );
              }

              return snapshot.data ?? const UberOnboarding();
            },
          ),
        );
      },
    );
  }
}
