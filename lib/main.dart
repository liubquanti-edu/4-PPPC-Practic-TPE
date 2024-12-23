//-----------------------------------------
//-  Copyright (c) 2024. Liubchenko Oleh  -
//-----------------------------------------

import 'package:flutter/foundation.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'screens/markers_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/map_screen.dart';
import 'notifiers/theme_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, _) => FluentApp(
        title: 'Marker Manager',
        themeMode: themeNotifier.themeMode == 'system'
            ? ThemeMode.system
            : themeNotifier.themeMode == 'light'
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
        home: const RootNavigationView(),
      ),
    );
  }
}

class RootNavigationView extends StatefulWidget {
  const RootNavigationView({super.key});

  @override
  State<RootNavigationView> createState() => _RootNavigationViewState();
}

class _RootNavigationViewState extends State<RootNavigationView> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      pane: NavigationPane(
        selected: _selectedIndex,
        onChanged: (index) => setState(() => _selectedIndex = index),
        displayMode: PaneDisplayMode.compact,
        items: [
          PaneItem(
            icon: const Icon(FluentIcons.map_pin),
            title: const Text('Маркери'),
            body: const MarkersScreen(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.map_directions),
            title: const Text('Мапа'),
            body: const MapScreen(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.settings),
            title: const Text('Налаштування'),
            body: const SettingsScreen(),
          ),
        ],
      ),
    );
  }
}