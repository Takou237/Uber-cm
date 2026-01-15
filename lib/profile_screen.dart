import 'package:flutter/material.dart';
import 'package:uber_cm/saved_places_screen.dart';
import 'package:uber_cm/services/appwrite_service.dart';
import 'package:uber_cm/login_screen.dart';
import 'package:uber_cm/settingscreen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AppwriteService appwrite = AppwriteService();

  @override
  Widget build(BuildContext context) {
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
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            FutureBuilder(
              future: appwrite.account.get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final user = snapshot.data!;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 35, 
                        backgroundColor: Colors.orange, 
                        child: Text(user.name[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 24))
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                          Text(user.email, style: TextStyle(color: subTextColor, fontSize: 13)),
                        ],
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
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SavedPlacesScreen()));
            }),
            _buildOptionItem(context, Icons.settings_outlined, "Paramètres avancés", () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsDetailScreen()));
            }),

            const SizedBox(height: 15),
            _buildSectionTitle("Réglages & Aide"),
            
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
              child: SwitchListTile(
                title: Text("Mode Sombre", style: TextStyle(color: textColor)),
                secondary: const Icon(Icons.dark_mode_outlined, color: Colors.orange),
                value: isDark,
                activeThumbColor: Colors.orange,
                onChanged: (bool value) {
                  themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
                },
              ),
            ),
            
            _buildOptionItem(context, Icons.language, "Langue", () {}),
            _buildOptionItem(context, Icons.help_outline, "Aide", () {}),

            const SizedBox(height: 30),
            Text("Version 1.0.0", style: TextStyle(color: subTextColor, fontSize: 11)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    child: Align(alignment: Alignment.centerLeft, child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange))),
  );

  Widget _buildOptionItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(color: isDark ? const Color(0xFF1E1E1E) : Colors.white, borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.orange),
        title: Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black)),
        trailing: const Icon(Icons.chevron_right, size: 18),
        onTap: onTap,
      ),
    );
  }
}

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
        title: const Text("Sécurité & Compte"),
        backgroundColor: cardColor,
        foregroundColor: textColor,
        elevation: 0,
      ),
      body: FutureBuilder(
        future: appwrite.account.get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final user = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionHeader("Informations de contact"),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    _infoRow("Nom", user.name, textColor),
                    const Divider(),
                    _infoRow("Email", user.email, textColor),
                    const Divider(),
                    _infoRow("Mobile", user.phone.isEmpty ? "Non défini" : user.phone, textColor),
                  ],
                ),
              ),

              const SizedBox(height: 25),
              _buildSectionHeader("Sécurité du compte"),
              
              _settingTile(context, isDark, Icons.verified_user_outlined, "Vérification à deux étapes", "Renforcez la sécurité", () {}),
              
              _settingTile(context, isDark, Icons.phone_android_outlined, "Changer de numéro", "Nécessite votre mot de passe", () {
                _showUpdatePhoneDialog(context, appwrite, isDark, textColor);
              }),

              const SizedBox(height: 25),

              _buildSectionHeader("Actions critiques"),
              Container(
                decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.orange),
                      title: Text("Se déconnecter", style: TextStyle(color: textColor)),
                      onTap: () => _showLogoutDialog(context, appwrite, isDark, textColor),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.delete_forever, color: Colors.red),
                      title: const Text("Supprimer le compte", style: TextStyle(color: Colors.red)),
                      onTap: () => _showDeleteDialog(context, appwrite, user.email, isDark, textColor),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showUpdatePhoneDialog(BuildContext context, AppwriteService appwrite, bool isDark, Color textColor) {
    final phoneController = TextEditingController();
    final passController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        title: Text("Nouveau numéro", style: TextStyle(color: textColor)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: phoneController, style: TextStyle(color: textColor), decoration: const InputDecoration(hintText: "+237 6xx xxx xxx")),
            const SizedBox(height: 10),
            TextField(controller: passController, obscureText: true, style: TextStyle(color: textColor), decoration: const InputDecoration(hintText: "Mot de passe")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("ANNULER")),
          TextButton(
            onPressed: () async {
              try {
                await appwrite.account.updatePhone(phone: phoneController.text, password: passController.text);
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Numéro mis à jour !")));
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Échec : Mot de passe incorrect"), backgroundColor: Colors.red));
              }
            },
            child: const Text("VALIDER", style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, AppwriteService appwrite, String email, bool isDark, Color textColor) {
    final passController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        title: const Text("Supprimer ?", style: TextStyle(color: Colors.red)),
        content: TextField(controller: passController, obscureText: true, style: TextStyle(color: textColor), decoration: const InputDecoration(hintText: "Entrez votre mot de passe")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("ANNULER")),
          TextButton(
            onPressed: () async {
              try {
                await appwrite.account.createEmailPasswordSession(email: email, password: passController.text);
                await appwrite.account.updateStatus();
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mot de passe incorrect"), backgroundColor: Colors.red));
              }
            },
            child: const Text("SUPPRIMER", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AppwriteService appwrite, bool isDark, Color textColor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        title: Text("Déconnexion", style: TextStyle(color: textColor)),
        content: const Text("Quitter la session actuelle ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("NON")),
          TextButton(
            onPressed: () async {
              await appwrite.logout();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
            },
            child: const Text("OUI", style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) => Padding(
    padding: const EdgeInsets.only(left: 8, bottom: 8),
    child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.orange)),
  );

  Widget _infoRow(String label, String val, Color textC) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Text(val, style: TextStyle(color: textC, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    ),
  );

  Widget _settingTile(BuildContext context, bool isDark, IconData icon, String title, String sub, VoidCallback onTap) => Container(
    margin: const EdgeInsets.symmetric(vertical: 4),
    decoration: BoxDecoration(color: isDark ? const Color(0xFF1E1E1E) : Colors.white, borderRadius: BorderRadius.circular(12)),
    child: ListTile(
      leading: Icon(icon, color: Colors.orange),
      title: Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14)),
      subtitle: Text(sub, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      trailing: const Icon(Icons.chevron_right, size: 16),
      onTap: onTap,
    ),
  );
}