import 'package:flutter/material.dart';
import 'package:uber_cm/auth_screen.dart'; 
import 'package:uber_cm/login_screen.dart'; 
import 'package:uber_cm/driver_placeholder_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Détection du mode sombre
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTitleColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              // LOGO
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 80,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.directions_car_filled_rounded, 
                      size: 60, 
                      color: Colors.orange[700]
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                "Bienvenue sur Uber_CM",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Comment souhaitez-vous utiliser l'application aujourd'hui ?",
                style: TextStyle(fontSize: 16, color: subTitleColor, height: 1.4),
              ),
              const SizedBox(height: 35),

              // RÔLES
              _buildRoleCard(
                context,
                title: "Passager",
                roleValue: "client",
                subtitle: "Commander une course en quelques clics",
                icon: Icons.person_pin_circle_rounded,
                accentColor: Colors.orange,
                isDark: isDark,
                isAvailable: true,
              ),
              const SizedBox(height: 16),
              _buildRoleCard(
                context,
                title: "Chauffeur",
                roleValue: "chauffeur",
                subtitle: "Générer des revenus avec votre véhicule",
                icon: Icons.local_taxi_rounded,
                accentColor: Colors.blue,
                isDark: isDark,
                isAvailable: false,
              ),
              const SizedBox(height: 16),
              _buildRoleCard(
                context,
                title: "Livreur",
                roleValue: "livreur",
                subtitle: "Livrer des colis en ville rapidement",
                icon: Icons.delivery_dining_rounded,
                accentColor: Colors.green,
                isDark: isDark,
                isAvailable: false,
              ),

              const Spacer(),

              // FOOTER
              Center(
                child: Column(
                  children: [
                    Text(
                      "Vous avez déjà un compte ?",
                      style: TextStyle(color: subTitleColor),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      ),
                      child: const Text(
                        "Se connecter maintenant",
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required String roleValue,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required bool isDark,
    required bool isAvailable,
  }) {
    final cardBg = isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50];
    final borderColor = isDark ? Colors.white10 : Colors.black.withOpacity(0.05);

    return InkWell(
      onTap: () {
        if (roleValue == "client") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AuthScreen(initialRole: roleValue)));
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const DriverPlaceholderScreen()));
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: accentColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87
                        ),
                      ),
                      if (!isAvailable) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            "Bientôt",
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isDark ? Colors.white54 : Colors.black54, 
                      fontSize: 13
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded, 
              color: isDark ? Colors.white24 : Colors.black26
            ),
          ],
        ),
      ),
    );
  }
}