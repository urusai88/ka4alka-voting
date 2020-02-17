import 'package:ka4alka_voting/domain.dart';
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

class VotingScreenState extends ScreenState {
  final int votingId;

  VotingScreenState({@required this.votingId});
}

class VotingProcessScreenState extends ScreenState {
  final Voting voting;
  final Human candidate;

  VotingProcessScreenState({@required this.voting, @required this.candidate})
      : assert(voting != null),
        assert(candidate != null);
}

class VotingResultsScreenState extends ScreenState {
  final int votingId;

  VotingResultsScreenState({@required this.votingId})
      : assert(votingId != null);
}

class VotingResultsCarouselScreenState extends ScreenState {
  final int votingId;

  VotingResultsCarouselScreenState({@required this.votingId})
      : assert(votingId != null);
}
