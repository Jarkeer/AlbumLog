import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class LastFmService {
  final String _apiKey = '3892c0bae522895e4cef36d817718d35';
  final String _baseUrl = 'http://ws.audioscrobbler.com/2.0/';


  Future<List<dynamic>> searchAlbums(String query) async {
    final String encodedQuery = Uri.encodeComponent(query);
    final url = Uri.parse(
        '$_baseUrl?method=album.search&album=$encodedQuery&api_key=$_apiKey&format=json&limit=15');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> albums =
            data['results']?['albummatches']?['album'] ?? [];

        // Filtramos y retornamos los álbumes válidos
        return albums
            .where((a) => a['name'] != '(null)' && a['name'] != '')
            .toList();
      } else {
        throw Exception("Servidor no disponible.");
      }
    } on TimeoutException {
      throw Exception("Tiempo de espera agotado.");
    } catch (e) {
      throw Exception("Fallo de conexión.");
    }
  }

  String getImageUrl(List<dynamic>? images, String size) {
    if (images == null || images.isEmpty) return '';
    try {
      final imageObj = images.firstWhere(
          (img) => img['size'] == size,
          orElse: () => images.last);
      return imageObj['#text'] ?? '';
    } catch (e) {
      return '';
    }
  }
}