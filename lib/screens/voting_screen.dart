import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ka4alka_voting/blocs/application/application.dart';
import 'package:ka4alka_voting/blocs/blocs.dart';
import 'package:ka4alka_voting/blocs/voting/voting.dart';
import 'package:ka4alka_voting/domain.dart';
import 'package:ka4alka_voting/extensions.dart';
import 'package:ka4alka_voting/widgets.dart';

class VotingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocBuilder<ApplicationBloc, ApplicationState>(
        builder: (context, appState) {
          if (appState is ApplicationLoaded) {
            return BlocBuilder<VotingBloc, VotingState>(
              builder: (context, votingState) {
                if (votingState is VotingLoadedState) {
                  return _VotingList(
                    applicationState: appState,
                    votingState: votingState,
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

class _VotingList extends StatelessWidget {
  final ApplicationLoaded applicationState;
  final VotingLoadedState votingState;

  _VotingList({@required this.applicationState, @required this.votingState})
      : assert(applicationState != null),
        assert(votingState != null);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        if (!votingState.voting.candidateIds.hasIndex(index)) return null;

        final humanId = votingState.voting.candidateIds[index];
        final human = applicationState.humans[humanId];

        return _VotingTile(voting: votingState.voting, human: human);
      },
    );
  }
}

class _VotingTile extends StatelessWidget {
  final Human human;
  final Voting voting;

  _VotingTile({@required this.human, @required this.voting})
      : assert(human != null),
        assert(voting != null);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(human.title),
      trailing: InkWell(
        onTap: () {
          BlocProvider.of<ScreenBloc>(context).add(
            VotingProcessScreenEvent(voting: voting, candidate: human),
          );
        },
        child: Icon(Icons.chevron_right),
      ),
    );
  }
}
