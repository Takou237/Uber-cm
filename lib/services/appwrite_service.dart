import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter/foundation.dart';

class AppwriteService {
  Client client = Client();
  late Account account;
  late Databases databases;
  late Functions functions;

  final String databaseId = '695d14e20018d8678d2c';
  final String placesCollectionId = 'user_places';

  AppwriteService() {
    client
        .setEndpoint('https://tor.cloud.appwrite.io/v1')
        .setProject('695d14e20018d8678d2c')
        .setSelfSigned(status: true);

    account = Account(client);
    databases = Databases(client);
    functions = Functions(client);
  }

  // --- AUTHENTIFICATION ---

  // Inscription
  Future<void> registerUser(String email, String password, String name, String role, String phone) async {
    try {
      await account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );
      // Optionnel: On peut ajouter le téléphone ou le rôle dans une collection 'users' ici
      debugPrint("Utilisateur créé avec succès");
    } catch (e) {
      debugPrint("Erreur Inscription: $e");
      throw Exception("Échec de l'inscription");
    }
  }

  // Connexion (Crucial pour la session persistante)
  Future<void> loginUser(String email, String password) async {
    try {
      // Création d'une session email
      await account.createEmailPasswordSession(
        email: email,
        password: password,
      );
      debugPrint("Connexion réussie");
    } catch (e) {
      debugPrint("Erreur Connexion: $e");
      throw Exception("Email ou mot de passe incorrect");
    }
  }

  // Déconnexion
  Future<void> logout() async {
    try {
      await account.deleteSession(sessionId: 'current');
      debugPrint("Déconnexion réussie");
    } catch (e) {
      debugPrint("Erreur Déconnexion: $e");
    }
  }

  // --- GESTION DES LIEUX (FAVORIS) ---

  // Récupérer les lieux
  Future<List<models.Document>> getFavoritePlaces() async {
    try {
      final user = await account.get();
      
      // ignore: deprecated_member_use
      final response = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: placesCollectionId,
        queries: [
          Query.equal('userId', user.$id),
        ],
      );
      return response.documents; 
    } catch (e) {
      debugPrint("Erreur lecture lieux: $e");
      return [];
    }
  }

  // Enregistrer un lieu
  Future<void> savePlace({
    required String name, 
    required String address, 
    required double latitude, 
    required double longitude
  }) async {
    try {
      final user = await account.get();
      
      // ignore: deprecated_member_use
      await databases.createDocument(
        databaseId: databaseId,
        collectionId: placesCollectionId,
        documentId: ID.unique(),
        data: {
          'name': name,
          'address': address,
          'latitude': latitude,
          'longitude': longitude,
          'userId': user.$id,
          'createdAt': DateTime.now().toIso8601String(),
        },
      );
      debugPrint("Lieu sauvegardé !");
    } catch (e) {
      debugPrint("Erreur sauvegarde lieu: $e");
      throw Exception("Impossible de sauvegarder ce lieu.");
    }
  }
}
