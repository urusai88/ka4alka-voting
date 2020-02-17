import 'package:bloc/bloc.dart';
import 'package:ka4alka_voting/blocs/screen/screen_event.dart';
import 'package:ka4alka_voting/blocs/screen/screen_state.dart';

enum HumanList { Candidate, Referee }

class ScreenBloc extends Bloc<ScreenEvent, ScreenState> {
  @override
  ScreenState get initialState => HomeScreenState();

  @override
  Stream<ScreenState> mapEventToState(ScreenEvent event) async* {
    if (event is HumanListScreenEvent) yield HumanListScreenState();
    if (event is VotingEditingScreenEvent)
      yield VotingEditScreenState(
        votingId: event.votingId,
        eventId: event.eventId,
      );
    if (event is VotingScreenEvent)
      yield VotingScreenState(votingId: event.votingId);
    if (event is VotingProcessScreenEvent)
      yield VotingProcessScreenState(
        voting: event.voting,
        candidate: event.candidate,
      );
    if (event is VotingResultsScreenEvent)
      yield VotingResultsScreenState(votingId: event.voting.id);
    if (event is VotingResultsCarouselScreenEvent)
      yield VotingResultsCarouselScreenState(votingId: event.voting.id);
    if (event is EventListScreenEvent) yield EventListScreenState();
    if (event is EventViewScreenEvent) yield EventViewScreenState(id: event.id);
    if (event is VotingListScreenEvent)
      yield VotingListScreenState(eventId: event.eventId);
    if (event is VotingHumanListScreenEvent)
      yield VotingHumanListScreenState(
        eventId: event.eventId,
        votingId: event.votingId,
        type: event.type,
      );
  }
}
