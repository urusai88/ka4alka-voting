import 'package:ka4alka_voting/blocs/blocs.dart';
import 'package:ka4alka_voting/domain.dart';
import 'package:meta/meta.dart';

abstract class VotingEvent {}

class VotingLoadEvent extends VotingEvent {
  final int votingId;

  VotingLoadEvent({@required this.votingId});
}

class VotingReloadFromStorage extends VotingEvent {
  final Voting voting;

  VotingReloadFromStorage(this.voting);
}

abstract class VotingAddHumanEvent extends VotingEvent {
  final HumanList type;

  VotingAddHumanEvent({@required this.type}) : assert(type != null);
}

class VotingAddHumanByNameEvent extends VotingAddHumanEvent {
  final String name;

  VotingAddHumanByNameEvent({@required this.name, @required HumanList type})
      : assert(name != null && name.trim().length > 0),
        super(type: type);
}

class VotingAddHumanByIdEvent extends VotingAddHumanEvent {
  final int id;

  VotingAddHumanByIdEvent({@required this.id, @required HumanList type})
      : assert(id != null),
        super(type: type);
}

class VotingRemoveHuman extends VotingEvent {
  final int humanId;
  final HumanList humanType;

  VotingRemoveHuman({@required this.humanId, @required this.humanType})
      : assert(humanId != null),
        assert(humanType != null);
}

class VotingRemoveCandidateEvent extends VotingEvent {
  final Human human;

  VotingRemoveCandidateEvent({@required this.human});
}

class VotingRemoveRefereeEvent extends VotingEvent {
  final Human human;

  VotingRemoveRefereeEvent({@required this.human});
}

class VotingVoteEvent extends VotingEvent {
  final Human candidate;
  final Human referee;
  final int value;

  VotingVoteEvent(
      {@required this.candidate, @required this.referee, @required this.value});
}
