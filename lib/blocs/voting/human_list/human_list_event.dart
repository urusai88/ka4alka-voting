import 'package:meta/meta.dart';

abstract class VotingHumanListEvent {}

class VotingHumanListLoadEvent extends VotingHumanListEvent {
  final List<int> keys;

  VotingHumanListLoadEvent({@required this.keys});
}
