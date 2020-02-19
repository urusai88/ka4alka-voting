import 'package:meta/meta.dart';

abstract class VotingHumanListEvent {}

class VotingHumanListLoadEvent extends VotingHumanListEvent {
  final List<int> ids;

  VotingHumanListLoadEvent({@required this.ids});
}
