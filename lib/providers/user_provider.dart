import 'package:flutter/material.dart';
import 'package:appwrite/models.dart' as models;
import 'package:uber_cm/services/appwrite_service.dart';

class UserProvider with ChangeNotifier {
  final AppwriteService _appwrite = AppwriteService();
  
  models.User? _user;
  bool _isLoading = false;

  models.User? get user => _user;
  bool get isLoading => _isLoading;

  // Cette fonction charge l'utilisateur et prévient tout le monde
  Future<void> refreshUser() async {
    _isLoading = true;
    notifyListeners(); 

    try {
      _user = await _appwrite.account.get().timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint("Erreur Provider User: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  initUser() {}
}