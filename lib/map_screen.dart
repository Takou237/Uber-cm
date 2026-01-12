import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  bool _isConverting = false;

  // Position actuelle du viseur au centre de la carte
  LatLng _currentMapCenter = const LatLng(3.8667, 11.5167);

  // Coordonnées par défaut (Yaoundé, Poste Centrale)
  final LatLng _center = const LatLng(3.8667, 11.5167);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _onCameraMove(CameraPosition position) {
    _currentMapCenter = position.target;
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    Position position = await Geolocator.getCurrentPosition();
    mapController.animateCamera(
      CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Choisir un lieu",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(target: _center, zoom: 14.0),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            onCameraMove: _onCameraMove,
          ),

          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 40),
              child: Icon(Icons.location_on, color: Colors.orange, size: 50),
            ),
          ),

          Positioned(
            bottom: 100,
            right: 20,
            child: FloatingActionButton(
              heroTag: "btn_gps",
              backgroundColor: Colors.white,
              onPressed: _getUserLocation,
              child: const Icon(Icons.my_location, color: Colors.orange),
            ),
          ),

          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: SizedBox(
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isConverting
                    ? null
                    : () async {
                        setState(() => _isConverting = true);

                        try {
                          // 1. Conversion des coordonnées (localeIdentifier retiré pour compatibilité Windows)
                          List<Placemark> placemarks =
                              await placemarkFromCoordinates(
                                _currentMapCenter.latitude,
                                _currentMapCenter.longitude,
                              );

                          String finalAddress = "Adresse inconnue";

                          if (placemarks.isNotEmpty) {
                            Placemark p = placemarks[0];
                            // Construction de l'adresse
                            finalAddress = "${p.street}, ${p.locality}";

                            // Nettoyage si l'adresse contient des codes Plus Code (+)
                            if (finalAddress.contains('+')) {
                              finalAddress =
                                  "${p.subLocality ?? p.name}, ${p.locality}";
                            }
                          }

                          if (mounted) {
                            Navigator.pop(context, {
                              'address': finalAddress,
                              'latitude': _currentMapCenter.latitude,
                              'longitude': _currentMapCenter.longitude,
                            });
                          }
                        } catch (e) {
                          debugPrint("Erreur geocoding: $e");
                          // Retour par défaut en cas d'erreur
                          Navigator.pop(context, {
                            'address':
                                "${_currentMapCenter.latitude.toStringAsFixed(4)}, ${_currentMapCenter.longitude.toStringAsFixed(4)}",
                            'latitude': _currentMapCenter.latitude,
                            'longitude': _currentMapCenter.longitude,
                          });
                        } finally {
                          if (mounted) setState(() => _isConverting = false);
                        }
                      },
                child: _isConverting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "CONFIRMER CE LIEU",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
