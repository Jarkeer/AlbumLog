import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:share_plus/share_plus.dart';

import 'viewsmodel/preferences_viewmodel.dart';
import 'ui/screens/preferences_screen.dart';
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
        onTap: (index) => setState(() => _currentIndex = index),
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
  final TextEditingController _searchController = TextEditingController();
  
  
  final String _lastFmApiKey = '3892c0bae522895e4cef36d817718d35';
  
  String _resultado = "Ingresa un artista o álbum para buscar";
  bool _isLoading = false;
  
  List<dynamic> _albumList = [];
  Map<String, dynamic>? _selectedAlbum;

  Future<void> _fetchDataFromLastFm() async {
    final String query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _resultado = "Por favor, escribe algo antes de buscar.";
        _albumList = [];
        _selectedAlbum = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _resultado = "Buscando en la base de datos de Last.fm...";
      _albumList = [];
      _selectedAlbum = null;
    });

    try {
      final String encodedQuery = Uri.encodeComponent(query);
      
      
      final url = Uri.parse('http://ws.audioscrobbler.com/2.0/?method=album.search&album=$encodedQuery&api_key=$_lastFmApiKey&format=json&limit=15');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
       
        final List<dynamic> albums = data['results']?['albummatches']?['album'] ?? [];
        
        if (albums.isNotEmpty) {
           // Filtramos álbumes que Last.fm manda sin nombre o sin imagen por error
           final validAlbums = albums.where((a) => a['name'] != '(null)' && a['name'] != '').toList();

           setState(() {
            _albumList = validAlbums;
            _resultado = "Se encontraron ${validAlbums.length} álbumes impecables.\nSelecciona el tuyo:";
          });
        } else {
          setState(() {
            _resultado = "No se encontraron álbumes para '$query'.";
          });
        }
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

  
  String _getImageUrl(List<dynamic>? images, String size) {
    if (images == null || images.isEmpty) return '';
    try {
      final imageObj = images.firstWhere((img) => img['size'] == size, orElse: () => images.last);
      return imageObj['#text'] ?? '';
    } catch (e) {
      return '';
    }
  }

  void _seleccionarAlbum(Map<String, dynamic> album) {
    setState(() {
      _selectedAlbum = album;
      _albumList = []; 
      _resultado = "¡Álbum seleccionado con éxito!";
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscador Musical (Last.fm)')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Buscar artista o álbum...',
                labelStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.deepPurple, width: 2.0)),
                prefixIcon: Icon(Icons.search, color: Colors.deepPurple),
              ),
              onSubmitted: (_) => _fetchDataFromLastFm(), 
            ),
            const SizedBox(height: 16),
            
            if (_isLoading) 
              const CircularProgressIndicator(color: Colors.deepPurple)
            else ...[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12)
                ),
                onPressed: _fetchDataFromLastFm,
                child: const Text('Buscar en la red', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
              const SizedBox(height: 16),
              Text(_resultado, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurpleAccent)),
            ],

            const SizedBox(height: 10),

            // LISTA DE RESULTADOS
            if (_albumList.isNotEmpty && _selectedAlbum == null)
              Expanded(
                child: ListView.builder(
                  itemCount: _albumList.length,
                  itemBuilder: (context, index) {
                    final album = _albumList[index];
                    final String albumName = album['name'] ?? 'Desconocido';
                    final String artistName = album['artist'] ?? 'Artista desconocido';
                    final String imageUrl = _getImageUrl(album['image'], 'large');

                    return Card(
                      color: Colors.grey[900],
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: imageUrl.isNotEmpty 
                            ? Image.network(imageUrl) 
                            : const Icon(Icons.album, color: Colors.grey, size: 50),
                        title: Text(albumName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Text(artistName, style: const TextStyle(color: Colors.grey)),
                        trailing: const Icon(Icons.touch_app, color: Colors.deepPurpleAccent),
                        onTap: () => _seleccionarAlbum(album),
                      ),
                    );
                  },
                ),
              ),

            // ÁLBUM SELECCIONADO
            if (_selectedAlbum != null)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Builder(
                      builder: (context) {
                        final String imageUrl = _getImageUrl(_selectedAlbum!['image'], 'extralarge');
                        if (imageUrl.isNotEmpty) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(imageUrl, height: 200, fit: BoxFit.cover),
                          );
                        }
                        return const Icon(Icons.album, color: Colors.grey, size: 100);
                      }
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _selectedAlbum!['name'] ?? 'Desconocido',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedAlbum!['artist'] ?? 'Artista desconocido',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 30),
                    
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)
                      ),
                      icon: const Icon(Icons.share, color: Colors.white),
                      label: const Text('Compartir Hallazgo', style: TextStyle(color: Colors.white)),
                      onPressed: () {
                        Share.share('¡Mira este álbum que encontré en AlbumLog! 🎧\n${_selectedAlbum!['name']} de ${_selectedAlbum!['artist']}');
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}