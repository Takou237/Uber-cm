import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

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
  int currentPage = 0; // Pour suivre la page actuelle

  // Fonction utilitaire pour aller à la page de connexion
  void _goToLogin() {
    print("Navigation vers la page de Connexion / Inscription");
    // Plus tard : Navigator.pushNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    bool isLastPage = currentPage == 3; // On a 4 pages (0, 1, 2, 3)
    bool isFirstPage = currentPage == 0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Bouton "PASSER" en haut à droite
          Positioned(
            top: 50,
            right: 20,
            child: TextButton(
              onPressed: _goToLogin,
              child: const Text(
                "Passer",
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),

          // 2. Les pages de l'Onboarding
          PageView(
            controller: controller,
            onPageChanged: (index) => setState(() => currentPage = index),
            children: [
              buildPage(
                color: const Color(0xFFFFEAD2),
                icon: Icons.local_taxi,
                title: "Uber_CM Taxi",
                subtitle:
                    "Déplacez-vous facilement dans toute la ville. Réservez en quelques secondes.",
              ),
              buildPage(
                color: const Color(0xFFFFEAD2),
                icon: Icons.motorcycle,
                title: "Uber_CM Moto",
                subtitle:
                    "Évitez les embouteillages avec nos coursiers rapides.",
              ),
              buildPage(
                color: const Color(0xFFFFEAD2),
                icon: Icons.delivery_dining,
                title: "Livraison Rapide",
                subtitle:
                    "Faites-vous livrer vos colis et repas en un clic. Service fiable et sécurisé.",
              ),
              buildPage(
                color: const Color(0xFFFFEAD2),
                icon: Icons.verified_user,
                title: "Sécurité & Confiance",
                subtitle:
                    "Des chauffeurs vérifiés pour des trajets en toute sérénité. Votre sécurité est notre priorité.",
              ),
            ],
          ),

          // 3. Barre de navigation basse (Indicateurs + Boutons)
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Indicateur de points
                SmoothPageIndicator(
                  controller: controller,
                  count: 4, // Mis à jour à 4
                  effect: const ExpandingDotsEffect(
                    activeDotColor: Colors.orange,
                    dotHeight: 8,
                    dotWidth: 8,
                    expansionFactor: 4,
                  ),
                ),
                const SizedBox(height: 40),

                // Rangée des boutons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Bouton PRÉCÉDENT (Invisible sur la première page)
                      Opacity(
                        opacity: isFirstPage ? 0 : 1,
                        child: TextButton(
                          onPressed: isFirstPage
                              ? null
                              : () => controller.previousPage(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                ),
                          child: const Text(
                            "Précédent",
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      // Bouton SUIVANT / COMMENCER
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 2,
                        ),
                        onPressed: () {
                          if (isLastPage) {
                            _goToLogin();
                          } else {
                            controller.nextPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        child: Text(
                          isLastPage ? "Commencer" : "Suivant",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
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

  // Composant visuel pour chaque page (inchangé mais nettoyé)
  Widget buildPage({
    required Color color,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 200,
            width: 200,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, size: 80, color: Colors.orange[800]),
          ),
          const SizedBox(height: 50),
          Text(
            title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
