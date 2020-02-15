import 'package:ka4alka_voting/domain.dart';
import 'package:meta/meta.dart';

abstract class ApplicationEvent {}

class ApplicationLoad extends ApplicationEvent {}

class HumanCreateEvent extends ApplicationEvent {}

class HumanUpdateEvent extends ApplicationEvent {
  final Human human;

  HumanUpdateEvent({@required this.human});
}

class HumanDeleteEvent extends ApplicationEvent {
  final Human human;

  HumanDeleteEvent({@required this.human});
}

class VotingCreateEvent extends ApplicationEvent {}

class VotingUpdateEvent extends ApplicationEvent {
  final Voting voting;

  VotingUpdateEvent({@required this.voting});
}

class VotingDeleteEvent extends ApplicationEvent {
  final Voting voting;

  VotingDeleteEvent({@required this.voting});
}
