import 'package:appwrite/appwrite.dart';

class AppwriteService {
  Client client = Client();
  late Account account;
  late Databases databases;
  late Functions functions;

  AppwriteService() {
    client
        .setEndpoint('https://tor.cloud.appwrite.io/v1')
        .setProject('695d14e20018d8678d2c')
        .setSelfSigned(status: true);

    account = Account(client);
    databases = Databases(client);
    functions = Functions(client);
  }

  Future<void> registerUser(String email, String password, String name, String role, String phone) async {
    try {
      final response = await functions.createExecution(
        functionId: 'registerUser',
        body: '{"email": "$email", "password": "$password", "name": "$name", "role": "$role", "phone": "$phone"}',
      );
      if (response.status == 'failed') throw Exception("Erreur serveur : ${response.responseBody}");
    } catch (e) {
      throw Exception("Échec de l'inscription : $e");
    }
  }

  Future<void> loginUser(String email, String password) async {
    try {
      await account.createEmailPasswordSession(email: email, password: password);
    } catch (e) {
      throw Exception("Échec de la connexion : $e");
    }
  }

  // CHANGEMENT ICI : Renommé en logout() pour correspondre à ProfileScreen
  Future<void> logout() async {
    try {
      await account.deleteSession(sessionId: 'current');
    } catch (e) {
      throw Exception("Échec de la déconnexion : $e");
    }
  }
}