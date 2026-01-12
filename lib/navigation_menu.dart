import 'package:flutter/material.dart';
import 'package:uber_cm/home_screen.dart';
import 'package:uber_cm/profile_screen.dart'; // Pour l'onglet Account

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({super.key});

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  int _selectedIndex = 0;

  // Liste des pages correspondantes aux icônes
  final List<Widget> _pages = [
    const HomeScreen(),
    const Center(child: Text("Services Screen (À créer)")), // Placeholder
    const Center(child: Text("Activity Screen (À créer)")), // Placeholder
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: _pages[_selectedIndex], // Affiche la page sélectionnée
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Garde les labels visibles
        backgroundColor: isDark ? Colors.black : Colors.white,
        selectedItemColor: Colors.orange,
        unselectedItemColor: isDark ? Colors.white60 : Colors.black54,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Services',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            label: 'Activité',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Compte',
          ),
        ],
      ),
    );
  }
}
