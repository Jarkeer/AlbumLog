import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewsmodel/auth_viewmodel.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: Center(
        child: authVM.isLoading
            ? const CircularProgressIndicator(color: Colors.deepPurple)
            : authVM.user == null
                ? _buildLoginView(authVM)
                : _buildProfileView(authVM),
      ),
    );
  }

  Widget _buildLoginView(AuthViewModel authVM) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off, size: 100, color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            'Inicia sesión para sincronizar tu biblioteca de AlbumLog en la nube',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            icon: Image.network(
              'https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg',
              height: 24,
            ),
            label: const Text('Continuar con Google', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            onPressed: () => authVM.signInWithGoogle(),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileView(AuthViewModel authVM) {
    final user = authVM.user!;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 60,
          backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
          backgroundColor: Colors.deepPurple,
          child: user.photoURL == null ? const Icon(Icons.person, size: 60, color: Colors.white) : null,
        ),
        const SizedBox(height: 20),
        
        
        Text(
          user.displayName ?? 'Usuario de AlbumLog', 
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)
        ),
        const SizedBox(height: 8),
        
        
        Text(
          user.email ?? 'Sin correo', 
          style: const TextStyle(fontSize: 16, color: Colors.grey)
        ),
        const SizedBox(height: 40),
        
       
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          ),
          icon: const Icon(Icons.logout, color: Colors.white),
          label: const Text('Cerrar Sesión', style: TextStyle(color: Colors.white, fontSize: 16)),
          onPressed: () => authVM.signOut(),
        ),
      ],
    );
  }
}