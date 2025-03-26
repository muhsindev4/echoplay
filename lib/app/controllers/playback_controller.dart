import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:get/get.dart';
import 'package:play/app/data/models/file_data.dart';

class PlaybackController extends GetxController {
  final AudioPlayer player = AudioPlayer();
  final ConcatenatingAudioSource playlist = ConcatenatingAudioSource(children: []);
  final RxInt currentIndex = 0.obs;

  Future<void> playAll(List<FileData> files) async {
    try {
      playlist.clear(); // Clear existing playlist
      for (var file in files) {
        playlist.add(AudioSource.uri(
          Uri.file(file.path!),
          tag: MediaItem(
            id: file.id.toString(),
            title: file.name,
            album: "Downloads",
            artist: "Unknown",
            extras: {"filePath": file.path},
          ),
        ));
      }

      await player.setAudioSource(playlist);
      await player.play();
      player.currentIndexStream.listen((index) {
        if (index != null) {
          currentIndex.value = index;
        }
      });
    } catch (e) {
      print("Error playing playlist: $e");
    }
  }

  Future<void> play(FileData file) async {
    try {
      final audioSource = AudioSource.uri(
        Uri.file(file.path!),
        tag: MediaItem(
          id: file.id.toString(),
          title: file.name,
          album: "Downloads",
          artist: "Unknown",
          extras: {"filePath": file.path},
        ),
      );

      await player.setAudioSource(audioSource);
      await player.play();
    } catch (e) {
      print("Error playing file: $e");
    }
  }

  void playNext() {
    if (currentIndex.value < playlist.length - 1) {
      player.seekToNext();
    }
  }

  void playPrevious() {
    if (currentIndex.value > 0) {
      player.seekToPrevious();
    }
  }

  void stop() {
    player.stop();
  }
}
