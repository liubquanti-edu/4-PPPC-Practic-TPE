import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import '../notifiers/theme_notifier.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, _) => ScaffoldPage(
        header: PageHeader(title: const Text('Налаштування')),
        content: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Тема програми'),
              const SizedBox(height: 10),
              RadioButton(
                checked: themeNotifier.themeMode == 'system',
                onChanged: (_) => themeNotifier.setTheme('system'),
                content: const Text('Системнв'),
              ),
              const SizedBox(height: 10),
              RadioButton(
                checked: themeNotifier.themeMode == 'light',
                onChanged: (_) => themeNotifier.setTheme('light'),
                content: const Text('Світла'),
              ),
              const SizedBox(height: 10),
              RadioButton(
                checked: themeNotifier.themeMode == 'dark',
                onChanged: (_) => themeNotifier.setTheme('dark'),
                content: const Text('Темна'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}