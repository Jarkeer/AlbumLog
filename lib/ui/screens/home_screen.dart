import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('AlbumLog'),
              background: Icon(Icons.album_rounded, size: 100, color: Colors.deepPurple),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bienvenido a tu bitácora musical',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'AlbumLog es el espacio donde tus discos favoritos cobran vida. '
                    'Aquí no solo escuchas música, la vives, la reseñas y la compartes.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 30),
                  _buildFeatureCard(
                    context,
                    Icons.star_rate,
                    'Reseñas Personalizadas',
                    'Valora cada álbum de 1 a 5 estrellas y deja tu opinión.',
                  ),
                  _buildFeatureCard(
                    context,
                    Icons.people,
                    'Comunidad',
                    'Sigue a tus amigos y descubre qué están escuchando.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, IconData icon, String title, String desc) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(desc),
      ),
    );
  }
}