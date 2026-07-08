import 'package:cloud_firestore/cloud_firestore.dart';

class FriendshipService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Enviar una solicitud de amistad
  Future<void> sendFriendRequest({
    required String senderId,
    required String receiverId,
  }) async {
    // El ID del documento será siempre 'ID_EMISOR_ID_RECEPTOR'
    await _db.collection('friend_requests').doc('${senderId}_$receiverId').set({
      'senderId': senderId,
      'receiverId': receiverId,
      'status': 'pending', // estados: pending, accepted
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Aceptar una solicitud de amistad (Usa un Batch para asegurar que todo se guarde o nada)
  Future<void> acceptFriendRequest({
    required String senderId,
    required String receiverId,
  }) async {
    WriteBatch batch = _db.batch();

    // 1. Actualizar el estado de la solicitud a 'accepted'
    DocumentReference requestRef = _db.collection('friend_requests').doc('${senderId}_$receiverId');
    batch.update(requestRef, {'status': 'accepted'});

    // 2. Agregar a la subcolección interna de amigos de cada usuario (opcional, para listas rápidas)
    DocumentReference senderFriendRef = _db.collection('users').doc(senderId).collection('friends').doc(receiverId);
    DocumentReference receiverFriendRef = _db.collection('users').doc(receiverId).collection('friends').doc(senderId);

    batch.set(senderFriendRef, {'uid': receiverId, 'timestamp': FieldValue.serverTimestamp()});
    batch.set(receiverFriendRef, {'uid': senderId, 'timestamp': FieldValue.serverTimestamp()});

    await batch.commit();
  }

  // Cancelar, rechazar o eliminar amigo
  Future<void> deleteFriendship({
    required String senderId,
    required String receiverId,
  }) async {
    WriteBatch batch = _db.batch();

    // Borramos cualquier intento de documento en ambas combinaciones posibles
    DocumentReference req1 = _db.collection('friend_requests').doc('${senderId}_$receiverId');
    DocumentReference req2 = _db.collection('friend_requests').doc('${receiverId}_$senderId');
    
    batch.delete(req1);
    batch.delete(req2);

    // Borramos de las subcolecciones de amigos por si ya eran amigos
    DocumentReference f1 = _db.collection('users').doc(senderId).collection('friends').doc(receiverId);
    DocumentReference f2 = _db.collection('users').doc(receiverId).collection('friends').doc(senderId);
    
    batch.delete(f1);
    batch.delete(f2);

    await batch.commit();
  }

  // Stream para escuchar en tiempo real el estado entre el usuario actual y el perfil visitado
  Stream<DocumentSnapshot?> getRelationshipStream(String currentUid, String targetUid) {
    // Como no sabemos quién la envió primero, escuchamos la combinación A_B
    return _db.collection('friend_requests').doc('${currentUid}_$targetUid').snapshots().asyncMap((doc1) {
      if (doc1.exists) return doc1;
      // Si no existe, revisamos la combinación B_A
      return _db.collection('friend_requests').doc('${targetUid}_$currentUid').get();
    });
  }
}