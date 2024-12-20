import 'package:fluent_ui/fluent_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends ChangeNotifier {
  String _themeMode = 'system';

  String get themeMode => _themeMode;

  ThemeNotifier() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = prefs.getString('themeMode') ?? 'system';
    notifyListeners();
  }

  Future<void> setTheme(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode);
    _themeMode = mode;
    notifyListeners();
  }
}