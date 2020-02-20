// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'domain.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HumanAdapter extends TypeAdapter<Human> {
  @override
  final typeId = 0;

  @override
  Human read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Human(
      title: fields[0] as String,
    )..image = fields[1] as ImageSource;
  }

  @override
  void write(BinaryWriter writer, Human obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.image);
  }
}

class ImageSourceBase64Adapter extends TypeAdapter<ImageSourceBase64> {
  @override
  final typeId = 1;

  @override
  ImageSourceBase64 read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ImageSourceBase64(
      base64: fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ImageSourceBase64 obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.base64);
  }
}

class VotingAdapter extends TypeAdapter<Voting> {
  @override
  final typeId = 2;

  @override
  Voting read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Voting()
      ..title = fields[0] as String
      ..candidateIds = (fields[1] as List)?.cast<int>()
      ..refereeIds = (fields[2] as List)?.cast<int>()
      ..votes = (fields[3] as List)?.cast<Vote>();
  }

  @override
  void write(BinaryWriter writer, Voting obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.candidateIds)
      ..writeByte(2)
      ..write(obj.refereeIds)
      ..writeByte(3)
      ..write(obj.votes);
  }
}

class VoteAdapter extends TypeAdapter<Vote> {
  @override
  final typeId = 3;

  @override
  Vote read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Vote(
      candidateId: fields[0] as int,
      refereeId: fields[1] as int,
      value: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Vote obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.candidateId)
      ..writeByte(1)
      ..write(obj.refereeId)
      ..writeByte(2)
      ..write(obj.value);
  }
}

class EventAdapter extends TypeAdapter<Event> {
  @override
  final typeId = 4;

  @override
  Event read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Event(
      title: fields[0] as String,
    )..votingIds = (fields[1] as List)?.cast<int>();
  }

  @override
  void write(BinaryWriter writer, Event obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.votingIds);
  }
}

class ImageSourceFilenameAdapter extends TypeAdapter<ImageSourceFilename> {
  @override
  final typeId = 5;

  @override
  ImageSourceFilename read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ImageSourceFilename(
      filename: fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ImageSourceFilename obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.filename);
  }
}
