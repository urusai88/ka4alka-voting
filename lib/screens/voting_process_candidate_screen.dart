import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ka4alka_voting/blocs/blocs.dart';
import 'package:ka4alka_voting/constants.dart';
import 'package:ka4alka_voting/domain.dart';
import 'package:ka4alka_voting/widgets.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

class VotingProcessCandidateScreen extends StatelessWidget {
  static const RouteWildcard =
      r'^\/events\/([\d]+)\/votings\/([\d]+)\/process\/([\d]+)';

  final int candidateId;

  VotingProcessCandidateScreen({@required this.candidateId});

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
            final applicationState = snapshot.data.item1 as ApplicationLoaded,
                votingState = snapshot.data.item2 as VotingLoadedState;

            return Provider(
              create: (_) => applicationState,
              child: _VotingProcessScreenBody(
                voting: votingState.voting,
                candidate: applicationState.humans[candidateId],
              ),
            );
          }

          return LoadingPageWidget();
        },
      ),
    );
  }
}

class _VotingProcessScreenBody extends StatelessWidget {
  final Voting voting;
  final Human candidate;

  _VotingProcessScreenBody({@required this.voting, @required this.candidate})
      : assert(voting != null),
        assert(candidate != null);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: _UpperContainer(candidate: candidate),
        ),
        Expanded(
          child: _MiddleContainer(
            voting: voting,
            candidate: candidate,
          ),
        ),
        Expanded(
          child: _LowerContainer(
            voting: voting,
            candidate: candidate,
          ),
        ),
      ],
    );
  }
}

class _UpperContainer extends StatelessWidget {
  final Human candidate;

  _UpperContainer({@required this.candidate}) : assert(candidate != null);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ApplicationBloc, ApplicationState>(
      builder: (context, state) {
        return Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(candidate.title, style: voteValueStyle),
            ],
          ),
        );
      },
    );
  }
}

class _MiddleContainer extends StatelessWidget {
  final Voting voting;
  final Human candidate;

  _MiddleContainer({@required this.voting, @required this.candidate})
      : assert(voting != null),
        assert(candidate != null);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      child: Table(
        border: TableBorder.all(color: Colors.grey),
        children: [
          TableRow(
            children: voting.refereeIds.map((refereeId) {
              final referee = BlocProvider.of<ApplicationBloc>(context)
                  .repository
                  .getHuman(refereeId);

              return RefereeWidget(
                referee: referee,
                candidate: candidate,
                vote: voting.getVote(candidate.id, refereeId).value,
              );
            }).toList(),
          )
        ],
      ),
    );
  }
}

class _LowerContainer extends StatelessWidget {
  final Voting voting;
  final Human candidate;

  _LowerContainer({@required this.voting, @required this.candidate});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        if (voting.isVoteCompleted(candidate.id)) {
          return Column(
            children: <Widget>[
              Text(
                'Итоговый счёт',
                style: TextStyle(fontSize: 40),
              ),
              Text(
                voting.getComputedVote(candidate.id).toString(),
                style: voteValueStyle,
              )
            ],
          );
        }

        return Container();
      },
    );
  }
}
