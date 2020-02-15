import 'package:hive/hive.dart';
import 'package:meta/meta.dart';

part 'domain.g.dart';

@HiveType(typeId: 0)
class Human {
  int id;

  @HiveField(0)
  String title;

  @HiveField(1)
  ImageSource image;

  Human({this.title});

  Human copyWith({String title}) {
    return Human(title: title ?? this.title);
  }

  @override
  String toString() => '$id $title';
}

// @HiveType(typeId: 4)
abstract class ImageSource {}

@HiveType(typeId: 1)
class ImageSourceBase64 extends ImageSource {
  @HiveField(0)
  String base64;

  ImageSourceBase64({@required this.base64}) : assert(base64 != null);
}

@HiveType(typeId: 2)
class Voting {
  int id;

  @HiveField(0)
  String title;

  @HiveField(1)
  List<int> candidateIds = [];

  @HiveField(2)
  List<int> refereeIds = [];

  @HiveField(3)
  List<Vote> votes = [];
}

@HiveType(typeId: 3)
class Vote {
  @HiveField(0)
  int candidateId;

  @HiveField(1)
  int refereeId;

  @HiveField(2)
  int value;
}
