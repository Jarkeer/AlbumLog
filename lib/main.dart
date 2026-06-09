import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Preferencias
import 'viewsmodel/preferences_viewmodel.dart';
import 'ui/screens/preferences_screen.dart';

// Encuesta
import 'viewsmodel/qa_viewmodel.dart';
import 'ui/screens/qa_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PreferencesViewModel()),
        ChangeNotifierProvider(create: (_) => QaViewModel()),
      ],
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
    const PoCScreen(),
    const PreferencesScreen(),
    const QaScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'PoC iTunes'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Configuración'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_turned_in), label: 'Beta Test QA'),
        ],
      ),
    );
  }
}

class PoCScreen extends StatefulWidget {
  const PoCScreen({super.key});

  @override
  State<PoCScreen> createState() => _PoCScreenState();
}

class _PoCScreenState extends State<PoCScreen> {
  String _resultado = "Presiona el botón para buscar a Daft Punk";
  bool _isLoading = false;

  Future<void> _fetchDataFromiTunes() async {
    setState(() {
      _isLoading = true;
      _resultado = "Conectando a la API de iTunes...";
    });

    try {
      final url = Uri.parse('https://itunes.apple.com/search?term=daft+punk&entity=album&limit=1');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final albumName = data['results'][0]['collectionName'];
        final artistName = data['results'][0]['artistName'];

        setState(() {
          _resultado = "¡Éxito!\n\nÁlbum encontrado: $albumName\nArtista: $artistName";
        });
      } else {
        setState(() {
          _resultado = "Error de servidor: Código ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _resultado = "Fallo de conexión:\n$e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PoC: iTunes API')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_resultado, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 30),
              if (_isLoading) 
                const CircularProgressIndicator(color: Colors.deepPurple)
              else
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                  onPressed: _fetchDataFromiTunes,
                  child: const Text('Ejecutar Transacción HTTP', style: TextStyle(color: Colors.white)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}