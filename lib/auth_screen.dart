import 'package:flutter/material.dart';
import 'package:uber_cm/services/appwrite_service.dart';
import 'package:uber_cm/login_screen.dart';

class AuthScreen extends StatefulWidget {
  final String? initialRole;
  const AuthScreen({this.initialRole, super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  late String _selectedRole;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

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
          content: Text("Bienvenue chez Uber CM ! Connectez-vous maintenant."),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );

      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur d'inscription : ${e.toString()}"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final secondaryTextColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Text(
                  "Créer un compte",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor),
                ),
                const SizedBox(height: 8),
                Text(
                  "Rejoignez la communauté Uber CM en quelques secondes.",
                  style: TextStyle(fontSize: 16, color: secondaryTextColor),
                ),
                const SizedBox(height: 30),

                // Champ Nom Complet
                _buildTextField(
                  controller: _nameController,
                  label: "Nom complet",
                  hint: "Ex: Jean Dupont",
                  icon: Icons.person_outline,
                  isDark: isDark,
                  validator: (v) => v!.isEmpty ? "Entrez votre nom" : null,
                ),
                const SizedBox(height: 16),

                // Champ Email
                _buildTextField(
                  controller: _emailController,
                  label: "Email",
                  hint: "exemple@gmail.com",
                  icon: Icons.email_outlined,
                  type: TextInputType.emailAddress,
                  isDark: isDark,
                  validator: (v) => !v!.contains("@") ? "Email invalide" : null,
                ),
                const SizedBox(height: 16),

                // Champ Téléphone
                _buildTextField(
                  controller: _phoneController,
                  label: "Téléphone",
                  hint: "+237 6XX XXX XXX",
                  icon: Icons.phone_android_outlined,
                  type: TextInputType.phone,
                  isDark: isDark,
                  validator: (v) => v!.isEmpty ? "Numéro requis" : null,
                ),
                const SizedBox(height: 16),

                // Champ Mot de passe
                _buildTextField(
                  controller: _passwordController,
                  label: "Mot de passe",
                  hint: "••••••••",
                  icon: Icons.lock_outline,
                  isDark: isDark,
                  isPassword: true,
                  obscureText: _obscurePassword,
                  toggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
                  validator: (v) => v!.length < 6 ? "Minimum 6 caractères" : null,
                ),
                const SizedBox(height: 16),

                // Champ Confirmation
                _buildTextField(
                  controller: _confirmPasswordController,
                  label: "Confirmer le mot de passe",
                  hint: "••••••••",
                  icon: Icons.lock_clock_outlined,
                  isDark: isDark,
                  isPassword: true,
                  obscureText: _obscureConfirmPassword,
                  toggleVisibility: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  validator: (v) => v != _passwordController.text ? "Les mots de passe diffèrent" : null,
                ),

                const SizedBox(height: 35),

                // Bouton d'inscription
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text("S'INSCRIRE", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ),
                ),

                const SizedBox(height: 30),
                _buildDivider(secondaryTextColor),
                const SizedBox(height: 30),

                // Boutons Sociaux
                Row(
                  children: [
                    Expanded(child: _socialButton(image: 'assets/images/google.png', label: "Google", isDark: isDark)),
                    const SizedBox(width: 16),
                    Expanded(child: _socialButton(image: 'assets/images/facebook.png', label: "Facebook", isDark: isDark)),
                  ],
                ),

                const SizedBox(height: 30),
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
                    child: RichText(
                      text: TextSpan(
                        text: "Déjà un compte ? ",
                        style: TextStyle(color: secondaryTextColor),
                        children: const [
                          TextSpan(text: "Se connecter", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGETS REUTILISABLES (IDENTIQUES AU LOGIN) ---

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    TextInputType type = TextInputType.text,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? toggleVisibility,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: type,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
            prefixIcon: Icon(icon, color: Colors.orange, size: 20),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, size: 20),
                    onPressed: toggleVisibility,
                  )
                : null,
            filled: true,
            fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.orange, width: 1.5)),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDivider(Color color) {
    return Row(
      children: [
        Expanded(child: Divider(color: color.withOpacity(0.2))),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text("OU", style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold))),
        Expanded(child: Divider(color: color.withOpacity(0.2))),
      ],
    );
  }

  Widget _socialButton({required String image, required String label, required bool isDark}) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white12 : Colors.grey[300]!),
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(image, height: 24, errorBuilder: (c, e, s) => const Icon(Icons.g_mobiledata)),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}