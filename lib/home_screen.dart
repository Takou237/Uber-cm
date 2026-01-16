import 'package:flutter/material.dart';
import 'package:uber_cm/saved_places_screen.dart';
import 'package:uber_cm/services/appwrite_service.dart';
import 'package:uber_cm/profile_screen.dart';
import 'package:uber_cm/screens/uber_search_screen.dart'; // Assure-toi que l'import est correct
import 'package:url_launcher/url_launcher.dart';
import 'package:appwrite/models.dart' as models;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AppwriteService _appwrite = AppwriteService();
  String _userName = "Utilisateur";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    try {
      final user = await _appwrite.account.get();
      if (mounted) {
        setState(() {
          _userName = user.name.isNotEmpty ? user.name : "Passager";
        });
      }
    } catch (e) {
      debugPrint("Erreur chargement profil: $e");
    }
  }

  // L'animation de transition "Style Uber"
  void _openUberSearch() {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) => const UberSearchScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Utilisation d'un fondu enchaîné pour la fluidité
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _openWhatsApp() async {
    var whatsappUrl = "whatsapp://send?phone=+237654266241&text=Bonjour Uber CM, j'ai besoin d'aide.";
    try {
      await launchUrl(Uri.parse(whatsappUrl));
    } catch (e) {
      debugPrint("Impossible d'ouvrir WhatsApp");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF6F6F6);

    return Scaffold(
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER ---
            Padding(
              padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Uber CM", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor)),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.orange,
                      child: Text(
                        _userName.isNotEmpty ? _userName[0].toUpperCase() : "U",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- BARRE DE RECHERCHE "STYLE UBER" ---
            Padding(
              padding: const EdgeInsets.all(20),
              child: GestureDetector(
                onTap: _openUberSearch, // Déclenche l'animation Uber
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFEEEEEE),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      if (!isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.black, size: 28), // Icône noire comme Uber
                      const SizedBox(width: 15),
                      const Expanded(
                        child: Text(
                          "Où allez-vous ?",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black54),
                        ),
                      ),
                      _buildTimePicker(isDark),
                    ],
                  ),
                ),
              ),
            ),

            // --- SERVICES ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildServiceCard("Course", Icons.directions_car, cardColor, textColor, _openUberSearch),
                  _buildServiceCard("Colis", Icons.inventory_2, cardColor, textColor, _openUberSearch),
                  _buildServiceCard("Réserver", Icons.calendar_month, cardColor, textColor, _openUberSearch),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // --- ADRESSES ENREGISTRÉES ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text("Vos adresses enregistrées", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
            ),

            FutureBuilder<List<models.Document>>(
              future: _appwrite.getFavoritePlaces(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LinearProgressIndicator(color: Colors.orange, backgroundColor: Colors.transparent);
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildLocationItem(Icons.star_border, "Ajouter un favori", "Enregistrez vos lieux fréquents", isDark, textColor, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SavedPlacesScreen()));
                  });
                }

                return Column(
                  children: snapshot.data!.map((doc) {
                    return _buildLocationItem(
                      Icons.location_on,
                      doc.data['name'] ?? "Lieu",
                      doc.data['address'] ?? "Cameroun",
                      isDark,
                      textColor,
                      _openUberSearch,
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 20),
            _buildPromoBanner(isDark, textColor),
            const SizedBox(height: 30),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openWhatsApp,
        backgroundColor: const Color(0xFF25D366),
        child: const Icon(Icons.support_agent, color: Colors.white),
      ),
    );
  }

  // --- WIDGETS DE CONSTRUCTION ---
  Widget _buildTimePicker(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)],
      ),
      child: const Row(
        children: [
          Icon(Icons.access_time_filled, size: 16, color: Colors.black),
          SizedBox(width: 5),
          Text("Maintenant", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
          Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.black),
        ],
      ),
    );
  }

  Widget _buildServiceCard(String title, IconData icon, Color cardColor, Color textColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, size: 35, color: Colors.black),
          ),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: textColor, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildLocationItem(IconData icon, String title, String subtitle, bool isDark, Color textColor, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.black54),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
      subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: const Icon(Icons.chevron_right, size: 18),
      onTap: onTap,
    );
  }

  Widget _buildPromoBanner(bool isDark, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.black, // Noir comme Uber pour le contraste
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.local_offer, color: Colors.white),
            SizedBox(width: 15),
            Expanded(
              child: Text(
                "Gagnez des réductions en parrainant vos amis !",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}