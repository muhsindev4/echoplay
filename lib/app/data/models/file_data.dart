import 'package:hive/hive.dart';

part 'file_data.g.dart';

@HiveType(typeId: 0)
class FileData extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String thumbnails;

  @HiveField(4)
  final int? duration;

  @HiveField(5)
  final DateTime? publishDate;

  @HiveField(6)
  final String? path;

  @HiveField(7)
  final bool isDownload;

  @HiveField(8)
  final double downloadProgress;

  FileData({
    required this.id,
    required this.name,
    required this.description,
    required this.thumbnails,
    this.duration,
    this.publishDate,
    this.path,
    this.isDownload = false,
    this.downloadProgress = 0.0,
  });

  FileData copyWith({
    String? id,
    String? name,
    String? description,
    String? thumbnails,
    int? duration,
    DateTime? publishDate,
    String? path,
    bool? isDownload,
    double? downloadProgress,
  }) {
    return FileData(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      thumbnails: thumbnails ?? this.thumbnails,
      duration: duration ?? this.duration,
      publishDate: publishDate ?? this.publishDate,
      path: path ?? this.path,
      isDownload: isDownload ?? this.isDownload,
      downloadProgress: downloadProgress ?? this.downloadProgress,
    );
  }
}
