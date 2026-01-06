import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'auth_screen.dart';

void main() => runApp(
  const MaterialApp(home: UberOnboarding(), debugShowCheckedModeBanner: false),
);

class UberOnboarding extends StatefulWidget {
  const UberOnboarding({super.key});

  @override
  State<UberOnboarding> createState() => _UberOnboardingState();
}

class _UberOnboardingState extends State<UberOnboarding> {
  final controller = PageController();
  int currentPage = 0;

  // CORRECTION : On définit la fonction ici pour qu'elle soit accessible partout
  void goToLogin() {
    Navigator.of(context).pushReplacement( // pushReplacement pour ne pas revenir à l'onboarding
      MaterialPageRoute(builder: (context) => const AuthScreen()),
    );
  }

  @override
Widget build(BuildContext context) {
  bool isLastPage = currentPage == 3;
  bool isFirstPage = currentPage == 0;

  return Scaffold(
    backgroundColor: Colors.white,
    body: Stack(
      children: [
        // 1. Le PageView en premier (tout en bas)
        PageView(
          controller: controller,
          onPageChanged: (index) => setState(() => currentPage = index),
          children: [
            buildPage(color: const Color(0xFFFFEAD2), icon: Icons.local_taxi, title: "Uber_CM Taxi", subtitle: "Déplacez-vous facilement dans toute la ville."),
            buildPage(color: const Color(0xFFFFEAD2), icon: Icons.motorcycle, title: "Uber_CM Moto", subtitle: "Évitez les embouteillages avec nos coursiers rapides."),
            buildPage(color: const Color(0xFFFFEAD2), icon: Icons.delivery_dining, title: "Livraison Rapide", subtitle: "Faites-vous livrer vos colis en un clic."),
            buildPage(color: const Color(0xFFFFEAD2), icon: Icons.verified_user, title: "Sécurité & Confiance", subtitle: "Votre sécurité est notre priorité."),
          ],
        ),

        // 2. Le bouton "Passer" (maintenant placé APRES le PageView pour être au-dessus)
        Positioned(
          top: 50,
          right: 20,
          child: TextButton(
            onPressed: () => goToLogin(), 
            style: TextButton.styleFrom(
              foregroundColor: Colors.orange, // S'assure que la couleur est bien appliquée
            ),
            child: const Text(
              "Passer",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),

        // 3. Les indicateurs et boutons du bas
        Positioned(
          bottom: 50,
          left: 0,
          right: 0,
          child: Column(
            children: [
              SmoothPageIndicator(
                controller: controller,
                count: 4,
                effect: const ExpandingDotsEffect(activeDotColor: Colors.orange, dotHeight: 8, dotWidth: 8, expansionFactor: 4),
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Opacity(
                      opacity: isFirstPage ? 0 : 1,
                      child: TextButton(
                        onPressed: isFirstPage ? null : () => controller.previousPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut),
                        child: const Text("Précédent", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      onPressed: () {
                        if (isLastPage) {
                          goToLogin();
                        } else {
                          controller.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
                        }
                      },
                      child: Text(isLastPage ? "Commencer" : "Suivant", style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

  Widget buildPage({required Color color, required IconData icon, required String title, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 200, width: 200,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, size: 80, color: Colors.orange[800]),
          ),
          const SizedBox(height: 50),
          Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 20),
          Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, color: Colors.black54, height: 1.5)),
        ],
      ),
    );
  }
}