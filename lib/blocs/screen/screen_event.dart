import 'package:ka4alka_voting/domain.dart';
import 'package:meta/meta.dart';

abstract class ScreenEvent {}

class HomeScreenEvent extends ScreenEvent {}

class HumanListScreenEvent extends ScreenEvent {}

/*
class StateListScreenEvent extends ScreenEvent {}

class StateScreenEvent extends ScreenEvent {
  final int stateId;

  StateScreenEvent({@required this.stateId});
}
*/

/// Список голосований
class VotingListScreenEvent extends ScreenEvent {
  VotingListScreenEvent();
}

/// Редактирование голосования
class VotingEditingScreenEvent extends ScreenEvent {
  final int votingId;

  VotingEditingScreenEvent({@required this.votingId});
}

/// Список участников
class VotingScreenEvent extends ScreenEvent {
  final int votingId;

  VotingScreenEvent({@required this.votingId});
}

/// Процесс голосования
class VotingProcessScreenEvent extends ScreenEvent {
  final Voting voting;
  final Human candidate;

  VotingProcessScreenEvent({@required this.voting, @required this.candidate})
      : assert(voting != null),
        assert(candidate != null);
}
