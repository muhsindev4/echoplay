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

  bool _isDownloading = false;

  @override
  void onReady() async {
    super.onReady();
    getData();
  }

  @override
  void onInit() async {
    super.onInit();
    getData();
  }

  Future<void> getData() async {
    _fileBox = Hive.box<FileData>('downloads');

    // Check if the box is initialized
    if (_fileBox == null) return;

    // Check if any files are not downloaded and we're not currently downloading
    if (!_isDownloading && _fileBox!.values.any((data) => !data.isDownload)) {

      for(FileData data in _fileBox!.values){
        if(!data.isDownload){
          await _downloadAudio(VideoId(data.id));
        }
      }


    }
  }

  Future<void> startDownload(String url) async {
    try {
      final playlistRegex = RegExp(r'list=([a-zA-Z0-9_-]+)');
      final match = playlistRegex.firstMatch(url);

      if (match != null) {
        // Handle playlist
        final playlistId = PlaylistId(url);
        final playlist = await _yt.playlists.get(playlistId);
        final videos = await _yt.playlists.getVideos(playlist.id).toList();
        for (final video in videos) {
          _addFile(video);
        }
        for (final video in videos) {
          await _downloadAudio(video.id);
        }

        Get.snackbar(
          'Download Complete',
          'All videos in the playlist downloaded.',
        );
      } else {
        // Handle single video
        final videoId = VideoId(url);
        await _downloadAudio(videoId);

        Get.snackbar('Download Complete', 'Video downloaded successfully.');
      }
    } catch (e) {
      Get.snackbar('Download Error', e.toString());
    }
  }

  Future<void> _downloadAudio(VideoId videoId) async {
    try {
      _isDownloading = true;
      final video = await _yt.videos.get(videoId);
      final manifest = await _yt.videos.streamsClient.getManifest(videoId);
      final audioStreamInfo = manifest.audioOnly.withHighestBitrate();

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
      _isDownloading = false;
    } catch (e) {
      debugPrint("Download error: $e");
      Get.snackbar('Download Error', e.toString());
    }
  }

  String sanitizeFileName(String name) {
    return name.replaceAll(
      RegExp(r'[\\/*?:"<>|]'),
      '_',
    ); // Replace invalid characters
  }

  void _addFile(Video video) {
    final file = FileData(
      id: video.id.value,
      name: video.title,
      description: video.description,
      thumbnails: video.thumbnails.mediumResUrl,
      duration: video.duration?.inSeconds,
      publishDate: video.publishDate,
      createdAt: DateTime.now(),
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
