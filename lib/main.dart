import 'package:flutter/foundation.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'screens/markers_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/map_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final prefs = await SharedPreferences.getInstance();
  final themeMode = prefs.getString('themeMode') ?? 'system';
  runApp(MyApp(themeMode: themeMode));
}

class MyApp extends StatefulWidget {
  final String themeMode;
  const MyApp({super.key, required this.themeMode});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late String _themeMode;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.themeMode;
  }

  void _updateThemeMode(String mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: 'Marker Manager',
      themeMode: _themeMode == 'system'
          ? ThemeMode.system
          : _themeMode == 'light'
              ? ThemeMode.light
              : ThemeMode.dark,
      theme: FluentThemeData(
        brightness: Brightness.light,
        accentColor: Colors.blue,
      ),
      darkTheme: FluentThemeData(
        brightness: Brightness.dark,
        accentColor: Colors.blue,
      ),
      home: NavigationView(
        pane: NavigationPane(
          selected: _selectedIndex,
          onChanged: (index) => setState(() => _selectedIndex = index),
          displayMode: PaneDisplayMode.compact,
          items: [
            PaneItem(
              icon: const Icon(FluentIcons.map_pin),
              title: const Text('Markers'),
              body: const MarkersScreen(),
            ),
            PaneItem(
              icon: const Icon(FluentIcons.settings),
              title: const Text('Settings'),
              body: const SettingsScreen(),
            ),
            PaneItem(
              icon: const Icon(FluentIcons.map_directions),
              title: const Text('Map'),
              body: const MapScreen(),
            ),
          ],
        ),
      ),
    );
  }
}