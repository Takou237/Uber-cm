import 'package:flutter/material.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  // Variables pour afficher/cacher le mot de passe
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

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

              // Onglets
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

              // Formulaire
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
                buildTextField(Icons.phone_outlined, "Téléphone", "6XX XXX XXX"),
                const SizedBox(height: 20),
              ],

              // Mot de passe avec bouton "Oeil"
              buildTextField(
                Icons.lock_outline, 
                "Mot de passe", 
                "••••••••", 
                isPassword: true,
                obscureText: _obscurePassword,
                onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              const SizedBox(height: 20),

              if (!isLogin) ...[
                buildTextField(
                  Icons.lock_outline, 
                  "Confirmer le mot de passe", 
                  "••••••••", 
                  isPassword: true,
                  obscureText: _obscureConfirmPassword,
                  onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
                const SizedBox(height: 20),
              ],

              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: () {
                  // Navigation vers la page d'accueil
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (route) => false, // On vide l'historique pour ne pas revenir à l'auth
                  );
                },
                child: Text(isLogin ? "Se connecter" : "Créer un compte", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),

              const SizedBox(height: 30),
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text("OU", style: TextStyle(color: Colors.grey, fontSize: 12))),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 30),

              Row(
                children: [
                  Expanded(child: socialButton("Google", "assets/images/google.png")),
                  const SizedBox(width: 15),
                  Expanded(child: socialButton("Facebook", "assets/images/facebook.png")),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTabButton(String text, bool active) {
    return GestureDetector(
      onTap: () => setState(() => isLogin = text == "Connexion"),
      child: Container(
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(text, style: TextStyle(fontWeight: FontWeight.bold, color: active ? Colors.black : Colors.grey)),
      ),
    );
  }

  // Widget TextField amélioré
  Widget buildTextField(IconData? icon, String label, String hint, {bool isPassword = false, bool obscureText = false, VoidCallback? onToggle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          obscureText: isPassword ? obscureText : false,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
            // Ajout du bouton Oeil
            suffixIcon: isPassword 
              ? IconButton(
                  icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                  onPressed: onToggle,
                ) 
              : null,
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
          ),
        ),
      ],
    );
  }

  Widget socialButton(String label, String imagePath) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () {},
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imagePath, height: 24), // Vrai logo
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}