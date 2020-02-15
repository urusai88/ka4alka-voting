import 'package:ka4alka_voting/domain.dart';
import 'package:meta/meta.dart';

abstract class ScreenState {}

class HomeScreenState extends ScreenState {}

class HumanListScreenState extends ScreenState {}

class VotingListScreenState extends ScreenState {}

class VotingEditScreenState extends ScreenState {
  final int votingId;

  VotingEditScreenState({@required this.votingId});
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
