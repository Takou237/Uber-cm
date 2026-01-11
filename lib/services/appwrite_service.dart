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

  // ... (Garde registerUser, loginUser et logout tels quels) ...

  /// RÉCUPÉRER (Mise à jour avec listDocuments ou syntaxe alternative selon ton SDK)
  Future<List<models.Document>> getFavoritePlaces() async {
    try {
      final user = await account.get();
      
      // Note: Si 'listRows' n'est pas reconnu par ton SDK actuel,
      // utilise cette syntaxe qui reste la plus propre :
      final response = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: placesCollectionId,
        queries: [
          Query.equal('userId', user.$id),
        ],
      );
      return response.documents;
    } catch (e) {
      debugPrint("Note: La collection n'est pas encore accessible ($e)");
      return [];
    }
  }

  /// ENREGISTRER (Mise à jour avec la nouvelle syntaxe recommandée)
  Future<void> savePlace({
    required String name, 
    required String address, 
    required double latitude, 
    required double longitude
  }) async {
    try {
      final user = await account.get();
      
      // La recommandation 'createRow' concerne l'évolution interne d'Appwrite.
      // Pour le SDK Flutter actuel, on continue d'utiliser createDocument
      // mais on s'assure d'utiliser les bons paramètres.
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
    } catch (e) {
      debugPrint("Erreur lors de l'enregistrement de l'adresse : $e");
      throw Exception("Impossible de sauvegarder ce lieu.");
    }
  }

  Future<void> loginUser(String trim, String trim2) async {}
  Future<void> logout() async {}
  Future<void> registerUser(String trim, String trim2, String trim3, String selectedRole, String trim4) async {}
}