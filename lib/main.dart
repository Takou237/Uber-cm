import 'package:flutter/material.dart';
import 'package:uber_cm/onboarding_screen.dart';
import 'package:uber_cm/services/appwrite_service.dart';
import 'package:uber_cm/home_screen.dart';
import 'package:uber_cm/profile_screen.dart'; // Import important pour accéder au themeNotifier

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp()); 
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AppwriteService _appwrite = AppwriteService();

    // On enveloppe MaterialApp avec ValueListenableBuilder pour écouter le changement de thème
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier, // La variable que nous avons créée dans profile_screen.dart
      builder: (context, currentMode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Uber CM',
          
          // --- CONFIGURATION DU THÈME ---
          themeMode: currentMode, // Utilise le mode (Light ou Dark)
          theme: ThemeData(
            primarySwatch: Colors.orange,
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF5F5F5),
          ),
          darkTheme: ThemeData(
            primarySwatch: Colors.orange,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF121212),
          ),
          // ------------------------------

          home: FutureBuilder(
            future: _appwrite.account.get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(color: Colors.orange),
                  ),
                );
              }

              if (snapshot.hasData) {
                return const HomeScreen(); 
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