import 'package:ka4alka_voting/domain.dart';
import 'package:meta/meta.dart';

import 'screen_bloc.dart';

abstract class ScreenEvent {}

class EventListScreenEvent extends ScreenEvent {}

class EventViewScreenEvent extends ScreenEvent {
  final int id;

  EventViewScreenEvent({@required this.id});
}

/// Список голосований
class VotingListScreenEvent extends ScreenEvent {
  final int eventId;

  VotingListScreenEvent({@required this.eventId});
}

class HomeScreenEvent extends ScreenEvent {}

class HumanListScreenEvent extends ScreenEvent {}

/*
class StateListScreenEvent extends ScreenEvent {}

class StateScreenEvent extends ScreenEvent {
  final int stateId;

  StateScreenEvent({@required this.stateId});
}
*/

/// Редактирование голосования
class VotingEditingScreenEvent extends ScreenEvent {
  final int eventId;
  final int votingId;

  VotingEditingScreenEvent({@required this.votingId, this.eventId});
}

class VotingHumanListScreenEvent extends ScreenEvent {
  final int eventId;
  final int votingId;
  final HumanList type;

  VotingHumanListScreenEvent(
      {@required this.eventId, @required this.votingId, @required this.type});
}

/// Процесс голосования
class VotingProcessScreenEvent extends ScreenEvent {
  final int eventId;
  final int votingId;

  VotingProcessScreenEvent({@required this.eventId, @required this.votingId});
}

/// Процесс голосования отдельного участника
class VotingProcessCandidateScreenEvent extends ScreenEvent {
  final int eventId;
  final int votingId;
  final int candidateId;

  VotingProcessCandidateScreenEvent(
      {@required this.eventId,
      @required this.votingId,
      @required this.candidateId});
}

class VotingResultsScreenEvent extends ScreenEvent {
  final Voting voting;

  VotingResultsScreenEvent({@required this.voting}) : assert(voting != null);
}

class VotingResultsCarouselScreenEvent extends ScreenEvent {
  final int eventId;
  final int votingId;

  VotingResultsCarouselScreenEvent(
      {@required this.eventId, @required this.votingId})
      : assert(eventId != null),
        assert(votingId != null);
}
