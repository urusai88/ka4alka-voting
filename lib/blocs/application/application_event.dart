import 'package:ka4alka_voting/domain.dart';
import 'package:meta/meta.dart';

abstract class ApplicationEvent {}

class ApplicationLoad extends ApplicationEvent {}

class ReloadEvent extends ApplicationEvent {
  final bool humans;
  final bool votings;
  final bool events;

  ReloadEvent({this.humans = false, this.votings = false, this.events = false});
}

class HumanCreateEvent extends ApplicationEvent {}

class HumanUpdateEvent extends ApplicationEvent {
  final Human human;

  HumanUpdateEvent({@required this.human});
}

class HumanDeleteEvent extends ApplicationEvent {
  final Human human;

  HumanDeleteEvent({@required this.human});
}

class VotingCreateEvent extends ApplicationEvent {
  final int eventId;

  VotingCreateEvent({@required this.eventId});
}

class VotingUpdateEvent extends ApplicationEvent {
  final Voting voting;

  VotingUpdateEvent({@required this.voting});
}

class VotingDeleteEvent extends ApplicationEvent {
  final Voting voting;

  VotingDeleteEvent({@required this.voting});
}

class EventCreateEvent extends ApplicationEvent {}

class EventUpdateEvent extends ApplicationEvent {
  final Event event;

  EventUpdateEvent({@required this.event});
}

class EventDeleteEvent extends ApplicationEvent {
  final Event event;

  EventDeleteEvent({@required this.event});
}
