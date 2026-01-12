import 'package:flutter/material.dart';
import 'package:uber_cm/navigation_menu.dart';
import 'package:uber_cm/onboarding_screen.dart';
import 'package:uber_cm/services/appwrite_service.dart';
import 'package:uber_cm/settingscreen.dart';
import 'package:uber_cm/driver_placeholder_screen.dart'; // Import de l'interface chauffeur

void main() async {
  // S'assurer que les services Flutter sont prêts
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Fonction pour déterminer l'écran de destination selon l'état de l'utilisateur
  Future<Widget> _getInitialScreen() async {
    final appwrite = AppwriteService();
    try {
      // 1. Vérifier si une session existe
      final user = await appwrite.account.get();

      // 2. Récupérer le rôle de l'utilisateur dans la base de données
      // On suppose que tu as une méthode getProfile dans ton AppwriteService
      final profile = await appwrite.getUserProfile(user.$id);
      final role = profile?.data['role'] ?? 'client';

      // 3. Rediriger selon le rôle
      if (role == 'chauffeur') {
        return const DriverPlaceholderScreen();
      } else {
        return const NavigationMenu();
      }
    } catch (e) {
      // Si erreur (pas de session, pas d'internet), retour à l'onboarding
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

          // DESIGN THÈME CLAIR
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

          // DESIGN THÈME SOMBRE
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
              // Écran de chargement (Splash) pendant la vérification
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                  backgroundColor: currentMode == ThemeMode.dark
                      ? const Color(0xFF121212)
                      : Colors.white,
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Tu peux remplacer par ton logo image
                        const Icon(
                          Icons.local_taxi,
                          size: 80,
                          color: Colors.orange,
                        ),
                        const SizedBox(height: 20),
                        const CircularProgressIndicator(color: Colors.orange),
                      ],
                    ),
                  ),
                );
              }

              // Retourne l'écran calculé ou l'onboarding par défaut
              return snapshot.data ?? const UberOnboarding();
            },
          ),
        );
      },
    );
  }
}
