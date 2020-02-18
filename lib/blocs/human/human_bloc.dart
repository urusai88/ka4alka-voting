import 'package:bloc/bloc.dart';
import 'package:ka4alka_voting/blocs/blocs.dart';
import 'package:meta/meta.dart';

class HumanBloc extends Bloc<HumanEvent, HumanState> {
  final ApplicationBloc applicationBloc;

  @override
  HumanState get initialState => HumanDummyState();

  HumanBloc({@required this.applicationBloc});

  @override
  Stream<HumanState> mapEventToState(HumanEvent event) async* {
    if (event is HumanLoadEvent) {
      yield* _mapHumanLoad(event);
    }

    if (event is HumanUpdateEvent && state is HumanLoadedState) {
      yield* _mapHumanUpdate(event, state as HumanLoadedState);
    }
  }

  Stream<HumanState> _mapHumanLoad(HumanLoadEvent event) async* {
    final human = applicationBloc.repository.getHuman(event.id);

    if (human != null) yield HumanLoadedState(human: human);
  }

  Stream<HumanState> _mapHumanUpdate(
      HumanUpdateEvent event, HumanLoadedState state) async* {
    await applicationBloc.repository.saveHuman(event.human);

    yield state.copyWith(human: event.human);
  }
}
