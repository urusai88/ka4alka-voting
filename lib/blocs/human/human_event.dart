import 'package:ka4alka_voting/domain.dart';
import 'package:meta/meta.dart';

abstract class HumanEvent {}

class HumanLoadEvent extends HumanEvent {
  final int id;

  HumanLoadEvent({@required this.id});
}

class HumanUpdateEvent extends HumanEvent {
  final Human human;

  HumanUpdateEvent({@required this.human});
}
