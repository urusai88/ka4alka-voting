import 'package:ka4alka_voting/domain.dart';
import 'package:meta/meta.dart';

abstract class VotingHumanListState {}

class VotingHumanListLoadingState extends VotingHumanListState {}

class VotingHumanListLoadedState extends VotingHumanListState {
  final int votingId;
  final Map<int, Human> humans;

  VotingHumanListLoadedState({@required this.votingId, @required this.humans});
}
