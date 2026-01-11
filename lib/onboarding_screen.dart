import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:uber_cm/role_selection_screen.dart';
import 'package:uber_cm/profile_screen.dart'; // Pour accéder au themeNotifier si besoin

class UberOnboarding extends StatefulWidget {
  const UberOnboarding({super.key});

  @override
  State<UberOnboarding> createState() => _UberOnboardingState();
}

class _UberOnboardingState extends State<UberOnboarding> {
  final controller = PageController();
  int currentPage = 0;

  void goToRoleSelection() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. DÉTECTION DU MODE SOMBRE
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    // 2. COULEURS DYNAMIQUES
    final bgColor = isDark ? const Color(0xFF121212) : Colors.white;
    final titleColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.white70 : Colors.black54;
    final circleColor = isDark ? Colors.orange.withOpacity(0.2) : const Color(0xFFFFEAD2);

    bool isLastPage = currentPage == 3;
    bool isFirstPage = currentPage == 0;

    return Scaffold(
      backgroundColor: bgColor, // Utilisation de la couleur dynamique
      body: Stack(
        children: [
          PageView(
            controller: controller,
            onPageChanged: (index) => setState(() => currentPage = index),
            children: [
              buildPage(
                color: circleColor,
                icon: Icons.local_taxi,
                title: "Uber_CM Taxi",
                subtitle: "Déplacez-vous facilement dans toute la ville.",
                tColor: titleColor,
                sColor: subtitleColor,
              ),
              buildPage(
                color: circleColor,
                icon: Icons.motorcycle,
                title: "Uber_CM Moto",
                subtitle: "Évitez les embouteillages avec nos coursiers rapides.",
                tColor: titleColor,
                sColor: subtitleColor,
              ),
              buildPage(
                color: circleColor,
                icon: Icons.delivery_dining,
                title: "Livraison Rapide",
                subtitle: "Faites-vous livrer vos colis en un clic.",
                tColor: titleColor,
                sColor: subtitleColor,
              ),
              buildPage(
                color: circleColor,
                icon: Icons.verified_user,
                title: "Sécurité & Confiance",
                subtitle: "Votre sécurité est notre priorité.",
                tColor: titleColor,
                sColor: subtitleColor,
              ),
            ],
          ),

          Positioned(
            top: 50,
            right: 20,
            child: TextButton(
              onPressed: () => goToRoleSelection(),
              style: TextButton.styleFrom(foregroundColor: Colors.orange),
              child: const Text(
                "Passer",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),

          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                SmoothPageIndicator(
                  controller: controller,
                  count: 4,
                  effect: ExpandingDotsEffect(
                    activeDotColor: Colors.orange,
                    dotColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                    dotHeight: 8,
                    dotWidth: 8,
                    expansionFactor: 4,
                  ),
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
                          onPressed: isFirstPage
                              ? null
                              : () => controller.previousPage(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                ),
                          child: Text(
                            "Précédent",
                            style: TextStyle(
                              color: isDark ? Colors.white54 : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

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
                        ),
                        onPressed: () {
                          if (isLastPage) {
                            goToRoleSelection();
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

  Widget buildPage({
    required Color color,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color tColor,
    required Color sColor,
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
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: tColor, // Dynamique
            ),
          ),
          const SizedBox(height: 20),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: sColor, // Dynamique
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}