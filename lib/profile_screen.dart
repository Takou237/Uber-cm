import 'package:flutter/material.dart';
import 'package:uber_cm/saved_places_screen.dart';
import 'package:uber_cm/services/appwrite_service.dart';
import 'package:uber_cm/login_screen.dart';
import 'package:uber_cm/settingscreen.dart'; // IMPORTANT : pour accéder à themeNotifier

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final AppwriteService appwrite = AppwriteService();
    
    // Détection automatique du thème global via le contexte
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final subTextColor = isDark ? Colors.white70 : Colors.grey;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: Text("Mon compte", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: cardColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // --- HEADER DYNAMIQUE (APPWRITE) ---
            FutureBuilder(
              future: appwrite.account.get(),
              builder: (context, snapshot) {
                String initiales = "U";
                String nom = "Utilisateur";
                String email = "Chargement...";
                if (snapshot.hasData) {
                  nom = snapshot.data!.name.isNotEmpty ? snapshot.data!.name : "Passager";
                  email = snapshot.data!.email;
                  initiales = nom[0].toUpperCase();
                }
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40, 
                        backgroundColor: Colors.orange, 
                        child: Text(initiales, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold))
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(nom, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                            Text(email, style: TextStyle(color: subTextColor, fontSize: 14)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 25),
            _buildSectionTitle("Services"),
            _buildOptionItem(context, Icons.credit_card, "Moyens de paiement", () {}),
            
            _buildOptionItem(context, Icons.location_on_outlined, "Adresses enregistrées", () {
              // Retrait du 'const' si SavedPlacesScreen n'est pas un constructeur constant
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SavedPlacesScreen()));
            }),
            
            _buildOptionItem(context, Icons.settings_outlined, "Paramètres", () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsDetailScreen()));
            }),

            const SizedBox(height: 15),
            _buildSectionTitle("Réglages & Aide"),
            
            // --- SWITCH DU THÈME (CORRIGÉ POUR ÊTRE GLOBAL) ---
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
              child: SwitchListTile(
                title: Text(isDark ? "Mode Sombre" : "Mode Clair", style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
                secondary: Icon(isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined, color: Colors.orange),
                value: isDark,
                activeColor: Colors.orange,
                onChanged: (bool value) {
                  // ACTION : On met à jour le Notifier global utilisé dans ton main.dart
                  themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
                },
              ),
            ),
            
            _buildOptionItem(context, Icons.language, "Langue", () {
              _showLanguageBottomSheet(context);
            }),
            
            _buildOptionItem(context, Icons.notifications_none, "Notifications", () {}),
            _buildOptionItem(context, Icons.help_outline, "Aide", () {}),
            
            const SizedBox(height: 20),
            Text("Version 1.0.0", style: TextStyle(color: subTextColor, fontSize: 12)),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- LES WIDGETS DE SOUTIEN ---

  Widget _buildSectionTitle(String title) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    child: Align(alignment: Alignment.centerLeft, child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange))),
  );

  Widget _buildOptionItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(color: isDark ? const Color(0xFF1E1E1E) : Colors.white, borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.orange),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
        onTap: onTap,
      ),
    );
  }

  void _showLanguageBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Sélectionner une langue", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ListTile(title: const Text("Français"), leading: const Text("🇫🇷"), onTap: () => Navigator.pop(context)),
            ListTile(title: const Text("English"), leading: const Text("🇺🇸"), onTap: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }
}

// --- LA PAGE DE DÉTAIL DES PARAMÈTRES ---

class SettingsDetailScreen extends StatelessWidget {
  const SettingsDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppwriteService appwrite = AppwriteService();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: const Text("Paramètres"),
        backgroundColor: cardColor,
        foregroundColor: textColor,
        elevation: 0,
      ),
      body: FutureBuilder(
        future: appwrite.account.get(),
        builder: (context, snapshot) {
          String nom = snapshot.hasData ? snapshot.data!.name : "Chargement...";
          String phone = snapshot.hasData ? snapshot.data!.phone : "...";

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    _infoRow("Nom", nom, textColor),
                    const Divider(),
                    _infoRow("Numéro", phone, textColor),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _settingTile(isDark, Icons.email_outlined, "Adresse e-mail", "Modifier"),
              _settingTile(isDark, Icons.verified_user_outlined, "Vérification 2 étapes", "Désactivé"),
              _settingTile(isDark, Icons.phone_android_outlined, "Changer de numéro", "Modifier"),
              _settingTile(isDark, Icons.delete_outline, "Supprimer le compte", "Permanent"),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.logout, color: Colors.grey),
                  title: Text("Se déconnecter", style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
                  trailing: const Icon(Icons.chevron_right, size: 18),
                  onTap: () async {
                    await appwrite.logout();
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _infoRow(String label, String val, Color textC) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(val, style: TextStyle(color: textC, fontWeight: FontWeight.bold)),
      ],
    ),
  );

  Widget _settingTile(bool isDark, IconData icon, String title, String sub) => Container(
    margin: const EdgeInsets.symmetric(vertical: 4),
    decoration: BoxDecoration(color: isDark ? const Color(0xFF1E1E1E) : Colors.white, borderRadius: BorderRadius.circular(12)),
    child: ListTile(
      leading: Icon(icon, color: Colors.orange),
      title: Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 15)),
      subtitle: Text(sub, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      trailing: const Icon(Icons.chevron_right, size: 18),
    ),
  );
}