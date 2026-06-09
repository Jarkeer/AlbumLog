import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'viewsmodel/preferences_viewmodel.dart';
import 'viewsmodel/qa_viewmodel.dart'; // 
import 'ui/screens/qa_screen.dart'; // 

void main() {
  runApp(
   
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PreferencesViewModel()),
        ChangeNotifierProvider(create: (_) => QaViewModel()), 
      child: const AlbumLogApp(),
    ),
  );
}

class AlbumLogApp extends StatelessWidget {
  const AlbumLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    final prefsVM = Provider.of<PreferencesViewModel>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AlbumLog',
      themeMode: prefsVM.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.black,
      ),
      theme: ThemeData.light(),
    
      home: const QaScreen(), 
    );
  }
}