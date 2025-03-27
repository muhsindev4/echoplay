class FileData {
  final String id;
  final String name;
  final String? path;
  final String? description;
  final String? thumbnails;
  final Duration? duration;
  final DateTime? publishDate;
  final bool isDownload;
  final double downloadProgress;

  FileData({
    required this.id,
    required this.name,
    this.path,
    this.description,
    this.thumbnails,
    this.duration,
    this.publishDate,
    this.isDownload = false,
    this.downloadProgress = 0.0,
  });

  FileData copyWith({
    String? id,
    String? name,
    String? path,
    String? description,
    String? thumbnails,
    Duration? duration,
    DateTime? publishDate,
    bool? isDownload,
    double? downloadProgress,
  }) {
    return FileData(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      description: description ?? this.description,
      thumbnails: thumbnails ?? this.thumbnails,
      duration: duration ?? this.duration,
      publishDate: publishDate ?? this.publishDate,
      isDownload: isDownload ?? this.isDownload,
      downloadProgress: downloadProgress ?? this.downloadProgress,
    );
  }

  factory FileData.fromJson(Map<String, dynamic> json) {
    return FileData(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown',
      path: json['path'] as String?,
      description: json['description'] as String?,
      thumbnails: json['thumbnails'] as String?,
      duration: json['duration'] != null ? Duration(seconds: json['duration']) : null,
      publishDate: json['publishDate'] != null ? DateTime.tryParse(json['publishDate']) : null,
      isDownload: json['isDownload'] ?? false,
      downloadProgress: (json['downloadProgress'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'description': description,
      'thumbnails': thumbnails,
      'duration': duration?.inSeconds,
      'publishDate': publishDate?.toIso8601String(),
      'isDownload': isDownload,
      'downloadProgress': downloadProgress,
    };
  }
}
