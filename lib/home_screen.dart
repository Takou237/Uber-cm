import 'package:flutter/material.dart';
import 'package:uber_cm/services/appwrite_service.dart';
import 'package:uber_cm/login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppwriteService _appwrite = AppwriteService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Uber CM"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _appwrite.account.deleteSession(sessionId: 'current');
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: const Center(child: Text("Bienvenue sur l'accueil !")),
    );
  }
}
