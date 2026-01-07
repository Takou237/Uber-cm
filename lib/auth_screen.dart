import 'package:flutter/material.dart';
import 'package:uber_cm/services/appwrite_service.dart';
import 'package:uber_cm/login_screen.dart'; // Import pour la redirection

class AuthScreen extends StatefulWidget {
  final String?
  initialRole; // Reçoit le rôle choisi (client, chauffeur, livreur)

  const AuthScreen({this.initialRole, super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  late String _selectedRole;
  bool _isLoading = false;
  bool _obscurePassword = true;

  final AppwriteService _appwrite = AppwriteService();

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole ?? 'client';
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _appwrite.registerUser(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _nameController.text.trim(),
        _selectedRole,
        _phoneController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Inscription réussie ! Redirection vers la connexion...",
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Petite pause pour laisser l'utilisateur lire le message de succès
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType type = TextInputType.text,
    bool obscure = false,
    String? hint,
    String? Function(String?)? validator,
    Widget? suffix,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        obscureText: obscure,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.black87),
          suffixIcon: suffix,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.black, width: 2),
          ),
        ),
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Créer un compte",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Bienvenue !",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Veuillez remplir vos informations pour continuer.",
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 30),

                    _buildTextField(
                      controller: _nameController,
                      label: "Nom complet",
                      icon: Icons.person_outline,
                      validator: (v) => v!.isEmpty ? "Entrez votre nom" : null,
                    ),

                    _buildTextField(
                      controller: _emailController,
                      label: "Email",
                      icon: Icons.email_outlined,
                      type: TextInputType.emailAddress,
                      validator: (v) =>
                          !v!.contains("@") ? "Email invalide" : null,
                    ),

                    _buildTextField(
                      controller: _passwordController,
                      label: "Mot de passe",
                      icon: Icons.lock_outline,
                      obscure: _obscurePassword,
                      suffix: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                      validator: (v) =>
                          v!.length < 6 ? "Minimum 6 caractères" : null,
                    ),

                    _buildTextField(
                      controller: _phoneController,
                      label: "Téléphone",
                      hint: "+237690000000",
                      icon: Icons.phone_android,
                      type: TextInputType.phone,
                      validator: (v) {
                        if (v!.isEmpty) return "Entrez votre numéro";
                        if (!v.startsWith('+'))
                          return "Doit commencer par + (ex: +237)";
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),
                    const Text(
                      "Votre rôle :",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedRole,
                          isExpanded: true,
                          items: ['client', 'chauffeur', 'livreur'].map((role) {
                            return DropdownMenuItem(
                              value: role,
                              child: Text(
                                role.toUpperCase(),
                                style: const TextStyle(fontSize: 14),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) =>
                              setState(() => _selectedRole = val!),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // BOUTON S'INSCRIRE
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
                        onPressed: _submit,
                        child: const Text(
                          "S'INSCRIRE",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // BOUTON VERS CONNEXION
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "Déjà un compte ? Connectez-vous",
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
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
