import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Solicita permisos y guarda el token del dispositivo en la base de datos
  Future<void> initializeNotificationSystem(String uid) async {
    try {
      // 1. Solicitar permisos al sistema operativo
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // 2. Obtener el token único de este dispositivo
        String? token = await _fcm.getToken();

        if (token != null) {
          // 3. Guardar o actualizar el token en el documento público del usuario
          await _db.collection('users').doc(uid).set({
            'fcmToken': token,
          }, SetOptions(merge: true));
        }
      }
    } catch (e) {
      debugPrint("Error inicializando notificaciones: $e");
    }
  }
}   