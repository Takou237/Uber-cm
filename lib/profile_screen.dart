import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app_settings/app_settings.dart'; 
import 'package:uber_cm/services/appwrite_service.dart';

// --- VARIABLE GLOBALE POUR LE THÈME ---
ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

// ==========================================
// 1. PAGE DE PROFIL (ÉCRAN PRINCIPAL)
// ==========================================
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  final AppwriteService _appwrite = AppwriteService();

  String _userName = "Chargement...";
  String _userPhone = "...";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Récupère les vraies infos depuis Appwrite
  void _loadUserData() async {
    try {
      final user = await _appwrite.account.get();
      if (mounted) {
        setState(() {
          _userName = (user.name.isNotEmpty) ? user.name : "Utilisateur Uber-CM";
          _userPhone = user.phone;
        });
      }
    } catch (e) {
      debugPrint("Erreur ProfileScreen: $e");
    }
  }

  // Menu pour choisir la source de la photo
  Future<void> _handleChangePhoto() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Photo de profil", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _photoOption(Icons.camera_alt, "Caméra", ImageSource.camera),
                _photoOption(Icons.photo_library, "Galerie", ImageSource.gallery),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _photoOption(IconData icon, String label, ImageSource source) {
    return InkWell(
      onTap: () async {
        Navigator.pop(context);
        final XFile? image = await _picker.pickImage(source: source);
        if (image != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Image sélectionnée : ${image.name}")));
        }
      },
      child: Column(
        children: [
          CircleAvatar(radius: 30, backgroundColor: Colors.orange.withOpacity(0.1), child: Icon(icon, color: Colors.orange, size: 30)),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, _) {
        final bool isDark = currentMode == ThemeMode.dark;
        final textColor = isDark ? Colors.white : Colors.black;
        final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

        return Scaffold(
          appBar: AppBar(
            title: Text("Mon compte", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
            centerTitle: true,
            backgroundColor: cardColor,
            elevation: 0,
            iconTheme: IconThemeData(color: textColor),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // CARTE PROFIL AVEC LE CRAYON
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _handleChangePhoto,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: isDark ? Colors.white10 : Colors.black12,
                              child: Icon(Icons.person, size: 45, color: isDark ? Colors.white70 : Colors.black54),
                            ),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                              child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_userName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                            Text(_userPhone, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: Colors.orange, size: 22),
                        onPressed: () async {
                          await Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
                          _loadUserData(); // Rafraîchit au retour
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                _sectionTitle("Compte & Services"),
                _customTile(icon: Icons.notifications_active_outlined, title: "Notifications", textColor: textColor, cardColor: cardColor, onTap: () => AppSettings.openAppSettings(type: AppSettingsType.notification)),
                _customTile(icon: Icons.account_balance_wallet_outlined, title: "Mode de paiement", textColor: textColor, cardColor: cardColor, onTap: () {}),
                _customTile(icon: Icons.location_on_outlined, title: "Ajouter une adresse", textColor: textColor, cardColor: cardColor, onTap: () {}),
                _customTile(icon: Icons.history, title: "Historique des courses", textColor: textColor, cardColor: cardColor, onTap: () {}),
                const SizedBox(height: 15),
                _sectionTitle("Réglages"),
                _customTile(
                  icon: Icons.settings_outlined,
                  title: "Paramètres",
                  textColor: textColor,
                  cardColor: cardColor,
                  onTap: () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
                    _loadUserData();
                  },
                ),
                _customTile(icon: Icons.help_outline, title: "Aide & Support", textColor: textColor, cardColor: cardColor, onTap: () {}),
                const SizedBox(height: 30),
                _buildLogoutButton(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Align(alignment: Alignment.centerLeft, child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange))),
    );
  }

  Widget _customTile({required IconData icon, required String title, required Color textColor, required Color cardColor, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.orange),
        title: Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.logout),
        label: const Text("Se déconnecter"),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      ),
    );
  }
}

// ==========================================
// 2. PAGE PARAMÈTRES (MODIFICATIONS ICI)
// ==========================================
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AppwriteService _appwrite = AppwriteService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _lang = "Français";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() async {
    try {
      final user = await _appwrite.account.get();
      if (mounted) {
        setState(() {
          _nameController.text = user.name;
          _phoneController.text = user.phone;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);
    try {
      await _appwrite.account.updateName(name: _nameController.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profil mis à jour"), backgroundColor: Colors.green));
        Navigator.pop(context); // Retour automatique après sauvegarde
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur : $e"), backgroundColor: Colors.red));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;
        final txtColor = isDark ? Colors.white : Colors.black;

        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => Navigator.pop(context)),
            actions: [
              IconButton(icon: const Icon(Icons.check, color: Colors.orange, size: 28), onPressed: _saveChanges)
            ],
          ),
          body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Paramètres", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 40),
                  
                  // NOM
                  _buildSimpleField("NOM", _nameController, txtColor),
                  const SizedBox(height: 25),
                  
                  // TÉLÉPHONE
                  _buildSimpleField("TÉLÉPHONE", _phoneController, txtColor, enabled: false),

                  const SizedBox(height: 40),
                  const Divider(),
                  
                  // THÈME
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(isDark ? Icons.dark_mode : Icons.light_mode, color: Colors.orange),
                    title: Text("Mode Sombre", style: TextStyle(color: txtColor)),
                    trailing: Switch(value: isDark, activeColor: Colors.orange, onChanged: (v) => themeNotifier.value = v ? ThemeMode.dark : ThemeMode.light),
                  ),
                  
                  // LANGUE
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.language, color: Colors.orange),
                    title: Text("Langue", style: TextStyle(color: txtColor)),
                    subtitle: Text(_lang),
                    onTap: _chooseLang,
                  ),
                ],
              ),
            ),
        );
      },
    );
  }

  Widget _buildSimpleField(String label, TextEditingController controller, Color color, {bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold)),
        TextField(
          controller: controller,
          enabled: enabled,
          style: TextStyle(color: color, fontSize: 18),
          decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 8)),
        ),
        Container(height: 1, color: Colors.grey.withOpacity(0.2)),
      ],
    );
  }

  void _chooseLang() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(title: const Text("Français"), onTap: () { setState(() => _lang = "Français"); Navigator.pop(context); }),
          ListTile(title: const Text("English"), onTap: () { setState(() => _lang = "English"); Navigator.pop(context); }),
        ],
      ),
    );
  }
}