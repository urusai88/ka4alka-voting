import 'package:bloc/bloc.dart';
import 'package:ka4alka_voting/blocs/voting/human_list/human_list_event.dart';
import 'package:ka4alka_voting/blocs/voting/human_list/human_list_state.dart';

class VotingHumanListBloc
    extends Bloc<VotingHumanListEvent, VotingHumanListState> {
  @override
  VotingHumanListState get initialState => VotingHumanListLoadingState();

  @override
  Stream<VotingHumanListState> mapEventToState(
      VotingHumanListEvent event) async* {}
}
