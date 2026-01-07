import 'package:flutter/material.dart';
import 'package:uber_cm/services/appwrite_service.dart';
import 'package:uber_cm/auth_screen.dart';
import 'package:uber_cm/home_screen.dart'; // Import ajouté pour la redirection

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  final AppwriteService _appwrite = AppwriteService();

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 1. Appel au service Appwrite pour créer une session
      await _appwrite.loginUser(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;

      // Message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Connexion réussie !"),
          backgroundColor: Colors.green,
        ),
      );

      // 2. Navigation vers la page d'accueil
      // On utilise pushReplacement pour que l'utilisateur ne puisse pas revenir au login avec le bouton retour
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur : ${e.toString()}"),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 80),
                    const Text(
                      "Connexion",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Heureux de vous revoir !",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    const SizedBox(height: 40),

                    // Champ Email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "Email",
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: Colors.black,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (v) =>
                          !v!.contains("@") ? "Email invalide" : null,
                    ),
                    const SizedBox(height: 20),

                    // Champ Mot de passe
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: "Mot de passe",
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: Colors.black,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (v) =>
                          v!.isEmpty ? "Entrez votre mot de passe" : null,
                    ),

                    const SizedBox(height: 40),

                    // Bouton Connexion
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _handleLogin,
                        child: const Text(
                          "SE CONNECTER",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Lien vers Inscription
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AuthScreen(),
                          ),
                        ),
                        child: const Text(
                          "Pas encore de compte ? Inscrivez-vous",
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
