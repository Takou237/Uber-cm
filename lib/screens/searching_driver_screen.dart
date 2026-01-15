import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // Import maintenant utilisé !

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
            // UTILISATION DE LOTTIE POUR UNE ANIMATION DE CARTE/RADAR
            // Tu peux trouver des JSON sur lottiefiles.com
            Lottie.network(
              'https://assets9.lottiefiles.com/packages/lf20_6sxyjyjj.json', // Exemple d'animation de radar
              height: 200,
              repeat: true,
            ),
            
            const SizedBox(height: 20),
            
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[50],
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
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
