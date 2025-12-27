// Firebase Messaging Service Worker
// Replace the firebaseConfig below with your app's config if you want to enable background messages on web.
// You can generate this file using the Firebase Console or the FlutterFire CLI.

/* eslint-disable */
importScripts('https://www.gstatic.com/firebasejs/9.22.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.22.0/firebase-messaging-compat.js');

// TODO: Replace with your Firebase app config
const firebaseConfig = {
  // apiKey: "...",
  // authDomain: "...",
  // projectId: "...",
  // storageBucket: "...",
  // messagingSenderId: "...",
  // appId: "...",
};

try {
  firebase.initializeApp(firebaseConfig);
  const messaging = firebase.messaging();

  messaging.onBackgroundMessage(function(payload) {
    console.log('[firebase-messaging-sw.js] Received background message ', payload);
    const notificationTitle = payload.notification?.title || 'Reservi';
    const notificationOptions = {
      body: payload.notification?.body || '',
      icon: '/icons/icon-192.png',
    };
    self.registration.showNotification(notificationTitle, notificationOptions);
  });
} catch (e) {
  console.log('FCM service worker init failed (expected if no config provided):', e);
}
