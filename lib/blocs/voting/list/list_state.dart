import 'package:ka4alka_voting/domain.dart';
import 'package:meta/meta.dart';

abstract class VotingListState {}

class VotingListLoadingState extends VotingListState {}

class VotingListLoadedState extends VotingListState {
  final Map<int, Voting> votings;

  VotingListLoadedState({@required this.votings}) : assert(votings != null);
}
