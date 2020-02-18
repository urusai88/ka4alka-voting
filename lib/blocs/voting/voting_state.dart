import 'package:ka4alka_voting/domain.dart';
import 'package:meta/meta.dart';

abstract class VotingState {}

class VotingLoadingState extends VotingState {}

class VotingLoadedState extends VotingState {
  final Voting voting;

  VotingLoadedState({@required this.voting});

  VotingLoadedState copyWith({Voting voting}) {
    return VotingLoadedState(voting: voting);
  }
}
