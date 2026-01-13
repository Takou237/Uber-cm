import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // Ajoute lottie dans ton pubspec.yaml

class SearchingDriverScreen extends StatelessWidget {
  const SearchingDriverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Une petite animation sympa (tu peux utiliser une icône si tu n'as pas Lottie)
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              strokeWidth: 5,
            ),
            const SizedBox(height: 40),
            const Text(
              "Recherche d'un chauffeur...",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Nous cherchons la voiture la plus proche",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red[50]),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Annuler la recherche",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
