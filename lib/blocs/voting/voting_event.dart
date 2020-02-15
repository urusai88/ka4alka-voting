import 'package:ka4alka_voting/domain.dart';
import 'package:meta/meta.dart';

abstract class VotingEvent {}

class VotingLoadEvent extends VotingEvent {
  final int votingId;

  VotingLoadEvent({@required this.votingId});
}

class VotingAddCandidateEvent extends VotingEvent {
  final Human human;

  VotingAddCandidateEvent({@required this.human});
}

class VotingAddRefereeEvent extends VotingEvent {
  final Human human;

  VotingAddRefereeEvent({@required this.human});
}

class VotingRemoveCandidateEvent extends VotingEvent {
  final Human human;

  VotingRemoveCandidateEvent({@required this.human});
}

class VotingRemoveRefereeEvent extends VotingEvent {
  final Human human;

  VotingRemoveRefereeEvent({@required this.human});
}
