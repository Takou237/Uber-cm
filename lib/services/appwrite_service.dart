import 'package:appwrite/appwrite.dart';

class AppwriteService {
  Client client = Client();
  late Account account;
  late Databases databases;
  late Functions functions;

  AppwriteService() {
    // Configuration de la connexion
    client
        .setEndpoint(
          'https://tor.cloud.appwrite.io/v1',
        ) // Mis à jour vers l'endpoint standard cloud
        .setProject('695d14e20018d8678d2c')
        .setSelfSigned(status: true);

    // Initialisation des outils
    account = Account(client);
    databases = Databases(client);
    functions = Functions(client);
  }

  /// Appelle la Cloud Function 'registerUser'
  Future<void> registerUser(
    String email,
    String password,
    String name,
    String role,
    String phone,
  ) async {
    try {
      final response = await functions.createExecution(
        functionId: 'registerUser',
        body:
            '{"email": "$email", "password": "$password", "name": "$name", "role": "$role", "phone": "$phone"}',
      );

      if (response.status == 'failed') {
        throw Exception("Erreur serveur : ${response.responseBody}");
      }
    } catch (e) {
      print("Erreur AppwriteService (Register): $e");
      throw Exception("Échec de l'inscription : $e");
    }
  }

  /// NOUVEAU : Connecte l'utilisateur en créant une session
  Future<void> loginUser(String email, String password) async {
    try {
      // Appwrite utilise createEmailPasswordSession pour le login
      await account.createEmailPasswordSession(
        email: email,
        password: password,
      );
    } catch (e) {
      print("Erreur AppwriteService (Login): $e");
      throw Exception("Échec de la connexion : $e");
    }
  }

  /// NOUVEAU : Déconnecte l'utilisateur (supprime la session actuelle)
  Future<void> logoutUser() async {
    try {
      await account.deleteSession(sessionId: 'current');
    } catch (e) {
      print("Erreur AppwriteService (Logout): $e");
      throw Exception("Échec de la déconnexion : $e");
    }
  }
}
