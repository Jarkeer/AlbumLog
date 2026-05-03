import 'package:flutter/material.dart';
import 'package:album_log/main.dart'; // Importamos para acceder a MainNavigationWrapper

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  // Función asíncrona para la transición
  _navigateToHome() async {
    // Esperamos 3 segundos
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;
    
    // Navegamos reemplazando la pantalla actual para no poder volver atrás al Splash
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainNavigationWrapper()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Usamos el color primario configurado en el ThemeData global
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png', 
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 24),
            const Text(
              'AlbumLog',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 10),
            const CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}