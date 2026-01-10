import 'package:flutter/material.dart';
import 'package:uber_cm/auth_screen.dart'; // Vers ton formulaire d'inscription
import 'package:uber_cm/login_screen.dart'; // Vers ton formulaire de connexion
import 'package:uber_cm/driver_placeholder_screen.dart'; // Vers la page de maintenance

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // LOGO DE L'APPLICATION
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 100,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.directions_car, 
                    size: 80, 
                    color: Colors.orange
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                "Comment voulez-vous\nutiliser Uber_CM ?",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Choisissez le mode qui vous convient le mieux.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),

              // CARTE PASSAGER (Disponible)
              _buildRoleCard(
                context,
                title: "Passager",
                roleValue: "client",
                subtitle: "Commander une course et voyager",
                icon: Icons.person_pin_circle,
                color: Colors.orange[50]!,
                iconColor: Colors.orange[800]!,
              ),
              const SizedBox(height: 16),

              // CARTE CHAUFFEUR (En développement)
              _buildRoleCard(
                context,
                title: "Chauffeur",
                roleValue: "chauffeur",
                subtitle: "Gagner de l'argent en conduisant",
                icon: Icons.local_taxi,
                color: Colors.blue[50]!,
                iconColor: Colors.blue[800]!,
              ),
              const SizedBox(height: 16),

              // CARTE LIVREUR (En développement)
              _buildRoleCard(
                context,
                title: "Livreur",
                roleValue: "livreur",
                subtitle: "Livrer des colis et repas",
                icon: Icons.delivery_dining,
                color: Colors.green[50]!,
                iconColor: Colors.green[800]!,
              ),

              const Spacer(),

              // BOUTON DE CONNEXION
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  child: const Text(
                    "Vous avez déjà un compte ? Connexion",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget personnalisé pour les cartes de rôle avec logique de redirection
  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required String roleValue,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color iconColor,
  }) {
    return InkWell(
      onTap: () {
        // LOGIQUE : Seul le client peut s'inscrire pour l'instant
        if (roleValue == "client") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AuthScreen(initialRole: roleValue),
            ),
          );
        } else {
          // Redirection vers la page "En cours de développement"
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DriverPlaceholderScreen(),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: iconColor.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 30),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}