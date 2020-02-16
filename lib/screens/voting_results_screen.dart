import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ka4alka_voting/blocs/blocs.dart';
import 'package:ka4alka_voting/extensions.dart';
import 'package:ka4alka_voting/widgets.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

class VotingResultsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
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

            if (!voting.isVotingCompleted) {
              return Center(child: Text('Голосование ещё не окончено'));
            } else {
              final results = voting.getResult();

              return Column(
                children: <Widget>[
                  Container(
                    height: 75,
                    child: FlatButton(
                      onPressed: () => BlocProvider.of<ScreenBloc>(context).add(
                        VotingResultsCarouselScreenEvent(voting: voting),
                      ),
                      child: Text('По порядку'),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(itemBuilder: (context, index) {
                      if (!results.hasIndex(index)) return null;

                      final result = results[index];

                      return ListTile(
                        title: Text(
                            applicationState.humans[result.candidateId].title),
                        trailing: Text(result.value.toString(),
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      );
                    }),
                  )
                ],
              );
            }
          }

          return LoadingPageWidget();
        },
      ),
    );
  }
}
