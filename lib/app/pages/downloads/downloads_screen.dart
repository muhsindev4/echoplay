import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play/app/controllers/download_controller.dart';
import 'package:play/app/data/models/file_data.dart';

import '../../controllers/playback_controller.dart';

class DownloadsScreen extends StatelessWidget{
  final _downloadController= Get.put(DownloadController(),);
  final _playController= Get.put(PlaybackController(),);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Downloads")),
      body: RefreshIndicator(
        onRefresh: () async {
          _downloadController.loadStoredFiles();
        },
        child: GetBuilder<DownloadController>(
          builder: (_) {
            if (_downloadController.files.isEmpty) {
              return const Center(child: Text("No downloads yet"));
            }
            return ListView.builder(
              itemCount: _downloadController.files.length,
              itemBuilder: (BuildContext context, int index) {
                FileData data = _downloadController.files[index];
                return GetBuilder<PlaybackController>(
                  builder: (_) {
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        onTap: (){
                          if(!data.isDownload){
                            return ;
                          }
                          List<FileData> allFiles = _downloadController.files;
                          int startIndex = index; // Get the index of the clicked file
                          List<FileData> reorderedFiles = [
                            allFiles[startIndex], // First play the clicked file
                            ...allFiles.sublist(startIndex + 1), // Then play the rest after it
                            ...allFiles.sublist(0, startIndex) // Finally play files before the clicked one
                          ];

                          _playController.playAll(reorderedFiles);
                        },
                        leading: data.isDownload
                            ? const Icon(Icons.file_download_done, color: Colors.green)
                            : const Icon(Icons.download, color: Colors.grey),
                        title: Text(data.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data.path ?? "Downloading...", style: TextStyle(fontSize: 12, color: Colors.grey)),
                            if (!data.isDownload)
                              LinearProgressIndicator(value: data.downloadProgress, minHeight: 4),
                          ],
                        ),
                        trailing: data.isDownload
                            ? IconButton(icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _downloadController.deleteFile(data.id),
                        )
                            : IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.red),
                          onPressed: () => _downloadController.download(data.id),
                        ),
                      ),
                    );
                  }
                );
              },
            );
          },
        ),
      ),
    );
  }
}
