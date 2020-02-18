import 'package:ka4alka_voting/domain.dart';
import 'package:meta/meta.dart';

abstract class HumanState {}

class HumanDummyState extends HumanState {}

class HumanLoadedState extends HumanState {
  final Human human;

  HumanLoadedState({@required this.human});

  HumanLoadedState copyWith({Human human}) {
    return HumanLoadedState(human: human);
  }
}
