// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FileDataAdapter extends TypeAdapter<FileData> {
  @override
  final int typeId = 0;

  @override
  FileData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FileData(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      thumbnails: fields[3] as String,
      createdAt: fields[9] as DateTime,
      duration: fields[4] as int?,
      publishDate: fields[5] as DateTime?,
      path: fields[6] as String?,
      playlistId: fields[10] as int?,
      isDownload: fields[7] as bool,
      downloadProgress: fields[8] as double,
    );
  }

  @override
  void write(BinaryWriter writer, FileData obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.thumbnails)
      ..writeByte(4)
      ..write(obj.duration)
      ..writeByte(5)
      ..write(obj.publishDate)
      ..writeByte(6)
      ..write(obj.path)
      ..writeByte(7)
      ..write(obj.isDownload)
      ..writeByte(8)
      ..write(obj.downloadProgress)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.playlistId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
