# sentryhome

Connect Firebase

1. Create new project at console.firebase.google.com
2. Under Build,select Firestore Database and create database
3. under Rules, change line 6 to allow read, write: if true;
4. Follow the instructions at https://firebase.google.com/docfluttes/flutter/setup?platform=ios
   4.1. ` npm install -g firebase-tools`
5. flutter pub add cloud_firestore
6. flutter run
7. flutter pub add firebase_auth
