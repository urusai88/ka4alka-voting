import 'package:bloc/bloc.dart';
import 'package:ka4alka_voting/blocs/blocs.dart';
import 'package:ka4alka_voting/blocs/voting/human_list/human_list_event.dart';
import 'package:ka4alka_voting/blocs/voting/human_list/human_list_state.dart';
import 'package:meta/meta.dart';

class VotingHumanListBloc
    extends Bloc<VotingHumanListEvent, VotingHumanListState> {
  final ApplicationBloc applicationBloc;

  @override
  VotingHumanListState get initialState => VotingHumanListLoadingState();

  VotingHumanListBloc({@required this.applicationBloc});

  @override
  Stream<VotingHumanListState> mapEventToState(
      VotingHumanListEvent event) async* {
    if (event is VotingHumanListLoadEvent) {
      yield* _mapLoad(event);
    }
  }

  Stream<VotingHumanListState> _mapLoad(VotingHumanListLoadEvent event) async* {
    yield VotingHumanListLoadingState();
    yield VotingHumanListLoadedState(
        humans: applicationBloc.repository.getHumans(event.keys));
  }
}
