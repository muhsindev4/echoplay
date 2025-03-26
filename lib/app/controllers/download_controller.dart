import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../components/snack_bar/snack.dart';
import '../data/models/file_data.dart';

class DownloadController extends GetxController {
  final YoutubeExplode _yt = YoutubeExplode();
  final List<FileData> _files = [];
  List<FileData> get files => _files;

  @override
  void onInit() {
    super.onInit();
    loadStoredFiles();
  }

  void downloadUrl(String url) {
    if (isPlaylist(url)) {
      getPlayListVideoIds(url);
    } else {
      getVideoIdFromUrl(url);
    }
  }

  bool isPlaylist(String url) => url.contains("playlist?list=");

  Future<void> getPlayListVideoIds(String url) async {
    try {
      String playlistId = extractPlaylistId(url);
      await for (var video in _yt.playlists.getVideos(playlistId)) {
        _files.add(FileData(id: video.id.value, name: video.title));
        update();
        download(video.id.value);
      }
      saveFileData();
    } catch (e) {
      Snack.showErrorMessage(e.toString());
    }
  }

  void updateFileData(String id, {bool? isDownload, String? path, double? downloadProgress}) {
    for (int i = 0; i < _files.length; i++) {
      if (_files[i].id == id) {
        _files[i] = _files[i].copyWith(isDownload: isDownload, path: path, downloadProgress: downloadProgress);
      }
    }
    update();
    saveFileData();
  }

  Future<void> loadStoredFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/downloads.json');

      if (await file.exists()) {
        String contents = await file.readAsString();
        List<dynamic> jsonData = jsonDecode(contents);

        _files.clear();
        _files.addAll(jsonData.map((e) => FileData.fromJson(e)));
        update();
      }
    } catch (e) {
      print("Error loading stored files: $e");
    }
  }

  Future<void> saveFileData() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/downloads.json');

      String jsonData = jsonEncode(_files.map((e) => e.toJson()).toList());
      await file.writeAsString(jsonData);
    } catch (e) {
      print("Error saving file data: $e");
    }
  }

  String extractPlaylistId(String url) {
    var parts = url.split("list=");
    if (parts.length > 1) {
      return parts[1].split('&')[0];
    }
    throw 'Invalid playlist URL';
  }

  Future<void> getVideoIdFromUrl(String url) async {
    try {
      final RegExp videoIdPattern = RegExp(r'(?:v=|\/)([0-9A-Za-z_-]{11}).*');
      final match = videoIdPattern.firstMatch(url);

      if (match != null && match.groupCount >= 1) {
        final videoId = match.group(1);
        if (videoId != null) {
          final video = await _yt.videos.get(videoId);
          _files.add(FileData(id: video.id.value, name: video.title));
          update();
          await download(videoId);
          saveFileData();
        } else {
          throw 'Invalid video URL';
        }
      } else {
        throw 'Invalid video URL';
      }
    } catch (e) {
      print('Error extracting video ID: $e');
    }
  }

  Future<void> download(String videoId) async {
    try {
      var video = await _yt.videos.get(videoId);
      var manifest = await _yt.videos.streams.getManifest(video.id);
      var audioStreamInfo = manifest.audioOnly.withHighestBitrate();

      if (audioStreamInfo == null) {
        throw "No audio stream available for this video.";
      }

      var audioStream = _yt.videos.streamsClient.get(audioStreamInfo);
      var tempDir = await getApplicationDocumentsDirectory();
      var audioFilePath = '${tempDir.path}/${video.id}.webm';
      var audioFile = File(audioFilePath);
      var audioFileStream = audioFile.openWrite();

      int totalBytes = audioStreamInfo.size.totalBytes;
      int downloadedBytes = 0;

      await for (var chunk in audioStream) {
        audioFileStream.add(chunk);
        downloadedBytes += chunk.length;

        double progress = downloadedBytes / totalBytes;
        updateFileData(videoId, downloadProgress: progress);
        update();
      }

      await audioFileStream.flush();
      await audioFileStream.close();

      updateFileData(videoId, isDownload: true, path: audioFile.path, downloadProgress: 1.0);
      update();
    } catch (e) {
      print('Error downloading and saving video: $e');
    }
  }

  /// **New Method: Delete a Downloaded File**
  Future<void> deleteFile(String id) async {
    try {
      // Find the file in the list
      final fileIndex = _files.indexWhere((file) => file.id == id);
      if (fileIndex == -1) return;

      final filePath = _files[fileIndex].path;
      if (filePath != null && filePath.isNotEmpty) {
        final file = File(filePath);
        if (await file.exists()) {
          await file.delete(); // Delete the actual file
        }
      }

      // Remove file from list
      _files.removeAt(fileIndex);
      update();
      saveFileData();

      print("File deleted successfully.");
    } catch (e) {
      print("Error deleting file: $e");
    }
  }

  @override
  void onClose() {
    _yt.close();
    super.onClose();
  }
}
