import 'package:bloc/bloc.dart';
import 'package:ka4alka_voting/blocs/blocs.dart';
import 'package:ka4alka_voting/blocs/voting/list/list_event.dart';
import 'package:ka4alka_voting/blocs/voting/list/list_state.dart';
import 'package:meta/meta.dart';

class VotingListBloc extends Bloc<VotingListEvent, VotingListState> {
  final ApplicationBloc applicationBloc;

  @override
  VotingListState get initialState => VotingListLoadingState();

  VotingListBloc({@required this.applicationBloc})
      : assert(applicationBloc != null);

  @override
  Stream<VotingListState> mapEventToState(VotingListEvent event) async* {
    if (event is VotingListLoadEvent) yield* _mapLoad(event, state);
  }

  Stream<VotingListState> _mapLoad(
      VotingListLoadEvent event, VotingListState state) async* {
    yield VotingListLoadingState();
    try {
      final votings = await applicationBloc.repository.votings();

      yield VotingListLoadedState(votings: votings);
    } catch (e) {
      print(e);
    }
  }
}
