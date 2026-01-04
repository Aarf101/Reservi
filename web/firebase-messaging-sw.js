// Firebase Messaging Service Worker
// Replace the firebaseConfig below with your app's config if you want to enable background messages on web.
// You can generate this file using the Firebase Console or the FlutterFire CLI.

/* eslint-disable */
importScripts('https://www.gstatic.com/firebasejs/9.22.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.22.0/firebase-messaging-compat.js');

// Firebase web config copied from lib/firebase_options.dart (web)
const firebaseConfig = {
  apiKey: 'AIzaSyCoP3ayV2ThVfAd4FJc57OcgbV3uXVmwFQ',
  authDomain: 'reservi-e6b17.firebaseapp.com',
  projectId: 'reservi-e6b17',
  storageBucket: 'reservi-e6b17.firebasestorage.app',
  messagingSenderId: '610510773006',
  appId: '1:610510773006:web:92344c5e8ad7e25cd1555f',
  measurementId: 'G-ZNE04RGGS9'
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
