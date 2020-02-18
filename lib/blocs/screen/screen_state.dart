import 'package:meta/meta.dart';

import 'screen_bloc.dart';

abstract class ScreenState {}

class HomeScreenState extends ScreenState {}

class EventListScreenState extends ScreenState {}

class EventViewScreenState extends ScreenState {
  final int id;

  EventViewScreenState({@required this.id});
}

class HumanListScreenState extends ScreenState {}

class VotingListScreenState extends ScreenState {
  final int eventId;

  VotingListScreenState({@required this.eventId});
}

class VotingHumanListScreenState extends ScreenState {
  final int eventId;
  final int votingId;
  final HumanList type;

  VotingHumanListScreenState(
      {@required this.eventId, @required this.votingId, @required this.type});
}

class VotingEditScreenState extends ScreenState {
  final int eventId;
  final int votingId;

  VotingEditScreenState({@required this.votingId, this.eventId});
}

class VotingResultsScreenState extends ScreenState {
  final int votingId;

  VotingResultsScreenState({@required this.votingId})
      : assert(votingId != null);
}

class VotingResultsCarouselScreenState extends ScreenState {
  final int eventId;
  final int votingId;

  VotingResultsCarouselScreenState(
      {@required this.eventId, @required this.votingId})
      : assert(eventId != null),
        assert(votingId != null);
}

class VotingProcessScreenState extends ScreenState {
  final int eventId;
  final int votingId;

  VotingProcessScreenState({@required this.eventId, @required this.votingId});
}

class VotingProcessCandidateScreenState extends ScreenState {
  final int eventId;
  final int votingId;
  final int candidateId;

  VotingProcessCandidateScreenState(
      {@required this.eventId,
      @required this.votingId,
      @required this.candidateId});
}
