import 'package:flutter/material.dart';
import 'package:uber_cm/services/appwrite_service.dart';
import 'package:uber_cm/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AppwriteService _appwrite = AppwriteService();
  String _userName = "Passager";

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
      debugPrint("Info Backend: Utilisation du profil invité ($e)");
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Uber CM", 
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: textColor)),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.orange,
                        child: Text(_userName.isNotEmpty ? _userName[0].toUpperCase() : "U", 
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),

              // RECHERCHE (Simulée pro)
              _buildSearchBox(isDark),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Text("Services", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),

              // GRILLE DE SERVICES ASYMÉTRIQUE
              _buildServicesGrid(isDark, cardColor, textColor),

              const SizedBox(height: 30),

              // SUGGESTIONS
              _buildDestinationTile(Icons.history, "Dernière destination", "Carrefour Jouvence, Yaoundé", isDark),
              _buildDestinationTile(Icons.star_outline, "Lieux enregistrés", "Maison, Travail...", isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBox(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.grey[200],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.orange, size: 28),
          const SizedBox(width: 10),
          const Text("Où allez-vous ?", 
            style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildServicesGrid(bool isDark, Color cardColor, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Service Principal
          Expanded(
            flex: 2,
            child: _card(
              title: "Course", 
              icon: Icons.directions_car, 
              color: Colors.orange, 
              height: 160, 
              cardColor: cardColor, 
              textColor: textColor
            ),
          ),
          const SizedBox(width: 12),
          // Services Secondaires
          Expanded(
            flex: 1,
            child: Column(
              children: [
                _card(title: "Colis", icon: Icons.inventory_2, color: Colors.blue, height: 74, cardColor: cardColor, textColor: textColor),
                const SizedBox(height: 12),
                _card(title: "Moto", icon: Icons.moped, color: Colors.green, height: 74, cardColor: cardColor, textColor: textColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required String title, required IconData icon, required Color color, required double height, required Color cardColor, required Color textColor}) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha:0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: height > 80 ? 40 : 24, color: color),
          const SizedBox(height: 5),
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
        ],
      ),
    );
  }

  Widget _buildDestinationTile(IconData icon, String title, String sub, bool isDark) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isDark ? Colors.white10 : Colors.grey[100],
        child: Icon(icon, color: Colors.orange, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(sub),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }
}
