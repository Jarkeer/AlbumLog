import 'package:flutter/material.dart';

class DetailView extends StatelessWidget {
  final int albumId;
  
  const DetailView({super.key, required this.albumId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del Disco')),
      body: Center(
        child: Text('Mostrando detalles del disco número $albumId'),
      ),
    );
  }
}