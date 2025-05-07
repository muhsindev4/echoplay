import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:path_provider/path_provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import 'app/controllers/download_controller.dart';
import 'app/data/models/file_data.dart';
import 'app/pages/downloads/downloads_screen.dart';
import 'app/pages/home/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize JustAudioBackground
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.yt.play',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );

  // Receive media sharing intent
  ReceiveSharingIntent.instance.getMediaStream().listen((value) {
    if (value.isNotEmpty) {
      String? argument = value.first.path;
      Get.put(DownloadController(), permanent: true).startDownload(argument);
    }
  }, onError: (err) {
    print("getIntentDataStream error: $err");
  });

  // Handle media intent when the app is opened
  ReceiveSharingIntent.instance.getInitialMedia().then((value) {
    if (value.isNotEmpty) {
      String? argument = value.first.path;
      Get.put(DownloadController(), permanent: true).startDownload(argument);
      ReceiveSharingIntent.instance.reset();
    }
  });

  // Initialize Hive
  WidgetsFlutterBinding.ensureInitialized();
  final appDocDir = await getApplicationDocumentsDirectory(); // Get directory for app data storage
  Hive.init(appDocDir.path); // Provide the path where Hive will store its boxes

  // Register adapter and open box
  Hive.registerAdapter(FileDataAdapter());
  await Hive.openBox<FileData>('downloads');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  final String? argument;
  const MyApp({super.key, this.argument});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute:"/downloads",
      getPages: [

        GetPage(name: "/downloads", page: () => DownloadPage()),
      ],
    );
  }
}
