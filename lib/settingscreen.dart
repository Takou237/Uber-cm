import 'package:flutter/material.dart';
import 'package:uber_cm/services/appwrite_service.dart';

// Ce notifier permet de changer le thème dans toute l'app
// Si tu l'as déjà dans main.dart, tu peux supprimer cette ligne
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AppwriteService _appwrite = AppwriteService();
  
  String _name = "Chargement...";
  String _phone = "...";
  String _lang = "Français";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  // Fonction optimisée pour éviter les lenteurs infinies
  void _loadUser() async {
    try {
      // On met un timeout de 3 secondes pour ne pas bloquer l'utilisateur
      final user = await _appwrite.account.get().timeout(
        const Duration(seconds: 3),
      );
      
      if (mounted) {
        setState(() {
          _name = (user.name.isNotEmpty) ? user.name : "Utilisateur";
          _phone = (user.phone.isNotEmpty) ? user.phone : "Non renseigné";
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Info: Mode invité ou timeout ($e)");
      if (mounted) {
        setState(() {
          _name = "Profil local";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;
        final txtColor = isDark ? Colors.white : Colors.black;

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: txtColor, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Paramètres",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: txtColor),
                  ),
                  const SizedBox(height: 40),

                  // --- INFOS UTILISATEUR (LECTURE SEULE) ---
                  _buildReadOnlyInfo(
                    label: "NOM D'UTILISATEUR",
                    value: _name,
                    textColor: txtColor,
                  ),
                  
                  const SizedBox(height: 30),

                  _buildReadOnlyInfo(
                    label: "NUMÉRO DE TÉLÉPHONE",
                    value: _phone,
                    textColor: txtColor,
                  ),

                  const SizedBox(height: 40),
                  const Divider(thickness: 0.5),
                  const SizedBox(height: 20),

                  // --- RÉGLAGES DE L'APP ---
                  _buildRowOption(
                    icon: isDark ? Icons.dark_mode : Icons.light_mode,
                    title: "Mode Sombre",
                    textColor: txtColor,
                    trailing: Switch(
                      value: isDark,
                      activeThumbColor: Colors.orange,
                      onChanged: (v) {
                        themeNotifier.value = v ? ThemeMode.dark : ThemeMode.light;
                      },
                    ),
                  ),

                  _buildRowOption(
                    icon: Icons.language,
                    title: "Langue de l'application",
                    subtitle: _lang,
                    textColor: txtColor,
                    onTap: () => _showLanguageSelector(),
                  ),
                  
                  const SizedBox(height: 100), // Espace en bas
                ],
              ),
            ),
        );
      },
    );
  }

  Widget _buildReadOnlyInfo({
    required String label,
    required String value,
    required Color textColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w400),
        ),
        const SizedBox(height: 10),
        Container(height: 1, color: Colors.grey.withValues(alpha: .2)),
      ],
    );
  }

  Widget _buildRowOption({
    required IconData icon, 
    required String title, 
    String? subtitle, 
    required Color textColor, 
    Widget? trailing, 
    VoidCallback? onTap
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.orange),
      title: Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(color: Colors.grey)) : null,
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
    );
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          const Text("Choisir la langue", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Divider(),
          ListTile(
            title: const Text("Français"), 
            leading: const Icon(Icons.check, color: Colors.orange),
            onTap: () { setState(() => _lang = "Français"); Navigator.pop(context); }
          ),
          ListTile(
            title: const Text("English"), 
            onTap: () { setState(() => _lang = "English"); Navigator.pop(context); }
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}