import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true; // Pour basculer entre Connexion et Inscription

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Logo depuis tes assets
              Image.asset(
                'assets/images/logo.png',
                height: 100,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 100, width: 100,
                  decoration: BoxDecoration(color: const Color(0xFF10B981), borderRadius: BorderRadius.circular(20)),
                  child: const Center(child: Text("TL", style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold))),
                ),
              ),
              const SizedBox(height: 15),
              const Text("Uber_CM", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const Text("Transport & Livraison au Cameroun", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 40),

              // Sélecteur Connexion / Inscription
              Container(
                height: 50,
                decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(15)),
                child: Row(
                  children: [
                    Expanded(child: buildTabButton("Connexion", isLogin)),
                    Expanded(child: buildTabButton("Inscription", !isLogin)),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Formulaire dynamique
              if (!isLogin) ...[
                Row(
                  children: [
                    Expanded(child: buildTextField(Icons.person_outline, "Prénom", "Jean")),
                    const SizedBox(width: 15),
                    Expanded(child: buildTextField(null, "Nom", "Atangana")),
                  ],
                ),
                const SizedBox(height: 20),
              ],

              buildTextField(Icons.email_outlined, "Email", "votre@email.com"),
              const SizedBox(height: 20),
              
              if (!isLogin) ...[
                buildTextField(Icons.phone_outlined, "Téléphone (optionnel)", "6XX XXX XXX"),
                const SizedBox(height: 20),
              ],

              buildTextField(Icons.lock_outline, "Mot de passe", "••••••••", isPassword: true),
              const SizedBox(height: 20),

              if (!isLogin) ...[
                buildTextField(Icons.lock_outline, "Confirmer le mot de passe", "••••••••", isPassword: true),
                const SizedBox(height: 20),
              ],

              // Bouton Principal (Vert comme sur la capture)
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: () {},
                child: Text(isLogin ? "Se connecter" : "Créer un compte", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),

              const SizedBox(height: 30),
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text("OU CONTINUER AVEC", style: TextStyle(color: Colors.grey, fontSize: 12))),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 30),

              // Boutons Sociaux
              Row(
                children: [
                  Expanded(child: socialButton("Google", "assets/images/google.png", Colors.white, Colors.black)),
                  const SizedBox(width: 15),
                  Expanded(child: socialButton("Facebook", "assets/images/facebook.png", Colors.white, Colors.black)),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // Widget pour les onglets
  Widget buildTabButton(String text, bool active) {
    return GestureDetector(
      onTap: () => setState(() => isLogin = text == "Connexion"),
      child: Container(
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5)]
        ),
        alignment: Alignment.center,
        child: Text(text, style: TextStyle(fontWeight: FontWeight.bold, color: active ? Colors.black : Colors.grey)),
      ),
    );
  }

  // Widget pour les champs de saisie
  Widget buildTextField(IconData? icon, String label, String hint, {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
          ),
        ),
      ],
    );
  }

  // Widget pour les boutons Google/Facebook
  Widget socialButton(String label, String iconPath, Color bgColor, Color textColor) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      onPressed: () {},
      icon: const Icon(Icons.ads_click, size: 20), // Remplace par une icône ou Image.asset
      label: Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
    );
  }
}