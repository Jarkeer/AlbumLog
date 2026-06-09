import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; 
void main() => runApp(const PoCApp());

class PoCApp extends StatelessWidget {
  const PoCApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PoCScreen(),
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

  // Función asíncrona que simula la Capa de Datos 
  Future<void> _fetchDataFromiTunes() async {
    setState(() {
      _isLoading = true;
      _resultado = "Conectando a la API de iTunes...";
    });

    try {
      // Endpoint de la API pública de iTunes
      final url = Uri.parse('https://itunes.apple.com/search?term=daft+punk&entity=album&limit=1');
      
      // Realizamos la petición HTTP GET
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Decodificamos el JSON
        final Map<String, dynamic> data = json.decode(response.body);
        
        // Extraemos un dato específico para probar que funcionó
        final albumName = data['results'][0]['collectionName'];
        final artistName = data['results'][0]['artistName'];

        setState(() {
          _resultado = "¡Éxito!\n\nÁlbum encontrado: $albumName\nArtista: $artistName\n\nJSON Crudo:\n${response.body.substring(0, 150)}...";
        });
      } else {
        setState(() {
          _resultado = "Error de servidor: Código ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _resultado = "Fallo de conexión o error crítico:\n$e";
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
              Text(
                _resultado,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              if (_isLoading) 
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _fetchDataFromiTunes,
                  child: const Text('Ejecutar Transacción HTTP'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}