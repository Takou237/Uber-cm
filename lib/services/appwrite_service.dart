import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter/foundation.dart';

class AppwriteService {
  Client client = Client();
  late Account account;
  late Databases databases;
  late Functions functions;

  // Tes IDs réels
  final String databaseId = '695d1b430005eb249f4b';
  final String usersCollectionId = 'profiles';
  final String placesCollectionId = 'user_places';
  final String ridesCollectionId =
      'rides'; // ID à créer dans ta console Appwrite

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

  Future<models.User?> getCurrentUser() async {
    try {
      return await account.get();
    } catch (e) {
      return null;
    }
  }

  Future<models.Document?> getUserProfile(String userId) async {
    try {
      return await databases.getDocument(
        databaseId: databaseId,
        collectionId: usersCollectionId,
        documentId: userId,
      );
    } catch (e) {
      debugPrint("Erreur récupération profil: $e");
      return null;
    }
  }

  Future<void> registerUser(
    String email,
    String password,
    String name,
    String role,
    String phone,
  ) async {
    try {
      final user = await account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );

      await databases.createDocument(
        databaseId: databaseId,
        collectionId: usersCollectionId,
        documentId: user.$id,
        data: {
          'userId': user.$id,
          'name': name,
          'email': email,
          'role': role,
          'phone': phone,
          'createdAt': DateTime.now().toIso8601String(),
        },
      );
      debugPrint("Utilisateur et profil créés !");
    } catch (e) {
      debugPrint("Erreur Inscription: $e");
      throw Exception("Échec de l'inscription : $e");
    }
  }

  Future<void> loginUser(String email, String password) async {
    try {
      await account.createEmailPasswordSession(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception("Identifiants incorrects");
    }
  }

  Future<void> logout() async {
    try {
      await account.deleteSession(sessionId: 'current');
    } catch (e) {
      debugPrint("Erreur Déconnexion: $e");
    }
  }

  // --- GESTION DES LIEUX (FAVORIS) ---

  Future<List<models.Document>> getFavoritePlaces() async {
    try {
      final user = await account.get();
      final response = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: placesCollectionId,
        queries: [
          Query.equal('userId', user.$id),
          Query.orderDesc('createdAt'),
        ],
      );
      return response.documents;
    } catch (e) {
      debugPrint("Erreur lecture lieux: $e");
      return [];
    }
  }

  Future<void> savePlace({
    required String name,
    required String address,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final user = await account.get();

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
      debugPrint("Lieu sauvegardé avec succès");
    } catch (e) {
      debugPrint("ERREUR DÉTAILLÉE APPWRITE: $e");
      throw Exception("Impossible de sauvegarder ce lieu.");
    }
  }

  Future<void> deletePlace(String documentId) async {
    try {
      await databases.deleteDocument(
        databaseId: databaseId,
        collectionId: placesCollectionId,
        documentId: documentId,
      );
    } catch (e) {
      throw Exception("Erreur lors de la suppression.");
    }
  }

  // --- GESTION DES COURSES (RIDES) ---

  /// Crée une nouvelle demande de course
  Future<void> createRide({
    required String destinationAddress,
    required double destinationLat,
    required double destinationLng,
    required double price,
    required String sourceAddress,
  }) async {
    try {
      final user = await account.get();

      await databases.createDocument(
        databaseId: databaseId,
        collectionId: ridesCollectionId,
        documentId: ID.unique(),
        data: {
          'userId': user.$id,
          'userName': user.name,
          'sourceAddress': sourceAddress,
          'destinationAddress': destinationAddress,
          'destinationLat': destinationLat,
          'destinationLng': destinationLng,
          'price': price,
          'status':
              'pending', // pending, accepted, ongoing, completed, cancelled
          'createdAt': DateTime.now().toIso8601String(),
        },
      );
      debugPrint("Course créée avec succès dans Appwrite");
    } catch (e) {
      debugPrint("Erreur création course: $e");
      throw Exception("Impossible de commander la course.");
    }
  }
}
