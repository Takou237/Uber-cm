import 'package:flutter/material.dart';
import 'package:uber_cm/map_screen.dart';

class UberSearchScreen extends StatefulWidget {
  const UberSearchScreen({super.key});

  @override
  State<UberSearchScreen> createState() => _UberSearchScreenState();
}

class _UberSearchScreenState extends State<UberSearchScreen> {
  // Par défaut, le départ est la position actuelle
  final TextEditingController _startController = TextEditingController(text: "Ma position actuelle");
  final TextEditingController _destController = TextEditingController();
  
  // Ces FocusNodes permettent de savoir quel champ l'utilisateur a touché
  final FocusNode _startFocus = FocusNode();
  final FocusNode _destFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    // On donne le focus à la destination par défaut au démarrage
    Future.delayed(Duration.zero, () => _destFocus.requestFocus());
  }

  // Fonction pour gérer le clic sur une adresse suggérée (Maison, Bureau, etc.)
  void _handleAddressSelection(String address) {
    if (_startFocus.hasFocus) {
      // Si on modifie le départ
      setState(() {
        _startController.text = address;
      });
    } else {
      // Si on choisit la destination, on fonce vers la carte avec l'itinéraire
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MapScreen(
            startAddress: _startController.text,
            destinationAddress: address,
          ),
        ),
      );
    }
  }

  // Fonction pour l'option "Choisir sur la carte"
  void _openMapPicker(bool isPickingStart) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(
          isPickingStartMode: isPickingStart,
          // Si on choisit déjà le départ sur la carte, on passe l'info
        ),
      ),
    ).then((selectedAddr) {
      // Quand on revient de la carte après avoir choisi un point
      if (selectedAddr != null && selectedAddr is String) {
        setState(() {
          if (isPickingStart) {
            _startController.text = selectedAddr;
          } else {
            _destController.text = selectedAddr;
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Planifiez votre course", style: TextStyle(color: Colors.black, fontSize: 16)),
      ),
      body: Column(
        children: [
          // --- ZONE DE SAISIE ---
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Indicateur Uber (Point -> Ligne -> Carré)
                Column(
                  children: [
                    const Icon(Icons.circle, size: 8, color: Colors.grey),
                    Container(width: 1, height: 35, color: Colors.grey[300]),
                    const Icon(Icons.stop, size: 10, color: Colors.black),
                  ],
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    children: [
                      _buildTextField(_startController, _startFocus, "Lieu de départ", false),
                      const SizedBox(height: 10),
                      _buildTextField(_destController, _destFocus, "Où allez-vous ?", true),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(thickness: 8, color: Color(0xFFF3F3F3)),

          // --- OPTIONS ---
          Expanded(
            child: ListView(
              children: [
                _buildOption(Icons.map, "Choisir sur la carte", "", () => _openMapPicker(_startFocus.hasFocus)),
                _buildOption(Icons.home, "Maison", "Quartier Bastos, Yaoundé", () => _handleAddressSelection("Quartier Bastos, Yaoundé")),
                _buildOption(Icons.work, "Bureau", "Avenue Kennedy, Centre Ville", () => _handleAddressSelection("Avenue Kennedy, Centre Ville")),
                _buildOption(Icons.history, "Palais des Sports", "Warda, Yaoundé", () => _handleAddressSelection("Warda, Yaoundé")),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, FocusNode focus, String hint, bool isDest) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: isDest ? Colors.grey[200] : Colors.grey[100],
        borderRadius: BorderRadius.circular(5),
      ),
      child: TextField(
        controller: controller,
        focusNode: focus,
        decoration: InputDecoration(
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildOption(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(backgroundColor: Colors.grey[100], child: Icon(icon, color: Colors.black, size: 20)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right, size: 18),
    );
  }
}