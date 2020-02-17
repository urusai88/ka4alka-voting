import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ka4alka_voting/blocs/blocs.dart';
import 'package:ka4alka_voting/constants.dart';
import 'package:ka4alka_voting/domain.dart';
import 'package:ka4alka_voting/utils.dart';
import 'package:ka4alka_voting/widgets.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

class VotingProcessScreen extends StatelessWidget {
  final int candidateId;

  VotingProcessScreen({@required this.candidateId})
      : assert(candidateId != null);

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
          if (snapshot.hasData) {
            final data = snapshot.data;
            final applicationState = data.item1, votingState = data.item2;

            if (applicationState is ApplicationLoaded &&
                votingState is VotingLoadedState) {
              return _VotingProcessScreenBody(
                  voting: votingState.voting,
                  candidate: applicationState.humans[candidateId],
                  humans: applicationState.humans);
            }
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
  final Map<int, Human> humans;

  _VotingProcessScreenBody(
      {@required this.voting, @required this.candidate, @required this.humans})
      : assert(voting != null),
        assert(candidate != null),
        assert(humans != null);

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
            humans: humans,
          ),
        ),
        Expanded(
          child: _LowerContainer(
            voting: voting,
            candidate: candidate,
            humans: humans,
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
  final Map<int, Human> humans;

  _MiddleContainer(
      {@required this.voting, @required this.candidate, @required this.humans})
      : assert(voting != null),
        assert(candidate != null),
        assert(humans != null),
        assert(() {
          voting.refereeIds.forEach((id) {
            if (!humans.containsKey(id)) {
              throw AssertionError(
                'Voting.refereeIds contains human id which missing in humans list',
              );
            }
          });
          return true;
        }());

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
      child: Row(
        children: insertDivider(
          voting.refereeIds.map((refereeId) {
            return Expanded(
              child: _RefereeWidget(
                referee: humans[refereeId],
                candidate: candidate,
                vote: voting.getVote(candidate.id, refereeId).value,
              ),
            );
          }).toList(),
        ).toList(),
      ),
    );
  }
}

class _LowerContainer extends StatelessWidget {
  final Voting voting;
  final Human candidate;
  final Map<int, Human> humans;

  _LowerContainer(
      {@required this.voting, @required this.candidate, @required this.humans});

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
                    FittedBox(
                      fit: BoxFit.fitHeight,
                      child: CircleAvatar(
                        backgroundImage: MemoryImage(
                            (widget.referee.image as ImageSourceBase64)
                                .toByteArray()),
                      ),
                    ),
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
                inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                onChanged: (value) {
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
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
