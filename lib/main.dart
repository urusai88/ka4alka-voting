import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ka4alka_voting/blocs/blocs.dart';
import 'package:ka4alka_voting/blocs/screen/screen.dart';
import 'package:ka4alka_voting/domain.dart';
import 'package:ka4alka_voting/repository.dart';
import 'package:ka4alka_voting/screens/screens.dart';
import 'package:ka4alka_voting/simple_bloc_delegate.dart';

void main() async {
  await Hive.initFlutter();

  Hive.registerAdapter(EventAdapter());
  Hive.registerAdapter(HumanAdapter());
  Hive.registerAdapter(VotingAdapter());
  Hive.registerAdapter(VoteAdapter());
  Hive.registerAdapter(ImageSourceBase64Adapter());

  await Hive.openBox<Event>(Repository.EventBoxName);
  await Hive.openBox<Voting>(Repository.VotingBoxName);
  await Hive.openBox<Human>(Repository.HumanBoxName);

  BlocSupervisor.delegate = SimpleBlocDelegate();

  runApp(BlocProvider(
    create: (context) => ScreenBloc(),
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  // final Router
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) {
            return ApplicationBloc()..add(ApplicationLoad());
          },
        ),
      ],
      child: MaterialApp(
        home: HomeScreen(),
        onGenerateRoute: (settings) {
          print(settings.name);

          VotingBloc _votingBloc(BuildContext context, [int votingId]) {
            final bloc = VotingBloc(
              applicationBloc: BlocProvider.of<ApplicationBloc>(context),
            );

            if (votingId != null) bloc.add(VotingLoadEvent(votingId: votingId));

            return bloc;
          }

          if (settings.name == '/') {
            return MaterialPageRoute(
              builder: (context) => HomeScreen(),
              settings:
                  RouteSettings(name: settings.name, isInitialRoute: true),
            );
          }

          if (settings.name == '/event/list') {
            return MaterialPageRoute(
              builder: (context) => EventListScreen(),
              settings: RouteSettings(name: settings.name),
            );
          }

          if (settings.name
              .startsWith(RegExp(VotingResultsCarouselScreen.RouteWildcard))) {
            final match = RegExp(VotingResultsCarouselScreen.RouteWildcard)
                .firstMatch(settings.name);
            final eventId = int.parse(match.namedGroup('eventId'));
            final votingId = int.parse(match.namedGroup('votingId'));

            return MaterialPageRoute(
                builder: (context) {
                  return BlocProvider(
                    create: (context) => _votingBloc(context, votingId),
                    child: VotingResultsCarouselScreen(),
                  );
                },
                settings: RouteSettings(name: settings.name));
          }

          if (settings.name
              .startsWith(RegExp(VotingProcessScreen.RouteWildcard))) {
            final match = RegExp(VotingProcessScreen.RouteWildcard)
                .firstMatch(settings.name);
            final eventId = int.parse(match.namedGroup('eventId'));
            final votingId = int.parse(match.namedGroup('votingId'));

            return MaterialPageRoute(
                builder: (context) {
                  return BlocProvider(
                    create: (context) => _votingBloc(context, votingId),
                    child: VotingProcessScreen(eventId: eventId),
                  );
                },
                settings: RouteSettings(name: settings.name));
          }

          if (settings.name
              .startsWith(RegExp(VotingProcessCandidateScreen.RouteWildcard))) {
            final match = RegExp(VotingProcessCandidateScreen.RouteWildcard)
                .firstMatch(settings.name);
            final eventId = int.parse(match.namedGroup('eventId'));
            final votingId = int.parse(match.namedGroup('votingId'));
            final candidateId = int.parse(match.namedGroup('candidateId'));
            print(candidateId);
            return MaterialPageRoute(
                builder: (context) {
                  return BlocProvider(
                    create: (context) {
                      return _votingBloc(context, votingId);
                    },
                    child:
                        VotingProcessCandidateScreen(candidateId: candidateId),
                  );
                },
                settings: RouteSettings(name: settings.name));
          }

          if (settings.name.startsWith(RegExp(
              r'^\/event\/(?<eventId>[\d+])\/votings\/(?<votingId>[\d+])\/(?<type>[\d+])'))) {
            final match = RegExp(
                    r'^\/event\/(?<eventId>[\d+])\/votings\/(?<votingId>[\d+])\/(?<humanType>[\d+])')
                .firstMatch(settings.name);
            final eventId = int.parse(match.namedGroup('eventId'));
            final votingId = int.parse(match.namedGroup('votingId'));
            final humanType =
                HumanList.values[int.parse(match.namedGroup('humanType'))];

            return MaterialPageRoute(
                builder: (context) {
                  return BlocProvider(
                    create: (context) {
                      return _votingBloc(context)
                        ..add(VotingLoadEvent(votingId: votingId));
                    },
                    child: VotingHumanListScreen(
                        eventId: eventId, humanType: humanType),
                  );
                },
                settings: RouteSettings(name: settings.name));
          }

          if (settings.name
              .startsWith(RegExp(r'\/event\/(?<eventId>[\d+])\/votings'))) {
            final match =
                RegExp(r'^\/event\/(?<id>[\d+])').firstMatch(settings.name);
            final eventId = int.parse(match.namedGroup('id'));

            return MaterialPageRoute(
                builder: (context) => VotingListScreen(eventId: eventId),
                settings: RouteSettings(name: settings.name));
          }

          if (settings.name.startsWith(RegExp(r'\/event\/(?<id>[\d+])'))) {
            final match =
                RegExp(r'^\/event\/(?<id>[\d+])').firstMatch(settings.name);
            final id = int.parse(match.namedGroup('id'));

            return MaterialPageRoute(
                builder: (context) => EventViewScreen(id: id),
                settings: RouteSettings(name: settings.name));
          }

          return MaterialPageRoute(
              builder: (context) => HomeScreen(),
              settings: RouteSettings(name: settings.name));
        },
      ),
    );
  }
}
