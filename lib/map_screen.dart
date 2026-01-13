import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:uber_cm/services/price_service.dart';
import 'package:uber_cm/services/appwrite_service.dart';
// N'oublie pas de créer ce fichier ou de l'importer correctement
// import 'package:uber_cm/screens/searching_driver_screen.dart';
import 'package:flutter/foundation.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  final AppwriteService _appwriteService = AppwriteService();

  bool _isConverting = false;
  bool _isBooking = false;

  bool _showPricePanel = false;
  double _estimatedPrice = 0.0;
  String _selectedAddress = "";

  LatLng _currentMapCenter = const LatLng(3.8667, 11.5167);
  final LatLng _center = const LatLng(3.8667, 11.5167);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _onCameraMove(CameraPosition position) {
    _currentMapCenter = position.target;
    if (_showPricePanel) {
      setState(() => _showPricePanel = false);
    }
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    Position position = await Geolocator.getCurrentPosition();
    mapController.animateCamera(
      CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
    );
  }

  Future<void> _handleLocationSelection() async {
    setState(() => _isConverting = true);

    try {
      Position currentPos = await Geolocator.getCurrentPosition();

      double distance = PriceService.calculateDistance(
        currentPos.latitude,
        currentPos.longitude,
        _currentMapCenter.latitude,
        _currentMapCenter.longitude,
      );

      double estimatedDuration = (distance / 25) * 60;

      String finalAddr =
          "Position (${_currentMapCenter.latitude.toStringAsFixed(3)}, ${_currentMapCenter.longitude.toStringAsFixed(3)})";

      if (!kIsWeb) {
        try {
          List<Placemark> placemarks = await placemarkFromCoordinates(
            _currentMapCenter.latitude,
            _currentMapCenter.longitude,
          ).timeout(const Duration(seconds: 3));

          if (placemarks.isNotEmpty) {
            Placemark p = placemarks[0];
            finalAddr = "${p.street ?? p.name}, ${p.locality}";
          }
        } catch (e) {
          debugPrint("Erreur Geocoding : $e");
        }
      }

      if (mounted) {
        setState(() {
          _isConverting = false;
          _selectedAddress = finalAddr;
          _estimatedPrice = PriceService.calculatePrice(
            distance,
            estimatedDuration,
          );
          _showPricePanel = true;
        });
      }
    } catch (e) {
      debugPrint("Erreur de sélection : $e");
      if (mounted) setState(() => _isConverting = false);
    }
  }

  Future<void> _confirmRide() async {
    setState(() => _isBooking = true);

    try {
      // Appel au service Appwrite
      await _appwriteService.createRide(
        sourceAddress: "Ma position actuelle",
        destinationAddress: _selectedAddress,
        destinationLat: _currentMapCenter.latitude,
        destinationLng: _currentMapCenter.longitude,
        price: _estimatedPrice,
      );

      if (mounted) {
        // Redirection vers l'écran de recherche de chauffeur
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => const SearchingDriverScreen())
        // );

        // En attendant que tu crées l'écran, on affiche ce message :
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Course envoyée ! Recherche d'un chauffeur..."),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Erreur : Vérifiez les attributs Appwrite (userName...)",
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Où allez-vous ?",
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
            padding: EdgeInsets.only(bottom: _showPricePanel ? 230 : 0),
          ),

          if (!_showPricePanel)
            IgnorePointer(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.orange,
                    size: 50,
                  ),
                ),
              ),
            ),

          Positioned(
            bottom: _showPricePanel ? 240 : 100,
            right: 20,
            child: FloatingActionButton(
              heroTag: "btn_gps",
              backgroundColor: Colors.white,
              onPressed: _getUserLocation,
              child: const Icon(Icons.my_location, color: Colors.orange),
            ),
          ),

          if (!_showPricePanel)
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
                  onPressed: _isConverting ? null : _handleLocationSelection,
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
                          "CONFIRMER LA DESTINATION",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),

          if (_showPricePanel)
            Positioned(bottom: 0, left: 0, right: 0, child: _buildPricePanel()),
        ],
      ),
    );
  }

  Widget _buildPricePanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 15, spreadRadius: 5),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.orange),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _selectedAddress,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Divider(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Uber CM (Classique)",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                "${_estimatedPrice.toInt()} FCFA",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _isBooking ? null : _confirmRide,
              child: _isBooking
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      "CONFIRMER LA POSITION",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
