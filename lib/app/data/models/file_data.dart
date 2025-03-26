class FileData {
  final String id;
  final String name;
  final String? path;
  final bool isDownload;
  final double downloadProgress;

  FileData({
    this.isDownload = false,
    this.path,
    this.downloadProgress=0,
    required this.id,
    required this.name,
  });

  FileData copyWith({
    String? id,
    String? name,
    String? path,
    double? downloadProgress,
    bool? isDownload,
  }) {
    return FileData(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      isDownload: isDownload ?? this.isDownload,
    );
  }

  // Convert JSON to FileData object
  factory FileData.fromJson(Map<String, dynamic> json) {
    return FileData(
      id: json['id'],
      name: json['name'],
      downloadProgress: json['downloadProgress'],
      path: json['path'],
      isDownload: json['isDownload'] ?? false,
    );
  }

  // Convert FileData object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'downloadProgress': downloadProgress,
      'path': path,
      'isDownload': isDownload,
    };
  }
}
