import 'package:flutter/material.dart';
import 'package:uber_cm/navigation_menu.dart';
import 'package:uber_cm/onboarding_screen.dart';
import 'package:uber_cm/services/appwrite_service.dart';
import 'package:uber_cm/settingscreen.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); 

  @override
  Widget build(BuildContext context) {
    final appwrite = AppwriteService();

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Uber CM',
          themeMode: currentMode, 
          // THÈME CLAIR
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.orange,
            scaffoldBackgroundColor: Colors.white,
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Colors.black),
              bodyMedium: TextStyle(color: Colors.black87),
            ),
          ),
          // THÈME SOMBRE
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.orange,
            scaffoldBackgroundColor: const Color(0xFF121212),
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Colors.white),
              bodyMedium: TextStyle(color: Colors.white70),
            ),
          ),
          home: FutureBuilder(
            // On vérifie le compte au lieu de la session (plus stable pour la persistance)
            future: appwrite.account.get(), 
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.orange)));
              }

              // Si on a les données de l'utilisateur, on va à la Home
              if (snapshot.hasData && snapshot.data != null) {
                return const NavigationMenu(); 
              } else {
                return const UberOnboarding(); 
              }
            },
          ),
        );
      },
    );
  }
}
