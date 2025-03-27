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
  bool get isDownloading =>_isDownloading;
  bool  _isDownloading =false;
  @override
  void onInit() {
    super.onInit();
    loadStoredFiles();
  }



  /// Initializes the download process based on URL type (Playlist/Single Video)
  void initUrl(String url) {
    isPlaylist(url) ? _fetchPlaylistVideos(url) : _fetchVideoDetails(url);
  }

  bool isPlaylist(String url) => url.contains("playlist?list=");

  bool _isFileExists(String id) => _files.any((file) => file.id == id);

  /// Fetches and downloads videos from a playlist
  Future<void> _fetchPlaylistVideos(String url) async {
    try {
      String playlistId = _extractPlaylistId(url);
      await for (var video in _yt.playlists.getVideos(playlistId)) {
        if (!_isFileExists(video.id.value)) {
          _addFile(video);
        }
      }
      await _saveFileData();
      await  downloadAll();
      _isDownloading=false;
    } catch (e) {
      Snack.showErrorMessage(e.toString());
    }
  }

 Future downloadAll() async {
   if (isDownloading) return; // Prevent multiple calls
    for (var file in _files) {
      if(!file.isDownload){
       await downloadFile(file.id);
      }
    }
  }

  /// Updates file details
  void _updateFileData(String id, {bool? isDownload, String? path, double? downloadProgress}) {
    for (var i = 0; i < _files.length; i++) {
      if (_files[i].id == id) {
        _files[i] = _files[i].copyWith(
          isDownload: isDownload ?? _files[i].isDownload,
          path: path ?? _files[i].path,
          downloadProgress: downloadProgress ?? _files[i].downloadProgress,
        );
      }
    }
    update();
    _saveFileData();
  }

  Future<void> loadStoredFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/downloads.json');
      if (await file.exists()) {
        String contents = await file.readAsString();
        _files.clear();
        _files.addAll(List<FileData>.from(jsonDecode(contents).map((e) => FileData.fromJson(e))));
        update();
      }
    } catch (e) {
      print("Error loading stored files: $e");
    }
  }

  Future<void> _saveFileData() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/downloads.json');
      await file.writeAsString(jsonEncode(_files.map((e) => e.toJson()).toList()));
    } catch (e) {
      print("Error saving file data: $e");
    }
  }

  String _extractPlaylistId(String url) {
    var parts = url.split("list=");
    if (parts.length > 1) return parts[1].split('&')[0];
    throw 'Invalid playlist URL';
  }

  Future<void> _fetchVideoDetails(String url) async {
    try {
      final RegExp videoIdPattern = RegExp(r'(?:v=|\/)([0-9A-Za-z_-]{11}).*');
      final match = videoIdPattern.firstMatch(url);
      if (match != null && match.groupCount >= 1) {
        final videoId = match.group(1);
        if (videoId != null) {
          var video = await _yt.videos.get(videoId);
          _addFile(video);
          await downloadFile(videoId);
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

  void _addFile(Video video) {
    final file = FileData(
      id: video.id.value,
      name: video.title,
      description: video.description,
      thumbnails: video.thumbnails.mediumResUrl,
      duration: video.duration,
      publishDate: video.publishDate,
    );
    _files.add(file);
    _saveFileData();
    update();
  }

  Future<void> downloadFile(String videoId) async {
    try {
      print("DOWNLOADING....");
      _isDownloading=true;
      var video = await _yt.videos.get(videoId);
      var manifest = await _yt.videos.streams.getManifest(video.id);
      var audioStreamInfo = manifest.audioOnly.withHighestBitrate();
      if (audioStreamInfo == null) throw "No audio stream available.";
      var audioStream = _yt.videos.streamsClient.get(audioStreamInfo);
      var tempDir = await getApplicationDocumentsDirectory();
      var audioFilePath = '${tempDir.path}/${video.id}.webm';
      var audioFile = File(audioFilePath).openWrite();
      int totalBytes = audioStreamInfo.size.totalBytes;
      int downloadedBytes = 0;
      await for (var chunk in audioStream) {
        audioFile.add(chunk);
        downloadedBytes += chunk.length;
        _updateFileData(videoId, downloadProgress: downloadedBytes / totalBytes);
      }
      await audioFile.flush();
      await audioFile.close();
      _updateFileData(videoId, isDownload: true, path: audioFilePath, downloadProgress: 1.0);
    } catch (e) {
      print('Error downloading file: $e');
    }
  }

  Future<void> deleteFile(String id) async {
    try {
      final fileIndex = _files.indexWhere((file) => file.id == id);
      if (fileIndex == -1) return;
      final filePath = _files[fileIndex].path;
      if (filePath != null && filePath.isNotEmpty) {
        final file = File(filePath);
        if (await file.exists()) await file.delete();
      }
      _files.removeAt(fileIndex);
      update();
      _saveFileData();
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