import 'package:flutter/material.dart';
import 'package:uber_cm/services/appwrite_service.dart';
import 'package:appwrite/models.dart' as models;

class SavedPlacesScreen extends StatefulWidget {
  const SavedPlacesScreen({super.key});

  @override
  State<SavedPlacesScreen> createState() => _SavedPlacesScreenState();
}

class _SavedPlacesScreenState extends State<SavedPlacesScreen> {
  final AppwriteService _appwrite = AppwriteService();
  List<models.Document> _places = [];
  bool _isLoading = true;
  
  get textColor => null;

  @override
  void initState() {
    super.initState();
    _fetchPlaces();
  }

  Future<void> _fetchPlaces() async {
    setState(() => _isLoading = true);
    final places = await _appwrite.getFavoritePlaces();
    if (mounted) {
      setState(() {
        _places = places;
        _isLoading = false;
      });
    }
  }

  // Dans saved_places_screen.dart, modifie le _showAddPlaceDialog :

  void _showAddPlaceDialog() {
    final nameController = TextEditingController();
    final addressController = TextEditingController(); // Sera rempli par la carte plus tard

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20, right: 20, top: 20
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Ajouter un lieu", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
            const SizedBox(height: 15),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Nom (ex: Maison, Bureau)", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            
            // --- SECTION LOCATION / MAPS ---
            InkWell(
              onTap: () {
                // TODO: Ouvrir Google Maps Picker ici
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Bientôt : Sélection sur la carte Google Maps"))
                );
              },
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.map_outlined, color: Colors.orange),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        addressController.text.isEmpty ? "Choisir sur la carte" : addressController.text,
                        style: TextStyle(color: addressController.text.isEmpty ? Colors.grey : textColor),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, padding: const EdgeInsets.all(15)),
                onPressed: () async {
                  // Pour l'instant, on met une adresse test pour vérifier que la synchro marche
                  if (nameController.text.isNotEmpty) {
                    await _appwrite.savePlace(
                      name: nameController.text,
                      address: "Sélection carte en cours...", // Sera remplacé par la vraie adresse
                      latitude: 3.848,
                      longitude: 11.502,
                    );
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    _fetchPlaces(); 
                  }
                },
                child: const Text("ENREGISTRER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: Text("Adresses enregistrées", style: TextStyle(color: textColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.orange))
        : _places.isEmpty 
          ? Center(child: Text("Aucune adresse enregistrée", style: TextStyle(color: textColor.withValues(alpha: 0.5))))
          : ListView.builder(
              itemCount: _places.length,
              itemBuilder: (context, index) {
                final place = _places[index];
                return ListTile(
                  leading: const CircleAvatar(backgroundColor: Colors.orange, child: Icon(Icons.location_on, color: Colors.white)),
                  title: Text(place.data['name'] ?? "Nom inconnu", style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                  subtitle: Text(place.data['address'] ?? "Sans adresse", style: TextStyle(color: textColor.withValues(alpha: 0.6))),
                  trailing: Icon(Icons.delete_outline, color: Colors.red.withValues(alpha: 0.7)),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPlaceDialog,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
