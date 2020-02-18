import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ka4alka_voting/blocs/blocs.dart';
import 'package:ka4alka_voting/blocs/voting/voting_event.dart';
import 'package:ka4alka_voting/blocs/voting/voting_state.dart';
import 'package:ka4alka_voting/domain.dart';
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
        voting: await applicationBloc.repository.getVoting(event.votingId),
      );
    }

    if (event is VotingAddHumanEvent && state is VotingLoadedState) {
      if (event is VotingAddHumanByNameEvent) {
        final voting = (state as VotingLoadedState).voting;
        final human = Human(title: event.name);

        await applicationBloc.repository.saveHuman(human);

        applicationBloc.add(ReloadEvent(humans: true));

        switch (event.type) {
          case HumanList.Candidate:
            voting.candidateIds.add(human.id);
            break;
          case HumanList.Referee:
            voting.refereeIds.add(human.id);
            break;
        }

        await applicationBloc.repository.saveVoting(voting);

        yield (state as VotingLoadedState).copyWith(voting: voting);
      }
    }

    if (event is VotingRemoveHuman && state is VotingLoadedState)
      yield* _mapVotingRemoveHuman(event, state as VotingLoadedState);

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

    if (event is VotingVoteEvent && state is VotingLoadedState) {
      final voting = (state as VotingLoadedState).voting;
      final vote = voting.getVote(event.candidate.id, event.referee.id);

      vote.value = event.value;

      await applicationBloc.repository.saveVoting(voting);

      yield VotingLoadedState(voting: voting);
    }
  }

  Stream<VotingState> _mapVotingRemoveHuman(
    VotingRemoveHuman event,
    VotingLoadedState state,
  ) async* {
    final voting = state.voting;
    final list = event.humanType == HumanList.Candidate
        ? voting.candidateIds
        : voting.refereeIds;

    if (list.contains(event.humanId)) {
      list.remove(event.humanId);

      await applicationBloc.repository.saveVoting(voting);

      yield state.copyWith(voting: voting);
    }
  }
}
