import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play/app/controllers/download_controller.dart';
import 'package:play/app/data/models/file_data.dart';
import '../../controllers/playback_controller.dart';

class DownloadsScreen extends StatelessWidget {
  final _downloadController = Get.put(DownloadController());
  final _playController = Get.put(PlaybackController());

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$minutes:$seconds";
    } else {
      return "$minutes:$seconds";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: (){
    _downloadController.downloadAll();
      }),
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Downloads"),
        actions: [
          GetBuilder<DownloadController>(
            builder: (controller) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  "${controller.files.where((t) => t.isDownload).length}/${controller.files.length} Downloads",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _downloadController.loadStoredFiles();
        },
        child: GetBuilder<DownloadController>(
          builder: (_) {
            if (_downloadController.files.isEmpty) {
              return const Center(
                child: Text("No downloads yet", style: TextStyle(fontSize: 16)),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(15),
              itemCount: _downloadController.files.length,
              itemBuilder: (BuildContext context, int index) {
                FileData data = _downloadController.files[index];
                bool isPlaying = _playController.isPlaying(data.path ?? "");
                return GetBuilder<PlaybackController>(
                  builder: (_) {
                    return Container(
                      decoration: BoxDecoration(
                        color: isPlaying ? Colors.blue.shade50 : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isPlaying ? Colors.blue : Colors.grey.shade300,
                          width: 1.5,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        onTap: () {
                          if (!data.isDownload) return;
                          List<FileData> allFiles =
                              _downloadController.files
                                  .where((t) => t.isDownload)
                                  .toList();
                          int startIndex = index;
                          List<FileData> reorderedFiles = [
                            allFiles[startIndex],
                            ...allFiles.sublist(startIndex + 1),
                            ...allFiles.sublist(0, startIndex),
                          ];
                          _playController.playAll(reorderedFiles);
                        },
                        leading: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child:
                                  data.thumbnails != null
                                      ? Image.network(
                                        data.thumbnails!,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      )
                                      : CircleAvatar(
                                        backgroundColor: Colors.grey.shade200,
                                        radius: 25,
                                        child: Icon(
                                          data.isDownload
                                              ? Icons.file_download_done
                                              : Icons.download,
                                          color:
                                              data.isDownload
                                                  ? Colors.green
                                                  : Colors.grey,
                                        ),
                                      ),
                            ),
                            if (data.duration != null)
                              Positioned(
                                bottom: 4,
                                right: 4,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    _formatDuration(data.duration!),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),

                        title: Text(
                          data.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle:
                            data.isDownload
                                ? null
                                : Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: LinearProgressIndicator(
                                    value: data.downloadProgress,
                                    backgroundColor: Colors.grey.shade300,
                                    color: Colors.blue,
                                    minHeight: 4,
                                  ),
                                ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (data.isDownload)
                              IconButton(
                                icon: Icon(
                                  isPlaying
                                      ? Icons.pause_circle_filled
                                      : Icons.play_circle_fill,
                                  color: Colors.blue,
                                ),
                                onPressed: () {
                                  if (isPlaying) {
                                    _playController.pause();
                                  } else {
                                    _playController.play(data);
                                  }
                                },
                                tooltip: isPlaying ? "Pause" : "Play",
                              ),
                            IconButton(
                              icon: Icon(
                                data.isDownload ? Icons.delete : Icons.refresh,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                if (data.isDownload) {
                                  _downloadController.deleteFile(data.id);
                                  if (isPlaying) {
                                    _playController.stop();
                                  }
                                } else {
                                  _downloadController.downloadFile(data.id);
                                }
                              },
                              tooltip: data.isDownload ? "Delete" : "Retry",
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(height: 10);
              },
            );
          },
        ),
      ),
    );
  }
}
