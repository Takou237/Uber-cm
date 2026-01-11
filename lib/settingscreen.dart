class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AppwriteService _appwrite = AppwriteService();
  
  String _name = "Chargement...";
  String _phone = "...";
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
          // Si le nom est vide sur Appwrite, on affiche "Utilisateur"
          _name = (user.name != null && user.name.isNotEmpty) ? user.name : "Utilisateur";
          _phone = user.phone;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _name = "Non connecté";
          _isLoading = false;
        });
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
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: txtColor, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- GRAND TITRE ---
                  const Text(
                    "Paramètres",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 40),

                  // --- AFFICHAGE NOM ---
                  _buildReadOnlyInfo(
                    label: "NOM",
                    value: _name,
                    textColor: txtColor,
                  ),
                  
                  const SizedBox(height: 30),

                  // --- AFFICHAGE TÉLÉPHONE ---
                  _buildReadOnlyInfo(
                    label: "TÉLÉPHONE",
                    value: _phone,
                    textColor: txtColor,
                  ),

                  const SizedBox(height: 40),
                  const Divider(thickness: 0.5),
                  const SizedBox(height: 20),

                  // --- OPTIONS ---
                  _buildRowOption(
                    icon: isDark ? Icons.dark_mode : Icons.light_mode,
                    title: "Mode Sombre",
                    textColor: txtColor,
                    trailing: Switch(
                      value: isDark,
                      activeColor: Colors.orange,
                      onChanged: (v) => themeNotifier.value = v ? ThemeMode.dark : ThemeMode.light,
                    ),
                  ),

                  _buildRowOption(
                    icon: Icons.language,
                    title: "Langue",
                    subtitle: _lang,
                    textColor: txtColor,
                    onTap: () => _showLanguageSelector(),
                  ),
                ],
              ),
            ),
        );
      },
    );
  }

  // Widget pour afficher les infos sans pouvoir les modifier
  Widget _buildReadOnlyInfo({
    required String label,
    required String value,
    required Color textColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w400),
        ),
        const SizedBox(height: 10),
        Container(height: 1, color: Colors.grey.withOpacity(0.2)),
      ],
    );
  }

  Widget _buildRowOption({required IconData icon, required String title, String? subtitle, required Color textColor, Widget? trailing, VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.orange),
      title: Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(color: Colors.grey)) : null,
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
    );
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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