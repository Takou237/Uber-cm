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

  void _showAddPlaceDialog() {
    final nameController = TextEditingController();
    final addressController = TextEditingController();

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
            const SizedBox(height: 10),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: "Adresse complète", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                onPressed: () async {
                  if (nameController.text.isNotEmpty && addressController.text.isNotEmpty) {
                    await _appwrite.savePlace(
                      name: nameController.text,
                      address: addressController.text,
                      latitude: 0.0,
                      longitude: 0.0,
                    );
                    
                    // Correction de l'erreur "async gaps"
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    _fetchPlaces(); 
                  }
                },
                child: const Text("Enregistrer", style: TextStyle(color: Colors.white)),
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
