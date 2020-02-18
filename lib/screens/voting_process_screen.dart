import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ka4alka_voting/blocs/blocs.dart';
import 'package:ka4alka_voting/extensions.dart';
import 'package:ka4alka_voting/widgets.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

class VotingProcessScreen extends StatelessWidget {
  static const RouteWildcard =
      r'^\/events\/(?<eventId>[\d]+)\/votings\/(?<votingId>[\d]+)\/process$';

  final int eventId;

  VotingProcessScreen({@required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Голосование: список'),
      ),
      body: StreamBuilder<Tuple2<ApplicationState, VotingState>>(
        stream: Rx.combineLatest2(
          BlocProvider.of<ApplicationBloc>(context),
          BlocProvider.of<VotingBloc>(context),
          (a, b) => Tuple2(a, b),
        ),
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              snapshot.data.item1 is ApplicationLoaded &&
              snapshot.data.item2 is VotingLoadedState) {
            final applicationState = snapshot.data.item1 as ApplicationLoaded;
            final votingState = snapshot.data.item2 as VotingLoadedState;

            final voting = votingState.voting;
            final humans = applicationState.humans
                .whereKeyFn((key) => voting.candidateIds.contains(key))
                .values
                .toList();

            return Column(
              children: <Widget>[
                Container(
                  height: 75,
                  child: voting.isVotingCompleted
                      ? FlatButton(
                          onPressed: () =>
                              BlocProvider.of<ScreenBloc>(context).add(
                            VotingResultsCarouselScreenEvent(
                                eventId: eventId, votingId: voting.id),
                          ),
                          child: Text('По порядку'),
                        )
                      : Tooltip(
                          message: 'Голосование ещё не окончено',
                          child: FlatButton(
                            onPressed: () {},
                            child: Text('По порядку'),
                          ),
                        ),
                ),
                Expanded(
                  child: ListView.builder(itemBuilder: (context, index) {
                    if (!humans.hasIndex(index)) return null;

                    final human = humans[index];

                    return ListTile(
                      title: Row(
                        children: [
                          Text(human.title),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: voting.votes
                                  .where((vote) => vote.candidateId == human.id)
                                  .where((vote) => vote.value != null)
                                  .map((vote) => Text('${vote.value}'))
                                  .cast<Widget>()
                                  .insert(Row(
                                    children: <Widget>[
                                      Text(' ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      Icon(Icons.add),
                                      Text(' ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ))
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                      trailing: InkWell(
                        onTap: () {
                          BlocProvider.of<ScreenBloc>(context).add(
                            VotingProcessCandidateScreenEvent(
                                eventId: eventId,
                                votingId: voting.id,
                                candidateId: human.id),
                          );
                        },
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Icon(Icons.chevron_right),
                        ),
                      ),
                    );
                  }),
                )
              ],
            );
          }

          return LoadingPageWidget();
        },
      ),
    );
  }
}
