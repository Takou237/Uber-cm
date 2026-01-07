import 'package:flutter/material.dart';
import 'auth_screen.dart';
import 'driver_placeholder_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // REMPLACEMENT DE L'ICÔNE PAR TON LOGO
              Image.asset(
                'assets/images/logo.png',
                height: 120, // Ajuste la taille selon tes préférences
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 120, width: 120,
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1), 
                    borderRadius: BorderRadius.circular(20)
                  ),
                  child: const Center(
                    child: Icon(Icons.image_not_supported, color: Colors.orange, size: 50)
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              const Text(
                "Bienvenue sur Uber_CM",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                "Comment souhaitez-vous utiliser l'application aujourd'hui ?",
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Option Client
              roleCard(
                context,
                title: "Je suis un Client",
                subtitle: "Je cherche un taxi, une moto ou une livraison.",
                icon: Icons.person,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AuthScreen()),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Option Chauffeur
              roleCard(
                context,
                title: "Je suis un Chauffeur",
                subtitle: "Je souhaite proposer mes services de transport.",
                icon: Icons.drive_eta,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DriverPlaceholderScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Ton widget roleCard reste identique avec les corrections withValues
  Widget roleCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.orange.withValues(alpha: 0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.orange.withValues(alpha: 0.1),
              radius: 30,
              child: Icon(icon, color: Colors.orange, size: 30),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.orange),
          ],
        ),
      ),
    );
  }
}