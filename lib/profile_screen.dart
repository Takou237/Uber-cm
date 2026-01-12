import 'package:flutter/material.dart';
import 'package:uber_cm/saved_places_screen.dart';
import 'package:uber_cm/services/appwrite_service.dart';
import 'package:uber_cm/login_screen.dart';
import 'package:uber_cm/settingscreen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppwriteService appwrite = AppwriteService();

    // --- VARIABLES DE THÈME ---
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final subTextColor = isDark ? Colors.white70 : Colors.grey;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: Text("Mon compte", style: TextStyle(color: textColor)),
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor), // Pour que la flèche retour change de couleur
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // --- HEADER DYNAMIQUE (NOM & EMAIL) ---
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
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: isDark ? Border.all(color: Colors.white10) : null,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.orange,
                        child: Text(initiales, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(nom, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                            Text(email, style: TextStyle(color: subTextColor)),
                          ],
                        ),
                      ),
                      Icon(Icons.edit_outlined, color: subTextColor),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 20),
            
            // --- OPTIONS ---
            _buildOptionItem(context, Icons.credit_card, "Moyens de paiement", () {}),
            _buildOptionItem(context, Icons.location_on_outlined, "Adresses enregistrées", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SavedPlacesScreen()),
              );
            }),
            
            _buildOptionItem(context, Icons.settings_outlined, "Paramètres", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            }),
            
            const SizedBox(height: 10),
            Divider(indent: 20, endIndent: 20, color: isDark ? Colors.white10 : Colors.grey.shade300),
            const SizedBox(height: 10),
            
            _buildOptionItem(context, Icons.notifications_none, "Notifications", () {}),
            _buildOptionItem(context, Icons.security, "Sécurité", () {}),
            _buildOptionItem(context, Icons.help_outline, "Aide", () {}),
            _buildOptionItem(context, Icons.description_outlined, "Mentions légales", () {}),
            
            const SizedBox(height: 30),
            
            // --- BOUTON DÉCONNEXION ---
            TextButton.icon(
              onPressed: () async {
                try {
                  await appwrite.logout();
                  if (!context.mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                    (route) => false,
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: $e")));
                }
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text("Se déconnecter", style: TextStyle(color: Colors.red, fontSize: 16)),
            ),
            
            const SizedBox(height: 20),
            Text("Version 1.0.0", style: TextStyle(color: subTextColor)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- WIDGET OPTION ADAPTATIF ---
  Widget _buildOptionItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: isDark ? Border.all(color: Colors.white10) : null,
      ),
      child: ListTile(
        leading: Icon(icon, color: isDark ? Colors.orange : Colors.black87),
        title: Text(title, style: TextStyle(
          fontWeight: FontWeight.w500, 
          color: isDark ? Colors.white : Colors.black
        )),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
        onTap: onTap,
      ),
    );
  }
}
