import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Uber_CM", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none, color: Colors.black)),
          const CircleAvatar(backgroundColor: Colors.orange, child: Icon(Icons.person, color: Colors.white)),
          const SizedBox(width: 15),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Où allez-vous ?", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            
            // Barre de recherche
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white, 
                borderRadius: BorderRadius.circular(15), 
                boxShadow: const [ // AJOUT DE CONST ICI
                  BoxShadow(color: Colors.black12, blurRadius: 10)
                ]
              ),
              child: const TextField(
                decoration: InputDecoration(
                  icon: Icon(Icons.search, color: Colors.orange), 
                  hintText: "Saisir la destination", 
                  border: InputBorder.none
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Catégories
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                categoryItem(Icons.local_taxi, "Taxi"),
                categoryItem(Icons.motorcycle, "Moto"),
                categoryItem(Icons.delivery_dining, "Livraison"),
                categoryItem(Icons.more_horiz, "Plus"),
              ],
            ),
            
            const SizedBox(height: 30),
            
            // Bannière Promo
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange, 
                borderRadius: BorderRadius.circular(20)
              ),
              child: const Column( // Déjà en const, c'est parfait
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Promo de Noël !", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("-20% sur votre prochaine course", style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget categoryItem(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white, 
            borderRadius: BorderRadius.circular(15)
          ),
          child: Icon(icon, color: Colors.orange, size: 30),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}