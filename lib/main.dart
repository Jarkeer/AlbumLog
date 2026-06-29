import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:share_plus/share_plus.dart';
import 'ui/screens/explore_screen.dart';
import 'viewsmodel/preferences_viewmodel.dart';
import 'viewsmodel/qa_viewmodel.dart';
import 'ui/screens/qa_screen.dart';
import 'viewsmodel/auth_viewmodel.dart';
import 'ui/screens/profile_screen.dart';
import 'firebase_options.dart';
import 'services/local_preferences_services.dart';
import 'ui/screens/settings_screen.dart';
import 'ui/screens/about_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint("Flutter Error: ${details.exception}");
  };

  runZonedGuarded(() async {
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      debugPrint("Error cargando .env: $e");
    }

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      debugPrint("Error Firebase: $e");
    }

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => PreferencesViewModel()),
          ChangeNotifierProvider(create: (_) => QaViewModel()),
          ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ],
        child: const AlbumLogApp(),
      ),
    );
  }, (error, stackTrace) {
    debugPrint("ERROR GLOBAL: $error");
  });
}
class AlbumLogApp extends StatelessWidget {
  const AlbumLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    final prefsVM = Provider.of<PreferencesViewModel>(context);
    return MaterialApp(
      builder: (context, child) {
        ErrorWidget.builder = (FlutterErrorDetails details) {
          return const Scaffold(
            body: Center(
              child: Text("Algo salió mal"),
            ),
          );
        };
        return child!;
      },
      debugShowCheckedModeBanner: false,
      title: 'AlbumLog',
      themeMode: prefsVM.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.deepPurple),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.black,
          selectedItemColor: Colors.deepPurpleAccent,
          unselectedItemColor: Colors.grey,
        ),
      ),
      theme: ThemeData.light().copyWith(
        primaryColor: Colors.deepPurple,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.deepPurple),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.deepPurple,
          unselectedItemColor: Colors.grey,
        ),
      ),
      home: const MainNavigationWrapper(),
    );
  }
}

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const ExploreView(),   
    const ProfileScreen(), 
    const QaScreen(),      
    const SettingsScreen(),
    const AboutScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Explorar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.verified_user_outlined), 
            label: 'QA',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Ajustes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            label: 'Acerca',
          ),
        ],
      ),
    );
  }
}

