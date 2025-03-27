import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:get/get.dart';
import 'package:play/app/data/models/file_data.dart';

class PlaybackController extends GetxController {
  final AudioPlayer player = AudioPlayer();
  final ConcatenatingAudioSource playlist = ConcatenatingAudioSource(children: []);
  final RxInt currentIndex = 0.obs;

  bool isPlaying(String path) {
    return player.playing &&
        player.currentIndex != null &&
        playlist.children.isNotEmpty &&
       ( playlist.children[player.currentIndex!] as UriAudioSource).uri.path==path;
  }

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
            duration: file.duration,
            artUri:Uri.tryParse(file.thumbnails??"") ,
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
      update();
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
      update();
    } catch (e) {
      print("Error playing file: $e");
    }
  }

  void playNext() {
    if (currentIndex.value < playlist.length - 1) {
      player.seekToNext();
      update();
    }
  }

  void playPrevious() {
    if (currentIndex.value > 0) {
      player.seekToPrevious();
      update();
    }
  }

  void pause() {
    player.pause();
    update();
  }

  void stop() {
    player.stop();
    update();
  }
}
