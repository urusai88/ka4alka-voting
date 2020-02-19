import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ka4alka_voting/blocs/blocs.dart';
import 'package:ka4alka_voting/constants.dart';
import 'package:ka4alka_voting/domain.dart';
import 'package:ka4alka_voting/extensions.dart';
import 'package:ka4alka_voting/widgets.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

class VotingProcessCandidateScreen extends StatelessWidget {
  static const RouteWildcard =
      r'^\/events\/(?<eventId>[\d]+)\/votings\/(?<votingId>[\d]+)\/process\/(?<candidateId>[\d]+)';

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
      decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
      child: Row(
        children: voting.refereeIds
            .map((refereeId) {
              final referee = BlocProvider.of<ApplicationBloc>(context)
                  .repository
                  .getHuman(refereeId);

              return Expanded(
                child: _RefereeWidget(
                  referee: referee,
                  candidate: candidate,
                  vote: voting.getVote(candidate.id, refereeId).value,
                ),
              );
            })
            .cast<Widget>()
            .insert(VerticalDivider())
            .toList(),
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

class _RefereeWidget extends StatefulWidget {
  final Human referee;
  final Human candidate;
  final int vote;

  _RefereeWidget(
      {@required this.referee, @required this.candidate, this.vote, Key key})
      : assert(referee != null),
        assert(candidate != null),
        super(key: key);

  @override
  State createState() => _RefereeWidgetState();
}

class _RefereeWidgetState extends State<_RefereeWidget> {
  TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(
        text: '${widget.vote == null ? '' : widget.vote}');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey)),
              ),
              child: Row(
                children: <Widget>[
                  if (widget.referee.image is ImageSourceBase64)
                    CircleAvatar(
                        backgroundImage: MemoryImage(
                            (widget.referee.image as ImageSourceBase64)
                                .toByteArray())),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        widget.referee.title,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              child: TextField(
                controller: _controller,
                textAlign: TextAlign.center,
                decoration: InputDecoration(border: InputBorder.none),
                style: voteValueStyle,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  WhitelistingTextInputFormatter.digitsOnly,
                  MaxMinInputFormatter(),
                ],
                onChanged: (value) {
                  value = value.trim();

                  if (value == '') {
                    BlocProvider.of<VotingBloc>(context).add(
                      VotingVoteEvent(
                        candidate: widget.candidate,
                        referee: widget.referee,
                        value: null,
                      ),
                    );
                  } else {
                    int v = int.tryParse(value);

                    if (v != null) {
                      BlocProvider.of<VotingBloc>(context).add(
                        VotingVoteEvent(
                          candidate: widget.candidate,
                          referee: widget.referee,
                          value: v,
                        ),
                      );
                    }
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MaxMinInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    try {
      int v = int.parse(newValue.text);

      return newValue.copyWith(text: '${math.min(math.max(1, v), 15)}');
    } on FormatException catch (e) {}

    return newValue;
  }
}
