import 'package:flutter/material.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    final List<Map<String, dynamic>> services = [
      {'title': 'Course', 'icon': Icons.directions_car, 'promo': 'Économique'},
      {'title': 'Colis', 'icon': Icons.inventory_2, 'promo': 'Envoi rapide'},
      {'title': 'Réserver', 'icon': Icons.calendar_month, 'promo': 'À l\'avance'},
      {'title': 'Moto', 'icon': Icons.two_wheeler, 'promo': 'Plus rapide'},
      {'title': 'VIP', 'icon': Icons.stars, 'promo': 'Premium'},
      {'title': 'Location', 'icon': Icons.key, 'promo': 'À l\'heure'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Services", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Allez n'importe où, faites tout",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 0.8,
                ),
                itemCount: services.length,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      // Correction de la couleur ici
                      color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF3F3F3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(services[index]['icon'], size: 35, color: Colors.orange),
                        const SizedBox(height: 8),
                        Text(
                          services[index]['title'],
                          style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          services[index]['promo'],
                          style: const TextStyle(color: Colors.orange, fontSize: 9, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
