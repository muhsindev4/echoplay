import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play/app/controllers/download_controller.dart';
import 'package:play/app/controllers/playback_controller.dart';
import 'package:play/app/data/models/file_data.dart';
import 'package:progress_indicators/progress_indicators.dart';

class DownloadPage extends StatelessWidget {
  final DownloadController _downloadController = Get.put(DownloadController());
  final PlaybackController _playbackController = Get.put(PlaybackController());

  DownloadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GetBuilder<PlaybackController>(builder: (logic){
            if (_playbackController.getCurrentFileData() != null){
              return  CachedNetworkImage(
                imageUrl: _playbackController.getCurrentFileData()!.thumbnails,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              );
            }

            return SizedBox();
          }),
          /// Background Thumbnail + Blur (same as HomeScreen)

          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: Container(color: Colors.black.withOpacity(0.7)),
          ),

          /// Download List
          SafeArea(
            child: GetBuilder<DownloadController>(
                    builder: (logic) {
              if (_downloadController.files.isEmpty) {
                return Center(
                  child: Text(
                    "No downloads yet",
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              return ListView.builder(
                itemCount: _downloadController.files.length,
                padding: EdgeInsets.symmetric(horizontal: 10),
                itemBuilder: (context, index) {
                  final file = _downloadController.files[index];
                  return _buildDownloadTile(file);
                },
              );
            }),
          ),
        ],
      ),
      backgroundColor: Colors.black,
    );
  }

  Widget _buildDownloadTile(FileData file) {
    return GetBuilder<PlaybackController>(builder: (logic){
      bool isPlaying=false;
      if(file.path!=null){
        isPlaying =_playbackController.isPlaying(file.path!);
      }

      return Dismissible(
        key: Key(file.path ?? file.name),
        direction: DismissDirection.horizontal,
        background: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.redAccent,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: 20),
          child: Icon(Icons.delete, color: Colors.white),
        ),
        secondaryBackground: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.redAccent,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: 20),
          child: Icon(Icons.delete, color: Colors.white),
        ),
        onDismissed: (direction) {
          _downloadController.deleteFile(file.id); // Add this method in your controller
          Get.snackbar('Deleted', '${file.name} has been removed.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.black87,
              colorText: Colors.white);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: file.isDownload
                ? Colors.white.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            leading: CircleAvatar(
              backgroundImage: NetworkImage(file.thumbnails ?? 'https://placekitten.com/200/200'),
              radius: 30,
            ),
            title: Text(
              file.name,
              maxLines: 1,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            subtitle: Text(
              file.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[300]),
            ),
            trailing: file.isDownload
                ? IconButton(
              icon: Icon(isPlaying?Icons.pause:Icons.play_arrow, color: Colors.white),
              onPressed: () {
                if(isPlaying){
                  _playbackController.pause();
                  return;
                }
                _playbackController.playAll([file,..._downloadController.files]);
              },
            )
                : _buildDownloadProgress(file),
          ),
        ),
      );
    });

  }

  Widget _buildDownloadProgress(FileData file) {
    return Container(
    width: 60,
    child: Column(
      children: [
        JumpingDotsProgressIndicator(
          fontSize: 20.0,
          color: Colors.blueAccent,
        ),
        SizedBox(height: 8),
        Text(
          '${(file.downloadProgress! * 100).toStringAsFixed(0)}%',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ],
    ),
  );
    }
}
