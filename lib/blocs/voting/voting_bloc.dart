import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ka4alka_voting/blocs/blocs.dart';
import 'package:ka4alka_voting/blocs/voting/voting_event.dart';
import 'package:ka4alka_voting/blocs/voting/voting_state.dart';
import 'package:meta/meta.dart';

class VotingBloc extends Bloc<VotingEvent, VotingState> {
  ApplicationBloc applicationBloc;

  @override
  VotingState get initialState => VotingLoadingState();

  VotingBloc({@required this.applicationBloc});

  @override
  Stream<VotingState> mapEventToState(VotingEvent event) async* {
    if (event is VotingLoadEvent) {
      yield VotingLoadingState();
      yield VotingLoadedState(
          voting: await applicationBloc.repository.getVoting(event.votingId));
    }

    if (event is VotingAddCandidateEvent && state is VotingLoadedState) {
      final voting = (state as VotingLoadedState).voting;

      if (!voting.candidateIds.contains(event.human.id)) {
        voting.candidateIds.add(event.human.id);
        voting.candidateIds.sort();

        await applicationBloc.repository.saveVoting(voting);

        yield VotingLoadedState(voting: voting);
      }
    }

    if (event is VotingAddRefereeEvent && state is VotingLoadedState) {
      final voting = (state as VotingLoadedState).voting;

      if (!voting.refereeIds.contains(event.human.id)) {
        voting.refereeIds.add(event.human.id);
        voting.refereeIds.sort();

        await applicationBloc.repository.saveVoting(voting);

        yield VotingLoadedState(voting: voting);
      }
    }

    if (event is VotingRemoveCandidateEvent && state is VotingLoadedState) {
      final voting = (state as VotingLoadedState).voting;

      if (voting.candidateIds.contains(event.human.id)) {
        voting.candidateIds.remove(event.human.id);
        voting.candidateIds.sort();

        await applicationBloc.repository.saveVoting(voting);

        yield VotingLoadedState(voting: voting);
      }
    }

    if (event is VotingRemoveRefereeEvent && state is VotingLoadedState) {
      final voting = (state as VotingLoadedState).voting;

      if (voting.refereeIds.contains(event.human.id)) {
        voting.refereeIds.remove(event.human.id);
        voting.refereeIds.sort();

        await applicationBloc.repository.saveVoting(voting);

        yield VotingLoadedState(voting: voting);
      }
    }
  }
}
