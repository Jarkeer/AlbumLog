import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewsmodel/preferences_viewmodel.dart'; 
import 'ui/screens/preferences_screen.dart';  
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => PreferencesViewModel(),
      child: const AlbumLogApp(),
    ),
  );
}

class AlbumLogApp extends StatelessWidget {
  const AlbumLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchamos el ViewModel para saber qué tema aplicar
    final prefsVM = Provider.of<PreferencesViewModel>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AlbumLog',
      themeMode: prefsVM.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.black, 
        appBarTheme: const AppBarTheme(backgroundColor: Colors.deepPurple),
      ),
      theme: ThemeData.light().copyWith(
        primaryColor: Colors.deepPurple,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.deepPurple),
      ),
      home: const PreferencesScreen(), 
    );
  }
}