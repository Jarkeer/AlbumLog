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
  String _resultado = "Ingresa un artista o álbum para buscar";
  bool _isLoading = false;
  List<dynamic> _albumList = [];
  Map<String, dynamic>? _selectedAlbum;

  
  Future<void> _fetchDataFromiTunes() async {
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
      _resultado = "Buscando en iTunes...";
      _albumList = [];
      _selectedAlbum = null;
    });

    try {
     
      final List<dynamic> allResults = [];
      final String encodedQuery = Uri.encodeComponent(query);

      
      final albumResponse = await http.get(Uri.parse(
        'https://itunes.apple.com/search?term=$encodedQuery&entity=album&limit=200&country=US',
      ));
      if (albumResponse.statusCode == 200) {
        final data = json.decode(albumResponse.body);
        allResults.addAll(data['results'] ?? []);
        print('Petición 1 (texto): ${(data['results'] ?? []).length} resultados');
      }

      
      final artistResponse = await http.get(Uri.parse(
        'https://itunes.apple.com/search?term=$encodedQuery&entity=musicArtist&limit=3&country=US',
      ));

      if (artistResponse.statusCode == 200) {
        final artistData = json.decode(artistResponse.body);
        final List<dynamic> artists = artistData['results'] ?? [];
        print('Petición 2 (artistas): ${artists.length} artistas encontrados');

  
        final discografiaFutures = artists.map((artist) {
          final int artistId = artist['artistId'];
          print('  Buscando discografía de artistId: $artistId - ${artist['artistName']}');
          return http.get(Uri.parse(
            'https://itunes.apple.com/lookup?id=$artistId&entity=album&limit=200&country=US',
          ));
        }).toList();

        final discografiaResponses = await Future.wait(discografiaFutures);

        for (final r in discografiaResponses) {
          if (r.statusCode == 200) {
            final albumData = json.decode(r.body);
            final albums = (albumData['results'] ?? [])
                .where((r) => r['wrapperType'] == 'collection')
                .toList();
            print('  Discografía: ${albums.length} álbumes encontrados');
            allResults.addAll(albums);
          }
        }
      }

      print('Total antes de filtrar: ${allResults.length}');

      
      final List<dynamic> filteredAlbums = [];
      final Set<String> seenIds = {};

      for (var album in allResults) {
        final String collectionType = album['collectionType'] ?? '';
        final String albumName = (album['collectionName'] ?? '').toLowerCase();
        final String artistName = (album['artistName'] ?? '').toLowerCase();
        final int trackCount = album['trackCount'] ?? 0;
        final String albumId = album['collectionId']?.toString() ?? '';

        
        bool isRealAlbum = collectionType == 'Album' || collectionType == 'Compilation';

       
        bool notASingle = trackCount != 1;

       
        bool isNotCrap = !albumName.contains('tribute') &&
            !albumName.contains('karaoke') &&
            !albumName.contains('lullaby') &&
            !albumName.contains('renditions') &&
            !albumName.contains('cover') &&
            !albumName.contains('- ep') &&
            !albumName.contains('- single') &&
            !artistName.contains('tribute') &&
            !artistName.contains('vsq');

        
        bool notDuplicate = albumId.isNotEmpty && !seenIds.contains(albumId);

        if (isRealAlbum && notASingle && isNotCrap && notDuplicate) {
          seenIds.add(albumId);
          filteredAlbums.add(album);
        }
      }

      print('Total después de filtrar: ${filteredAlbums.length}');

      setState(() {
        if (filteredAlbums.isNotEmpty) {
          _albumList = filteredAlbums;
          _resultado = "Se encontraron ${filteredAlbums.length} álbumes.\nSelecciona el tuyo:";
        } else {
          _resultado = "No se encontraron álbumes. Intenta con el nombre del artista.";
        }
      });

    } catch (e) {
      setState(() => _resultado = "Fallo de conexión:\n$e");
    } finally {
      setState(() => _isLoading = false);
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
      appBar: AppBar(title: const Text('Buscador Musical')),
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
              onSubmitted: (_) => _fetchDataFromiTunes(),
            ),
            const SizedBox(height: 16),

            if (_isLoading)
              const CircularProgressIndicator(color: Colors.deepPurple)
            else ...[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                onPressed: _fetchDataFromiTunes,
                child: const Text('Buscar en la red', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
              const SizedBox(height: 16),
              Text(_resultado,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurpleAccent),
              ),
            ],

            const SizedBox(height: 10),

            if (_albumList.isNotEmpty && _selectedAlbum == null)
              Expanded(
                child: ListView.builder(
                  itemCount: _albumList.length,
                  itemBuilder: (context, index) {
                    final album = _albumList[index];
                    return Card(
                      color: Colors.grey[900],
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: album['artworkUrl100'] != null
                            ? Image.network(album['artworkUrl100'])
                            : const Icon(Icons.album, color: Colors.grey, size: 50),
                        title: Text(album['collectionName'] ?? 'Desconocido',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Text(album['artistName'] ?? 'Artista desconocido',
                          style: const TextStyle(color: Colors.grey)),
                        trailing: const Icon(Icons.touch_app, color: Colors.deepPurpleAccent),
                        onTap: () => _seleccionarAlbum(album),
                      ),
                    );
                  },
                ),
              ),

            if (_selectedAlbum != null)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_selectedAlbum!['artworkUrl100'] != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          _selectedAlbum!['artworkUrl100'].replaceAll('100x100', '300x300'),
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    const SizedBox(height: 20),
                    Text(
                      _selectedAlbum!['collectionName'] ?? 'Desconocido',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedAlbum!['artistName'] ?? 'Artista desconocido',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      icon: const Icon(Icons.share, color: Colors.white),
                      label: const Text('Compartir Hallazgo', style: TextStyle(color: Colors.white)),
                      onPressed: () {
                        Share.share(
                          '¡Mira este álbum que encontré en AlbumLog! \n${_selectedAlbum!['collectionName']} de ${_selectedAlbum!['artistName']}',
                        );
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