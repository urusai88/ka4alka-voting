import 'package:ka4alka_voting/domain.dart';

abstract class ApplicationState {}

class ApplicationLoading extends ApplicationState {}

class ApplicationLoaded extends ApplicationState {
  Map<int, Human> humans;
  Map<int, Voting> votings;

  ApplicationLoaded({Map<int, Human> humans, Map<int, Voting> votings})
      : this.humans = humans ?? [],
        this.votings = votings ?? [];

  ApplicationLoaded copyWith(
      {Map<int, Human> humans, Map<int, Voting> votings}) {
    return ApplicationLoaded(
      humans: humans ?? this.humans,
      votings: votings ?? this.votings,
    );
  }

  @override
  String toString() =>
      'ApplicationLoaded {humans.length: ${humans.length}, votings.length: ${votings.length}}';
}
