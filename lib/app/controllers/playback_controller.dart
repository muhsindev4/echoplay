import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:get/get.dart';
import 'package:play/app/data/models/file_data.dart';

class PlaybackController extends GetxController {
  final AudioPlayer _player = AudioPlayer();
  final ConcatenatingAudioSource _playlist = ConcatenatingAudioSource(children: []);
  final List<FileData> _currentFiles = [];
   List<FileData> get currentFiles =>_currentFiles;

  int _currentIndex = 0;

  @override
  void onInit() {
    super.onInit();
    _player.currentIndexStream.listen((index) {
      if (index != null) {
        _currentIndex = index;
        update();
      }
    });
  }

  bool isPlaying(String path) {
    // Check if the current audio is playing and matches the path
    if (_player.playing) {
      // Check if the current audio source path matches the given path
      return _currentFiles.isNotEmpty && _currentFiles[_currentIndex].path == path;
    }
    return false;
  }

  Future<void> playAll(List<FileData> files) async {
    try {
      _playlist.clear();
      _currentFiles.clear();
      _currentFiles.addAll(files);

      final sources = files.map((file) {
        return AudioSource.uri(
          Uri.file(file.path!),
          tag: MediaItem(
            id: file.id.toString(),
            title: file.name,
            album: "Downloads",
            artist: "Unknown",
            duration:Duration(seconds:  file.duration!),
            artUri: Uri.tryParse(file.thumbnails ?? ""),
            extras: {"filePath": file.path},
          ),
        );
      }).toList();

      _playlist.addAll(sources);
      await _player.setAudioSource(_playlist);
      await _player.play();
      await Future.delayed(Duration(seconds: 1));
      update();
    } catch (e) {
      print("Error playing playlist: $e");
    }
  }

  Future<void> play(FileData file) async {
    try {
      _currentFiles.clear();
      _currentFiles.add(file);

      final source = AudioSource.uri(
        Uri.file(file.path!),
        tag: MediaItem(
          id: file.id.toString(),
          title: file.name,
          album: "Downloads",
          artist: "Unknown",
          duration:Duration(seconds: file.duration!) ,
          artUri: Uri.tryParse(file.thumbnails ?? ""),
          extras: {"filePath": file.path},
        ),
      );

      await _player.setAudioSource(source);
      await _player.play();
    } catch (e) {
      print("Error playing file: $e");
    }
  }

  void playNext() {
    _player.seekToNext();
  }

  void playPrevious() {
    _player.seekToPrevious();
  }

  void pause() {
    _player.pause();
    update();
  }

  void stop() {
    _player.stop();
  }

  /// Get the currently playing FileData, or null if not available
  FileData? getCurrentFileData() {
    if (_currentFiles.isEmpty || _player.currentIndex == null) return null;
    return _currentFiles[_player.currentIndex!];
  }
}
