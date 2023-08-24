import 'package:app/app.dart';
import 'package:app/controllers/service_controller.dart';
// import 'package:app/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    // Uncomment after $ flutterfire configure
    // options: DefaultFirebaseOptions.currentPlatform
  );

  const String url = String.fromEnvironment('EMULATOR_HOST', defaultValue: '');
  if (url != "") {
    print("Using emulator on $url");
    // Initializing services
    await FirebaseAuth.instance.useAuthEmulator(url, 9099);
    await FirebaseStorage.instance.useStorageEmulator(url, 9199);
    FirebaseFirestore.instance.useFirestoreEmulator(url, 8080);
  }
  
  // Initializing local storage
  final storage = await SharedPreferences.getInstance();

  // Initializing path
  final directory = !kIsWeb ? await getApplicationDocumentsDirectory() : null;

  // Initializing background audio service
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );

  // Initializing services global class
  final controller = ServiceController(storage, directory);
  
  // Initializing
  await controller.init();

  runApp(ServiceContext(
    controller: controller, 
    child: const App()
  ));
}
