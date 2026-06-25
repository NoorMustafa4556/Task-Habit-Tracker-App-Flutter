import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../main.dart'; // import to access global themeNotifier

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isNotificationEnabled = true;
  final StorageService _storageService = StorageService();

  String _username = "Noor Mustafa";
  String _email = "noormustafa4556@gmail.com";
  String _currentThemeLabel = "System Default";

  @override
  void initState() {
    super.initState();
    _loadProfileDetails();
  }

  void _loadProfileDetails() async {
    final name = await _storageService.getUsername();
    final email = await _storageService.getEmail();
    final themeModeStr = await _storageService.getThemeMode();

    String label = "System Default";
    if (themeModeStr == "light") label = "Light Mode";
    if (themeModeStr == "dark") label = "Dark Mode";

    setState(() {
      if (name != null && name.isNotEmpty) _username = name;
      if (email != null && email.isNotEmpty) _email = email;
      _currentThemeLabel = label;
    });
  }

  void _showThemeSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Choose App Theme",
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.brightness_5_outlined),
                title: const Text("Light Mode"),
                trailing: _currentThemeLabel == "Light Mode" ? Icon(Icons.check, color: theme.colorScheme.primary) : null,
                onTap: () => _updateTheme("light", "Light Mode"),
              ),
              ListTile(
                leading: const Icon(Icons.brightness_4_outlined),
                title: const Text("Dark Mode"),
                trailing: _currentThemeLabel == "Dark Mode" ? Icon(Icons.check, color: theme.colorScheme.primary) : null,
                onTap: () => _updateTheme("dark", "Dark Mode"),
              ),
              ListTile(
                leading: const Icon(Icons.settings_suggest_outlined),
                title: const Text("System Default"),
                trailing: _currentThemeLabel == "System Default" ? Icon(Icons.check, color: theme.colorScheme.primary) : null,
                onTap: () => _updateTheme("system", "System Default"),
              ),
            ],
          ),
        );
      },
    );
  }

  void _updateTheme(String modeStr, String label) async {
    Navigator.pop(context);
    await _storageService.saveThemeMode(modeStr);
    
    ThemeMode selectedMode = ThemeMode.system;
    if (modeStr == "light") selectedMode = ThemeMode.light;
    if (modeStr == "dark") selectedMode = ThemeMode.dark;

    themeNotifier.value = selectedMode;
    setState(() {
      _currentThemeLabel = label;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: theme.brightness == Brightness.light
                ? [colorScheme.primary.withOpacity(0.05), Colors.white]
                : [colorScheme.primary.withOpacity(0.02), Colors.black],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          children: [
            // Profile Card (Header)
            Card(
              elevation: 4,
              shadowColor: Colors.black12,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: theme.brightness == Brightness.light
                        ? [colorScheme.primary.withOpacity(0.1), colorScheme.primary.withOpacity(0.02)]
                        : [colorScheme.surface, colorScheme.surface.withOpacity(0.9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                      child: Text(
                        _username.isNotEmpty ? _username[0].toUpperCase() : "U",
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _username,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _email,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.hintColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Settings Options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Text(
                "Preferences",
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            Card(
              elevation: 1,
              shadowColor: Colors.black12,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text("Enable Notifications"),
                    subtitle: const Text("Receive reminder notifications"),
                    secondary: Icon(Icons.notifications_active_outlined, color: colorScheme.primary),
                    value: _isNotificationEnabled,
                    onChanged: (bool value) {
                      setState(() {
                        _isNotificationEnabled = value;
                      });
                    },
                  ),
                  const Divider(height: 1, indent: 64),
                  ListTile(
                    leading: Icon(Icons.palette_outlined, color: colorScheme.primary),
                    title: const Text("App Theme"),
                    subtitle: Text(_currentThemeLabel),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: _showThemeSelector,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Logout Card
            Card(
              elevation: 1,
              shadowColor: Colors.black12,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                title: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.redAccent),
                onTap: () async {
                  await _storageService.clearData();
                  if (mounted) {
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
