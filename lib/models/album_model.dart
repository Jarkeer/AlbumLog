class AlbumModel {

  final String id;
  final String title;
  final String artist;
  final String imagePath; 
  final String description;

  AlbumModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.imagePath,
    required this.description,
  });
}

final List<AlbumModel> albums = [
  AlbumModel(
    id: '1',
    title: 'Synkronized',
    artist: 'Jamiroquai',
    imagePath: 'assets/images/synkronized.png',
    description: 'El cuarto álbum de estudio de la banda británica de funk ácido Jamiroquai.',
    ),
    AlbumModel(
    id: '2',
    title: 'Discovery',
    artist: 'Daft Punk',
    imagePath: 'assets/images/daft-punk-discovery.jpg',
    description: 'Un viaje conceptual por el house y el synth-pop que marcó una era.',
  ),
  AlbumModel(
    id: '3',
    title: 'Performance and Cocktails',
    artist: 'Stereophonics',
    imagePath: 'assets/images/performance_and_cocktails.jpg',
    description: 'Una experiencia auditiva que combina rock y pop con toques de funk.',
  ),
];