const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.onNewCommentNotification = functions.firestore
    .document('users/{reviewOwnerId}/reviews/{reviewId}/comments/{commentId}')
    .onCreate(async (snapshot, context) => {
        const commentData = snapshot.data();
        const reviewOwnerId = context.params.reviewOwnerId;

        if (commentData.senderId === reviewOwnerId) return null;

        const userDoc = await admin.firestore().collection('users').doc(reviewOwnerId).get();
        if (!userDoc.exists) return null;

        const userData = userDoc.data();
        const destToken = userData.fcmToken;

        if (!destToken) {
            console.log('El dueño de la reseña no tiene un dispositivo registrado.');
            return null;
        }

        const message = {
            notification: {
                title: '¡Nuevo comentario en tu reseña!',
                body: `${commentData.senderName || 'Alguien'} comentó: "${commentData.text}"`,
            },
            data: {
                click_action: 'FLUTTER_NOTIFICATION_CLICK',
                reviewId: context.params.reviewId,
                ownerId: reviewOwnerId,
            },
            token: destToken
        };

        try {
            const response = await admin.messaging().send(message);
            console.log('Notificación enviada con éxito:', response);
            return response;
        } catch (error) {
            console.error('Error al enviar la notificación:', error);
            return null;
        }
    });