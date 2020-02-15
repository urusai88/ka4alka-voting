import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ka4alka_voting/blocs/application/application.dart';
import 'package:ka4alka_voting/domain.dart';
import 'package:ka4alka_voting/widgets.dart';

final voteValueStyle =
    const TextStyle(fontWeight: FontWeight.bold, fontSize: 112);

class VotingProcessScreen extends StatelessWidget {
  final Voting voting;
  final int candidateId;

  VotingProcessScreen({@required this.voting, @required this.candidateId})
      : assert(voting != null),
        assert(candidateId != null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocBuilder<ApplicationBloc, ApplicationState>(
        builder: (context, state) {
          if (state is ApplicationLoaded)
            return _VotingProcessScreenBody(
              voting: voting,
              candidateId: candidateId,
              humans: state.humans,
            );

          return LoadingPageWidget();
        },
      ),
    );
  }
}

class _VotingProcessScreenBody extends StatelessWidget {
  final Voting voting;
  final int candidateId;
  final Map<int, Human> humans;

  _VotingProcessScreenBody(
      {@required this.voting,
      @required this.candidateId,
      @required this.humans})
      : assert(voting != null),
        assert(candidateId != null),
        assert(humans != null);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: _UpperContainer(candidate: humans[candidateId]),
        ),
        Expanded(child: _MiddleContainer()),
        // Expanded(),
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
            children: <Widget>[
              Text('Голосование за'),
              Text(candidate.title),
            ],
          ),
        );
      },
    );
  }
}

class _MiddleContainer extends StatelessWidget {
  final Voting voting;
  final Map<int, Human> humans;

  _MiddleContainer({@required this.voting, @required this.humans})
      : assert(voting != null),
        assert(humans != null);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[],
    );
  }
}
