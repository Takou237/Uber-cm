import 'package:flutter/material.dart';
import 'package:uber_cm/services/appwrite_service.dart';
import 'package:uber_cm/auth_screen.dart';
import 'package:uber_cm/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

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
      await _appwrite.loginUser(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Ravi de vous revoir !"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Échec de connexion : ${e.toString()}"),
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
                const SizedBox(height: 20),
                Text(
                  "Bon retour parmi nous",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor),
                ),
                const SizedBox(height: 8),
                Text(
                  "Connectez-vous pour continuer à voyager avec Uber CM",
                  style: TextStyle(fontSize: 16, color: secondaryTextColor),
                ),
                const SizedBox(height: 40),

                // Champ Email
                _buildTextField(
                  controller: _emailController,
                  label: "Email",
                  hint: "exemple@gmail.com",
                  icon: Icons.email_outlined,
                  isDark: isDark,
                  validator: (v) => !v!.contains("@") ? "Veuillez entrer un email valide" : null,
                ),
                const SizedBox(height: 20),

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
                  validator: (v) => v!.length < 6 ? "Mot de passe trop court" : null,
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text("Mot de passe oublié ?", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600)),
                  ),
                ),

                const SizedBox(height: 30),

                // Bouton de connexion
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
                    onPressed: _isLoading ? null : _handleLogin,
                    child: _isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text("SE CONNECTER", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
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

                const SizedBox(height: 40),
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AuthScreen())),
                    child: RichText(
                      text: TextSpan(
                        text: "Nouveau sur l'application ? ",
                        style: TextStyle(color: secondaryTextColor),
                        children: const [
                          TextSpan(text: "S'inscrire", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
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
            fillColor: isDark ? Colors.white.withValues(alpha:0.05) : Colors.grey[100],
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
        Expanded(child: Divider(color: color.withValues(alpha:0.2))),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text("OU", style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold))),
        Expanded(child: Divider(color: color.withValues(alpha:0.2))),
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
    super.dispose();
  }
}