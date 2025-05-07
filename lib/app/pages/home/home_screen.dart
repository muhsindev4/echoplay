import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/download_controller.dart';
import '../../controllers/playback_controller.dart';
import '../../data/models/file_data.dart';

class HomeScreen extends StatelessWidget {
  final _downloadController = Get.put(DownloadController());
  final _playController = Get.put(PlaybackController());

  HomeScreen({super.key});

  List<FileData> get songs => _downloadController.files;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// Background Thumbnail + Blur
          if (_playController.getCurrentFileData() != null)
            CachedNetworkImage(
              imageUrl: _playController.getCurrentFileData()!.thumbnails!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: Container(color: Colors.black.withOpacity(0.7)),
          ),

          /// Song List
          SafeArea(
            child: ListView.builder(
              itemCount: songs.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final song = songs[index];

                final isPlaying = _playController.isPlaying(song.path!);

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color:
                        isPlaying
                            ? Colors.white.withOpacity(0.1)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: song.thumbnails!,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      song.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight:
                            isPlaying ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      song.description ?? "",
                      style: TextStyle(color: Colors.grey[300]),
                    ),
                    trailing:
                        isPlaying
                            ? Icon(Icons.equalizer, color: Colors.white)
                            : Icon(Icons.play_arrow, color: Colors.white),
                    onTap: () {
                      // Handle play song
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      backgroundColor: Colors.black,
    );
  }
}
