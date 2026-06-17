import 'package:flutter/material.dart';
import 'package:kotabi/screens/main_shell.dart';
import 'package:kotabi/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KotabiApp());
}

class KotabiApp extends StatelessWidget {
  const KotabiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KOTABI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const MainShell(),
    );
  }
}
