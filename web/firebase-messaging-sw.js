importScripts('https://www.gstatic.com/firebasejs/9.0.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.0.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyA4P4gnSQVIFhUIg464LMH_T68LhpsffbY",
  authDomain: "fitness-tracker-des.firebaseapp.com",
  projectId: "fitness-tracker-des",
  storageBucket: "fitness-tracker-des.firebasestorage.app",
  messagingSenderId: "596014931235",
  appId: "1:596014931235:web:fa55d081ab6416db324096"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/favicon.png'
  };

  return self.registration.showNotification(notificationTitle,
    notificationOptions);
});
