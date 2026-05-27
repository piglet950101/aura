import 'package:aura/core/theme/aura_theme.dart';
import 'package:aura/features/home/home_screen.dart';
import 'package:flutter/material.dart';

class AuraApp extends StatelessWidget {
  const AuraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AURA',
      debugShowCheckedModeBanner: false,
      theme: AuraTheme.dark,
      darkTheme: AuraTheme.dark,
      themeMode: ThemeMode.dark,
      home: const HomeScreen(),
    );
  }
}
