import 'package:flutter/material.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/explore_screen.dart';
import 'ui/screens/profile_screen.dart';
import 'ui/screens/about_screen.dart';

void main() => runApp(const AlbumLogApp());

class AlbumLogApp extends StatelessWidget {
  const AlbumLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AlbumLog',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6200EE),
          brightness: Brightness.dark, 
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
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeView(),
    const ExploreView(),
    const ProfileView(),
    const AboutScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.explore), label: 'Explorar'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Perfil'),
          NavigationDestination(icon: Icon(Icons.info), label: 'Acerca de'),
        ],
      ),
    );
  }
}