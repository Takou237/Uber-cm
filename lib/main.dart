import 'package:flutter/material.dart';
import 'package:uber_cm/onboarding_screen.dart';
import 'package:uber_cm/services/appwrite_service.dart';
import 'package:uber_cm/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp()); // Retrait du const ici
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AppwriteService _appwrite = AppwriteService();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Uber CM',
      theme: ThemeData(primarySwatch: Colors.orange),
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
            return HomeScreen(); // Retrait du const si nécessaire
          } else {
            return UberOnboarding(); // Retrait du const ici
          }
        },
      ),
    );
  }
}
