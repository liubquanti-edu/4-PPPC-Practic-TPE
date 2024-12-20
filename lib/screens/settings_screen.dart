import 'package:fluent_ui/fluent_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _themeMode = 'system';

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _themeMode = prefs.getString('themeMode') ?? 'system';
    });
  }

  Future<void> _saveThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode);
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(title: const Text('Settings')),
      content: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Theme Mode'),
            RadioButton(
              checked: _themeMode == 'system',
              onChanged: (value) => _saveThemeMode('system'),
              content: const Text('System'),
            ),
            RadioButton(
              checked: _themeMode == 'light',
              onChanged: (value) => _saveThemeMode('light'),
              content: const Text('Light'),
            ),
            RadioButton(
              checked: _themeMode == 'dark',
              onChanged: (value) => _saveThemeMode('dark'),
              content: const Text('Dark'),
            ),
          ],
        ),
      ),
    );
  }
}