import 'package:bloc/bloc.dart';
import 'package:ka4alka_voting/blocs/application/application_event.dart';
import 'package:ka4alka_voting/blocs/application/application_state.dart';
import 'package:ka4alka_voting/domain.dart';
import 'package:ka4alka_voting/repository.dart';

class ApplicationBloc extends Bloc<ApplicationEvent, ApplicationState> {
  @override
  ApplicationState get initialState => ApplicationLoading();

  Repository repository;

  ApplicationBloc() : repository = Repository();

  @override
  Stream<ApplicationState> mapEventToState(ApplicationEvent event) async* {
    if (event is ApplicationLoad) {
      yield ApplicationLoading();

      await repository.open();

      yield ApplicationLoaded(
        humans: (await repository.humans()),
        votings: (await repository.votings()),
        events: (await repository.events()),
      );
    }

    if (event is ReloadEvent && state is ApplicationLoaded) {
      if (event.humans)
        yield (state as ApplicationLoaded)
            .copyWith(humans: (await repository.humans()));
      if (event.events)
        yield (state as ApplicationLoaded)
            .copyWith(events: (await repository.events()));
      if (event.votings)
        yield (state as ApplicationLoaded)
            .copyWith(votings: (await repository.votings()));
    }

    if (event is HumanCreateEvent && state is ApplicationLoaded) {
      await repository.saveHuman(Human());

      yield (state as ApplicationLoaded)
          .copyWith(humans: (await repository.humans()));
    }

    if (event is HumanUpdateEvent && state is ApplicationLoaded) {
      await repository.saveHuman(event.human);

      yield (state as ApplicationLoaded)
          .copyWith(humans: (await repository.humans()));
    }

    if (event is HumanDeleteEvent && state is ApplicationLoaded) {
      await repository.deleteHuman(event.human);

      yield (state as ApplicationLoaded)
          .copyWith(humans: (await repository.humans()));
    }

    if (event is VotingCreateEvent && state is ApplicationLoaded) {
      final eventModel = (state as ApplicationLoaded).events[event.eventId];
      final voting = await repository.saveVoting(Voting());

      eventModel.votingIds.add(voting.id);

      await repository.saveEvent(eventModel);

      yield (state as ApplicationLoaded)
          .copyWith(votings: (await repository.votings()));
    }

    if (event is VotingUpdateEvent && state is ApplicationLoaded) {
      await repository.saveVoting(event.voting);

      yield (state as ApplicationLoaded)
          .copyWith(votings: (await repository.votings()));
    }

    if (event is VotingDeleteEvent && state is ApplicationLoaded) {
      await repository.deleteVoting(event.voting);

      yield (state as ApplicationLoaded)
          .copyWith(votings: (await repository.votings()));
    }

    if (event is EventCreateEvent && state is ApplicationLoaded) {
      await repository.saveEvent(Event());

      yield (state as ApplicationLoaded)
          .copyWith(events: (await repository.events()));
    }

    if (event is EventUpdateEvent && state is ApplicationLoaded) {
      await repository.saveEvent(event.event);

      yield (state as ApplicationLoaded)
          .copyWith(events: (await repository.events()));
    }

    if (event is EventDeleteEvent && state is ApplicationLoaded) {
      await repository.deleteEvent(event.event);

      yield (state as ApplicationLoaded)
          .copyWith(events: (await repository.events()));
    }
  }
}
