import 'package:flutter/material.dart';
import 'package:uber_cm/saved_places_screen.dart';
import 'package:uber_cm/services/appwrite_service.dart';
import 'package:uber_cm/profile_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:appwrite/models.dart' as models;
import 'package:uber_cm/map_screen.dart';

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

  void _openWhatsApp() async {
    var whatsappUrl =
        "whatsapp://send?phone=+237654266241&text=Bonjour Uber CM, j'ai besoin d'aide.";
    try {
      await launchUrl(Uri.parse(whatsappUrl));
    } catch (e) {
      debugPrint("Impossible d'ouvrir WhatsApp");
    }
  }

  // Fonction utilitaire pour naviguer vers la carte
  void _goToMap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MapScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = isDark
        ? const Color(0xFF2C2C2C)
        : const Color(0xFFF6F6F6);

    return Scaffold(
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER ---
            Padding(
              padding: const EdgeInsets.only(
                top: 50,
                left: 20,
                right: 20,
                bottom: 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Uber CM",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.orange,
                      child: Text(
                        _userName.isNotEmpty ? _userName[0].toUpperCase() : "U",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- BARRE DE RECHERCHE (Modifiée pour ouvrir la carte) ---
            Padding(
              padding: const EdgeInsets.all(20),
              child: GestureDetector(
                onTap: _goToMap, // Ouvre la carte au clic sur le conteneur
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 15,
                  ), // Augmenté pour le confort
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E1E1E)
                        : const Color(0xFFEEEEEE),
                    borderRadius: BorderRadius.circular(12),
                    border: isDark ? Border.all(color: Colors.white10) : null,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.orange, size: 30),
                      const SizedBox(width: 15),
                      const Expanded(
                        child: Text(
                          "Où allez-vous ?",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
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
                  _buildServiceCard(
                    "Course",
                    Icons.directions_car,
                    cardColor,
                    textColor,
                    _goToMap,
                  ),
                  _buildServiceCard(
                    "Colis",
                    Icons.inventory_2,
                    cardColor,
                    textColor,
                    _goToMap,
                  ),
                  _buildServiceCard(
                    "Réserver",
                    Icons.calendar_month,
                    cardColor,
                    textColor,
                    _goToMap,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // --- SECTION SUGGESTIONS DYNAMIQUE ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                "Vos adresses enregistrées",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),

            FutureBuilder<List<models.Document>>(
              future: _appwrite.getFavoritePlaces(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: LinearProgressIndicator(
                      color: Colors.orange,
                      backgroundColor: Colors.transparent,
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildLocationItem(
                    Icons.star_border,
                    "Ajouter un favori",
                    "Enregistrez vos lieux fréquents ici",
                    isDark,
                    textColor,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SavedPlacesScreen(),
                      ),
                    ),
                  );
                }

                return Column(
                  children: snapshot.data!.map((doc) {
                    return _buildLocationItem(
                      Icons.location_on,
                      doc.data['name'] ?? "Lieu",
                      doc.data['address'] ?? "Cameroun",
                      isDark,
                      textColor,
                      _goToMap, // On envoie vers la carte pour commencer le trajet
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 20),

            // --- BANNIÈRE PROMO ---
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? Colors.black26 : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.access_time_filled, size: 16, color: Colors.orange),
          SizedBox(width: 5),
          Text(
            "Maintenant",
            style: TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(
    String title,
    IconData icon,
    Color cardColor,
    Color textColor,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: Colors.orange),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationItem(
    IconData icon,
    String title,
    String subtitle,
    bool isDark,
    Color textColor,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isDark ? Colors.white10 : const Color(0xFFEEEEEE),
        child: Icon(icon, color: Colors.orange),
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
      ),
      subtitle: Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: textColor.withValues(alpha: 0.6)),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: textColor.withValues(alpha: 0.3),
      ),
      onTap: onTap,
    );
  }

  Widget _buildPromoBanner(bool isDark, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.orange.withValues(alpha: 0.1)
              : Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.local_offer, color: Colors.orange),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "Promo : -20% sur votre prochain trajet !",
                style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
