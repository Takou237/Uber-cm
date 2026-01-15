import 'package:flutter/material.dart';
import 'package:appwrite/models.dart' as models;
import 'package:uber_cm/services/appwrite_service.dart';

class UserProvider with ChangeNotifier {
  final AppwriteService _appwrite = AppwriteService();
  models.User? _user;
  bool _isLoading = false;

  models.User? get user => _user;
  bool get isLoading => _isLoading;

  // Récupérer l'utilisateur une seule fois pour toute l'app
  Future<void> initUser() async {
    _isLoading = true;
    notifyListeners(); // Prévient les widgets d'afficher un loader

    _user = await _appwrite.getCurrentUser();
    
    _isLoading = false;
    notifyListeners(); // Prévient les widgets de cacher le loader et d'afficher les infos
  }
}