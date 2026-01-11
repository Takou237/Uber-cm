import 'package:flutter/material.dart';
import 'package:uber_cm/services/appwrite_service.dart';
import 'package:uber_cm/profile_screen.dart';
import 'package:url_launcher/url_launcher.dart'; // Pour WhatsApp

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AppwriteService _appwrite = AppwriteService();
  String _userName = "...";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    try {
      final user = await _appwrite.account.get();
      if (mounted) setState(() => _userName = user.name);
    } catch (e) {
      debugPrint("Erreur: $e");
    }
  }

  // Fonction pour ouvrir WhatsApp Support
  void _openWhatsApp() async {
    var whatsappUrl = "whatsapp://send?phone=+237654266241&text=Bonjour Uber CM, j'ai besoin d'aide.";
    if (!await launchUrl(Uri.parse(whatsappUrl))) {
      debugPrint("Impossible d'ouvrir WhatsApp");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER MINIMALISTE (Uber Style)
            Padding(
              padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Uber CM", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.orange,
                      child: Text(_userName[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),

            // ACTION PRINCIPALE : RECHERCHE
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEEEEE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Où allez-vous ?",
                    hintStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
                    border: InputBorder.none,
                    icon: const Icon(Icons.search, color: Colors.black, size: 30),
                    suffixIcon: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.access_time_filled, size: 16, color: Colors.black),
                          SizedBox(width: 5),
                          Text("Maintenant", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // SERVICES (LES 3 GRANDS)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildServiceCard("Course", Icons.directions_car),
                  _buildServiceCard("Colis", Icons.inventory_2),
                  _buildServiceCard("Réserver", Icons.calendar_month),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ADRESSES RAPIDES
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text("Suggestions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            _buildLocationItem(Icons.home, "Maison Essos", "Yaoundé, Cameroun"),
            _buildLocationItem(Icons.work, "Cité Universitaire", "Ngoa-Ekelle"),
            _buildLocationItem(Icons.star, "Marché Mokolo", "Point de rendez-vous fréquent"),

            const SizedBox(height: 20),

            // PROMO DISCRÈTE (BANNER)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.local_offer, color: Colors.orange),
                    SizedBox(width: 10),
                    Text("Promo : -20% sur votre trajet !", style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      
      // SUPPORT WHATSAPP (Flottant)
      floatingActionButton: FloatingActionButton(
        onPressed: _openWhatsApp,
        backgroundColor: const Color(0xFF25D366),
        child: const Icon(Icons.support_agent, color: Colors.white),
      ),
    );
  }

  Widget _buildServiceCard(String title, IconData icon) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: Colors.black),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildLocationItem(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFEEEEEE),
        child: Icon(icon, color: Colors.black),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }
}
