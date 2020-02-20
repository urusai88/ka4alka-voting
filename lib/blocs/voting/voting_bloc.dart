import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:ka4alka_voting/blocs/blocs.dart';
import 'package:ka4alka_voting/blocs/voting/voting_event.dart';
import 'package:ka4alka_voting/blocs/voting/voting_state.dart';
import 'package:ka4alka_voting/domain.dart';
import 'package:meta/meta.dart';

class VotingBloc extends Bloc<VotingEvent, VotingState> {
  ApplicationBloc applicationBloc;
  StreamSubscription<BoxEvent> _subscription;

  @override
  VotingState get initialState => VotingLoadingState();

  VotingBloc({@required this.applicationBloc});

  @override
  Stream<VotingState> mapEventToState(VotingEvent event) async* {
    if (event is VotingReloadFromStorage && state is VotingLoadedState) {
      yield (state as VotingLoadedState).copyWith(voting: event.voting);
    }

    if (event is VotingLoadEvent) {
      yield VotingLoadingState();

      if (_subscription != null) {
        _subscription.cancel();
        _subscription = null;
      }

      _subscription = applicationBloc.repository
          .votingBox()
          .watch(key: event.votingId)
          .listen((boxEvent) => add(VotingReloadFromStorage(boxEvent.value)));

      yield VotingLoadedState(
        voting: await applicationBloc.repository.getVoting(event.votingId),
      );
    }

    if (event is VotingAddHumanEvent && state is VotingLoadedState) {
      if (event is VotingAddHumanByNameEvent) {
        final voting = (state as VotingLoadedState).voting;
        final human = Human(title: event.name.trim());

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

      vote.value =
          event.value == null ? null : math.min(math.max(1, event.value), 15);

      await applicationBloc.repository.saveVoting(voting);

      yield VotingLoadedState(voting: voting);
    }

    if (event is VotingAddHumanByIdEvent && state is VotingLoadedState) {
      yield* _mapVotingAddHumanById(event, state as VotingLoadedState);
    }

    if (event is VotingCopyHuman && state is VotingLoadedState) {
      yield* _mapCopyHuman(event, state as VotingLoadedState);
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

  Stream<VotingState> _mapVotingAddHumanById(
      VotingAddHumanByIdEvent event, VotingLoadedState state) async* {
    switch (event.type) {
      case HumanList.Candidate:
        if (!state.voting.candidateIds.contains(event.id))
          state.voting.candidateIds.add(event.id);
        break;
      case HumanList.Referee:
        if (!state.voting.refereeIds.contains(event.id))
          state.voting.refereeIds.add(event.id);
        break;
    }

    await applicationBloc.repository.saveVoting(state.voting);

    yield state.copyWith(voting: state.voting);
  }

  Stream<VotingState> _mapCopyHuman(
      VotingCopyHuman event, VotingLoadedState state) async* {
    List<int> source;
    List<int> destination;

    Voting sourceVoting =
        await applicationBloc.repository.getVoting(event.votingId);

    switch (event.humanType) {
      case HumanList.Candidate:
        destination = state.voting.candidateIds;
        source = sourceVoting.candidateIds;
        break;
      case HumanList.Referee:
        destination = state.voting.refereeIds;
        source = sourceVoting.refereeIds;
        break;
    }

    for (final id in source) {
      if (!destination.contains(id)) {
        destination.add(id);
      }
    }

    await applicationBloc.repository.saveVoting(state.voting);

    yield state.copyWith(voting: state.voting);
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
