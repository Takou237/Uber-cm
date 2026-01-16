import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:uber_cm/services/price_service.dart';
import 'package:uber_cm/services/appwrite_service.dart';

class MapScreen extends StatefulWidget {
  final String? startAddress;
  final String? destinationAddress;
  final bool isPickingStartMode;

  const MapScreen({
    super.key,
    this.startAddress,
    this.destinationAddress,
    this.isPickingStartMode = false,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // --- IMPORTANT : ASSURE-TOI QUE CETTE CLÉ EST VALIDE ---
  final String googleApiKey = "AIzaSyDqJtH6hpF1i1ct9qHzKsqHh4wzMwZTzfw";

  late GoogleMapController mapController;
  final AppwriteService _appwriteService = AppwriteService();
  final PolylinePoints _polylinePoints = PolylinePoints();

  bool _isConverting = false;
  bool _showPricePanel = false;
  double _estimatedPrice = 0.0;
  String _selectedAddress = "Recherche de l'adresse...";

  final Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};
  
  LatLng _currentMapCenter = const LatLng(3.8667, 11.5167); // Centre par défaut (Yaoundé)
  LatLng _startLocation = const LatLng(3.8667, 11.5167);

  @override
  void initState() {
    super.initState();
    _checkInitialData();
  }

  void _checkInitialData() {
    if (widget.destinationAddress != null) {
      setState(() => _selectedAddress = widget.destinationAddress!);
      // On attend que la map soit prête
      Future.delayed(const Duration(milliseconds: 1500), () => _handleLocationSelection());
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _setInitialUserLocation();
  }

  Future<void> _setInitialUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _startLocation = LatLng(position.latitude, position.longitude);
        _currentMapCenter = _startLocation;
      });
      if (widget.destinationAddress == null) {
        mapController.animateCamera(CameraUpdate.newLatLng(_startLocation));
      }
    } catch (e) {
      debugPrint("Erreur localisation : $e");
    }
  }

  // RÉCUPÉRATION DE L'ITINÉRAIRE (SUR LES ROUTES)
  Future<void> _getRoutePolyline(LatLng destination) async {
    _polylines.clear();
    List<LatLng> polylineCoordinates = [];

    debugPrint("Calcul de la route de ${_startLocation.latitude} vers ${destination.latitude}");

    try {
      PolylineResult result = await _polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: googleApiKey,
        request: PolylineRequest(
          origin: PointLatLng(_startLocation.latitude, _startLocation.longitude),
          destination: PointLatLng(destination.latitude, destination.longitude),
          mode: TravelMode.driving,
        ),
      );

      if (result.points.isNotEmpty) {
        for (var point in result.points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }

        setState(() {
          _polylines.add(
            Polyline(
              polylineId: const PolylineId("route_poly"),
              color: Colors.black,
              width: 5,
              points: polylineCoordinates,
            ),
          );
          _zoomToFit(polylineCoordinates);
        });
      } else {
        debugPrint("Erreur API Directions : ${result.errorMessage}");
        // SI L'API ECHOUE, ON TRACE AU MOINS UNE LIGNE DROITE POUR NE PAS RESTER VIDE
        _drawFallbackLine(destination);
      }
    } catch (e) {
      debugPrint("Exception Polyline : $e");
    }
  }

  // Ligne de secours si l'API Directions ne répond pas
  void _drawFallbackLine(LatLng dest) {
    setState(() {
      _polylines.add(Polyline(
        polylineId: const PolylineId("fallback"),
        points: [_startLocation, dest],
        color: Colors.red,
        width: 3,
      ));
    });
  }

  void _zoomToFit(List<LatLng> points) {
    if (points.isEmpty) return;
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (var p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    mapController.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(southwest: LatLng(minLat, minLng), northeast: LatLng(maxLat, maxLng)),
        80,
      ),
    );
  }

  Future<void> _handleLocationSelection() async {
    setState(() {
      _isConverting = true;
      _showPricePanel = false; // On cache temporairement pour refresh
    });

    try {
      // 1. On récupère la route
      await _getRoutePolyline(_currentMapCenter);

      // 2. On calcule la distance
      double distance = PriceService.calculateDistance(
        _startLocation.latitude, _startLocation.longitude,
        _currentMapCenter.latitude, _currentMapCenter.longitude,
      );

      // 3. Mise à jour des marqueurs A et B
      setState(() {
        _markers.clear();
        _markers.add(Marker(
          markerId: const MarkerId("A"),
          position: _startLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ));
        _markers.add(Marker(
          markerId: const MarkerId("B"),
          position: _currentMapCenter,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ));
        
        _estimatedPrice = PriceService.calculatePrice(distance, 15);
        _showPricePanel = true;
        _isConverting = false;
      });
    } catch (e) {
      setState(() => _isConverting = false);
      debugPrint("Erreur sélection : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(target: _currentMapCenter, zoom: 15),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            markers: _markers,
            polylines: _polylines,
            onCameraMove: (pos) => _currentMapCenter = pos.target,
            onCameraIdle: () {
              if (!_showPricePanel) _updateAddressFromMap();
            },
          ),

          // Barre de recherche
          Positioned(top: 50, left: 15, right: 15, child: _buildSearchBar()),

          // L'épingle centrale (Cachée si l'itinéraire est là)
          if (!_showPricePanel)
            const Center(child: Padding(padding: EdgeInsets.only(bottom: 35), child: Icon(Icons.location_on, size: 50, color: Colors.black))),

          // Bouton de confirmation
          if (!_showPricePanel)
            Positioned(
              bottom: 40, left: 20, right: 20,
              child: _buildConfirmButton(),
            ),

          // Panel de prix
          if (_showPricePanel)
            Positioned(bottom: 0, left: 0, right: 0, child: _buildPricePanel()),
        ],
      ),
    );
  }

  // --- WIDGETS DE SOUTIEN ---

  void _updateAddressFromMap() async {
    try {
      List<Placemark> p = await placemarkFromCoordinates(_currentMapCenter.latitude, _currentMapCenter.longitude);
      if (p.isNotEmpty) setState(() => _selectedAddress = "${p[0].street}, ${p[0].locality}");
    } catch (e) { debugPrint(e.toString()); }
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      height: 55,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)]),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
          Expanded(child: Text(_selectedAddress, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity, height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: widget.isPickingStartMode ? Colors.blue : Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        onPressed: _isConverting ? null : () {
          if (widget.isPickingStartMode) {
            Navigator.pop(context, _selectedAddress);
          } else {
            _handleLocationSelection();
          }
        },
        child: _isConverting ? const CircularProgressIndicator(color: Colors.white) : Text(widget.isPickingStartMode ? "CONFIRMER LE DÉPART" : "CONFIRMER LA DESTINATION", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildPricePanel() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28)), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)]),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Uber CM Classique", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text("${_estimatedPrice.toInt()} F CFA", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orange)),
            ],
          ),
          const SizedBox(height: 20),
          // BOUTON RE-MODIFIER
          TextButton(onPressed: () => setState(() => _showPricePanel = false), child: const Text("Changer la destination")),
          SizedBox(
            width: double.infinity, height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: () {}, 
              child: const Text("COMMANDER MAINTENANT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}