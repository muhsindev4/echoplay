import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';

import '../data/models/file_data.dart';


class DownloadController extends GetxController {
   Box<FileData>? _fileBox;
  final YoutubeExplode _yt = YoutubeExplode();

   List<FileData> get files {
     if (_fileBox == null) return [];
     final fileList = _fileBox!.values.toList();
     fileList.sort((a, b) => a.createdAt.compareTo(b.createdAt));
     return fileList;
   }

  @override
  void onReady() async {
    super.onReady();
    _fileBox = Hive.box<FileData>('downloads');
  }

   @override
   void onInit() async {
     super.onInit();
     _fileBox = Hive.box<FileData>('downloads');
   }


   Future<void> startDownload(String url) async {
    try {
      final videoId = VideoId(url);
      final video = await _yt.videos.get(videoId);
      final manifest = await _yt.videos.streamsClient.getManifest(videoId);
      final audioStreamInfo = manifest.audioOnly.withHighestBitrate();

      if (audioStreamInfo == null) {
        Get.snackbar('Download Error', 'No suitable audio stream found.');
        return;
      }

      final fileName = sanitizeFileName('${videoId.value}_${video.title}.mp3');
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/$fileName';

      _addFile(video);

      final file = File(filePath);
      final stream = _yt.videos.streamsClient.get(audioStreamInfo);
      final fileStream = file.openWrite();

      var totalBytes = audioStreamInfo.size.totalBytes;
      int downloadedBytes = 0;

      await for (final data in stream) {
        downloadedBytes += data.length;
        fileStream.add(data);

        final progress = downloadedBytes / totalBytes;
        _updateFileData(videoId.value, downloadProgress: progress);
      }

      await fileStream.flush();
      await fileStream.close();

      _updateFileData(videoId.value, isDownload: true, path: filePath);
    } catch (e) {
      debugPrint("Download error: $e");
      Get.snackbar('Download Error', e.toString());
    }
  }

  String sanitizeFileName(String name) {
    return name.replaceAll(RegExp(r'[\\/*?:"<>|]'), '_');  // Replace invalid characters
  }

  void _addFile(Video video) {
    final file = FileData(
      id: video.id.value,
      name: video.title,
      description: video.description,
      thumbnails: video.thumbnails.mediumResUrl,
      duration: video.duration?.inSeconds ,
      publishDate: video.publishDate, createdAt:  DateTime.now(),
    );
    _fileBox!.put(file.id, file);
    update();
  }

  void _updateFileData(
      String id, {
        bool? isDownload,
        String? path,
        double? downloadProgress,
      }) {
    final file = _fileBox!.get(id);
    if (file != null) {
      final updated = file.copyWith(
        isDownload: isDownload ?? file.isDownload,
        path: path ?? file.path,
        downloadProgress: downloadProgress ?? file.downloadProgress,
      );
      _fileBox!.put(id, updated);
      update();
    }
  }

  Future<void> deleteFile(String id) async {
    final file = _fileBox!.get(id);
    if (file?.path != null && file!.path!.isNotEmpty) {
      final localFile = File(file.path!);
      if (await localFile.exists()) {
        await localFile.delete();
      }
    }
    await _fileBox!.delete(id);
    update();
  }
}
