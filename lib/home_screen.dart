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
  String _userName = "...";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    try {
      final user = await _appwrite.account.get();
      if (mounted) {
        setState(() => _userName = user.name);
      }
    } catch (e) {
      // debugPrint est préférable à print en Flutter
      debugPrint("Erreur chargement utilisateur: $e");
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty || name == "...") return "?";
    List<String> parts = name.trim().split(RegExp(r'\s+'));
    String firstLetter = parts[0][0].toUpperCase();
    if (parts.length > 1) {
      String secondLetter = parts[1][0].toUpperCase();
      if (firstLetter != secondLetter) return firstLetter + secondLetter;
    }
    return firstLetter;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 30),
            decoration: const BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
                  child: CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    child: Text(
                      _getInitials(_userName),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Bonjour,", style: TextStyle(color: Colors.white, fontSize: 18)),
                    Text(_userName, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.notifications_none, color: Colors.white, size: 30),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Row( // Ajout du CONST ici
                children: [
                  Icon(Icons.location_on, color: Colors.orange),
                  SizedBox(width: 10),
                  Text(
                    "Où allez-vous ?",
                    style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}