import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ka4alka_voting/blocs/blocs.dart';
import 'package:ka4alka_voting/extensions.dart';
import 'package:ka4alka_voting/widgets.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

class VotingEditScreen extends StatelessWidget {
  final int eventId;
  final int votingId;

  VotingEditScreen({@required this.eventId, @required this.votingId});

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

            return ListView(
              children: <Widget>[
                ListTile(
                  title: Text('Список участников'),
                  trailing: InkWell(
                    onTap: () {},
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Container(
                          height: constraints.maxHeight,
                          width: constraints.maxHeight,
                          child: Icon(Icons.chevron_right),
                        );
                      },
                    ),
                  ),
                ),
                ListTile(
                  title: Text('Список судей'),
                  trailing: InkWell(
                    onTap: () {},
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Container(
                          height: constraints.maxHeight,
                          width: constraints.maxHeight,
                          child: Icon(Icons.chevron_right),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          }

          return LoadingPageWidget();
        },
      ),
    );

    return Scaffold(
      appBar: AppBar(),
      body: BlocBuilder<ApplicationBloc, ApplicationState>(
        builder: (context, appState) {
          if (appState is ApplicationLoaded) {
            return BlocBuilder<VotingBloc, VotingState>(
              builder: (context, votingState) {
                if (votingState is VotingLoadedState) {
                  return Container(
                    child: Row(
                      children: <Widget>[
                        _Column(
                          color: Colors.blue,
                          header: Text('Участники'),
                          body: ListView.builder(
                            itemBuilder: (context, index) {
                              if (!votingState.voting.candidateIds
                                  .hasIndex(index)) return null;

                              final human = appState.humans[
                                  votingState.voting.candidateIds[index]];

                              return ListTile(
                                title: Text(human.title),
                                trailing: InkWell(
                                  onTap: () {
                                    BlocProvider.of<VotingBloc>(context).add(
                                      VotingRemoveCandidateEvent(human: human),
                                    );
                                  },
                                  child: Icon(Icons.chevron_right),
                                ),
                              );
                            },
                          ),
                        ),
                        _Column(
                          header: Text('Все люди'),
                          body: ListView.builder(
                            itemBuilder: (context, index) {
                              final humans = appState.humans.values.toList();

                              if (!humans.hasIndex(index)) return null;

                              final human = humans[index];

                              return ListTile(
                                leading: InkWell(
                                  onTap: () {
                                    BlocProvider.of<VotingBloc>(context).add(
                                      VotingAddCandidateEvent(human: human),
                                    );
                                  },
                                  child: Icon(Icons.chevron_left),
                                ),
                                title: _HumanTitle(
                                  title: human.title,
                                  isCandidate: votingState.voting.candidateIds
                                      .contains(human.id),
                                  isReferee: votingState.voting.refereeIds
                                      .contains(human.id),
                                ),
                                trailing: InkWell(
                                  onTap: () {
                                    BlocProvider.of<VotingBloc>(context).add(
                                      VotingAddRefereeEvent(human: human),
                                    );
                                  },
                                  child: Icon(Icons.chevron_right),
                                ),
                              );
                            },
                          ),
                        ),
                        _Column(
                          color: Colors.red,
                          header: Text('Судьи'),
                          body: ListView.builder(
                            itemBuilder: (context, index) {
                              if (!votingState.voting.refereeIds
                                  .hasIndex(index)) return null;

                              final human = appState
                                  .humans[votingState.voting.refereeIds[index]];

                              return ListTile(
                                leading: InkWell(
                                  onTap: () {
                                    BlocProvider.of<VotingBloc>(context).add(
                                      VotingRemoveRefereeEvent(human: human),
                                    );
                                  },
                                  child: Icon(Icons.chevron_left),
                                ),
                                title: Text(human.title),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return LoadingPageWidget();
              },
            );
          }

          return LoadingPageWidget();
        },
      ),
    );
  }
}

class _Column extends StatelessWidget {
  final Widget header;
  final Widget body;
  final Color color;

  _Column({@required this.header, @required this.body, this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: color,
        child: Column(
          children: <Widget>[header, Expanded(child: body)],
        ),
      ),
    );
  }
}

class _HumanTitle extends StatelessWidget {
  final String title;
  final bool isCandidate;
  final bool isReferee;

  _HumanTitle(
      {@required this.title, this.isCandidate = false, this.isReferee = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(title),
        Spacer(),
        if (isCandidate) Container(width: 12, height: 12, color: Colors.blue),
        if (isReferee) Container(width: 12, height: 12, color: Colors.red)
      ],
    );
  }
}
