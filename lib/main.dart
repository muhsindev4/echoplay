import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import 'app/controllers/download_controller.dart';
import 'app/pages/downloads/downloads_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.yt.play',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );



  ReceiveSharingIntent.instance.getMediaStream().listen((value) {
    if (value.isNotEmpty) {
      String? argument = value.first.path;
      print("ReceiveSharingIntent : $argument");
      Get.put(DownloadController(), permanent: true).downloadUrl(argument);
    }
  }, onError: (err) {
    print("getIntentDataStream error: $err");
  });

  // Get the media sharing intent when the app is closed and then opened
  ReceiveSharingIntent.instance.getInitialMedia().then((value) {
    if (value.isNotEmpty) {
      String? argument = value.first.path;
      print("ReceiveSharingIntent2 : $argument");
      Get.put(DownloadController(), permanent: true).downloadUrl(argument);
      ReceiveSharingIntent.instance.reset();
    }
  });

  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  String? argument;
  MyApp({this.argument});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sharing Intent Example',
      initialRoute: "/downloads",
      getPages: [
        GetPage(name: "/downloads", page: () => DownloadsScreen()),
      ],
    );
  }
}
