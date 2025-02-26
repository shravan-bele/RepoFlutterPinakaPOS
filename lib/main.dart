import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Helper/Extentions/theme_notifier.dart';
import 'Screens/Auth/splash_screen.dart';


void main() {
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
    final themeHelper = Provider.of<ThemeNotifier>(context);
    return SafeArea(  //Build #1.0.2 : Fixed - status bar overlapping with design
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeNotifier.lightTheme,
        darkTheme: ThemeNotifier.darkTheme,
        themeMode: themeHelper.themeMode,
        home: Scaffold(
          body: SplashScreen(),
        ),
      ),
    );
  }
}
