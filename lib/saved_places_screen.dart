import 'package:flutter/material.dart';
import 'package:uber_cm/services/appwrite_service.dart';
import 'package:appwrite/models.dart' as models;
import 'package:uber_cm/map_screen.dart';

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
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final places = await _appwrite.getFavoritePlaces();
      if (mounted) {
        setState(() {
          _places = places;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Erreur lors de la récupération : $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleDelete(String docId) async {
    try {
      await _appwrite.deletePlace(docId);
      _fetchPlaces();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lieu supprimé avec succès")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : ${e.toString()}")),
      );
    }
  }

  void _showAddPlaceDialog() {
    final nameController = TextEditingController();
    final addressController = TextEditingController();

    double selectedLat = 3.8667;
    double selectedLng = 11.5167;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Ajouter un lieu favori",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Nom (ex: Maison, Bureau)",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.label_important_outline),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: addressController,
                  readOnly: true,
                  onTap: () async {
                    _openMapPicker(addressController, (lat, lng) {
                      setModalState(() {
                        selectedLat = lat;
                        selectedLng = lng;
                      });
                    });
                  },
                  decoration: const InputDecoration( // <-- AJOUT DU CONST ICI
                    labelText: "Adresse exacte",
                    hintText: "Cliquez pour choisir sur la carte",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.map_outlined),
                    suffixIcon: Icon(
                      Icons.my_location,
                      color: Colors.orange,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      if (nameController.text.isNotEmpty &&
                          addressController.text.isNotEmpty) {
                        
                        await _appwrite.savePlace(
                          name: nameController.text,
                          address: addressController.text,
                          latitude: selectedLat,
                          longitude: selectedLng,
                        );

                        // VÉRIFICATION DU MOUNTED ICI
                        if (!context.mounted) return;
                        Navigator.pop(context); 
                        _fetchPlaces(); 
                      } else {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Veuillez remplir tous les champs"),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      "ENREGISTRER",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _openMapPicker(
    TextEditingController controller,
    Function(double, double) onCoordsUpdated,
  ) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MapScreen()),
    );

    if (result != null && result is Map<String, dynamic>) {
      controller.text = result['address'];
      onCoordsUpdated(result['latitude'], result['longitude']);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Adresses enregistrées",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : _places.isEmpty
          ? _buildEmptyState(textColor)
          : _buildPlacesList(isDark, textColor),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPlaceDialog,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState(Color textColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off_outlined,
            size: 80,
            // Correction ici : usage de .withValues
            color: textColor.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 10),
          Text(
            "Aucune adresse enregistrée",
            // Correction ici : usage de .withValues
            style: TextStyle(color: textColor.withValues(alpha: 0.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildPlacesList(bool isDark, Color textColor) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemCount: _places.length,
      itemBuilder: (context, index) {
        final place = _places[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Card(
            elevation: 0,
            color: isDark ? Colors.white10 : Colors.grey.shade100,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.orange,
                child: Icon(Icons.location_on, color: Colors.white),
              ),
              title: Text(
                place.data['name'] ?? "Nom inconnu",
                style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
              ),
              subtitle: Text(
                place.data['address'] ?? "Sans adresse",
                // Correction ici : usage de .withValues
                style: TextStyle(color: textColor.withValues(alpha: 0.6)),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () => _handleDelete(place.$id),
              ),
            ),
          ),
        );
      },
    );
  }
}
