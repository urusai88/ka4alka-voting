import 'package:ka4alka_voting/domain.dart';

abstract class ApplicationState {}

class ApplicationLoading extends ApplicationState {}

class ApplicationLoaded extends ApplicationState {
  Map<int, Human> humans;
  Map<int, Event> events;
  Map<int, Voting> votings;

  ApplicationLoaded({
    Map<int, Human> humans,
    Map<int, Voting> votings,
    Map<int, Event> events,
  })  : this.humans = humans ?? [],
        this.votings = votings ?? [],
        this.events = events ?? [];

  ApplicationLoaded copyWith({
    Map<int, Human> humans,
    Map<int, Voting> votings,
    Map<int, Event> events,
  }) {
    return ApplicationLoaded(
      humans: humans ?? this.humans,
      votings: votings ?? this.votings,
      events: events ?? this.events,
    );
  }

  @override
  String toString() =>
      'ApplicationLoaded {humans: ${humans.length}, votings: ${votings.length}, events: ${events.length}';
}
