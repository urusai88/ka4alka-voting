import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ka4alka_voting/blocs/blocs.dart';
import 'package:ka4alka_voting/domain.dart';
import 'package:ka4alka_voting/utils.dart';
import 'package:ka4alka_voting/widgets.dart';

final voteValueStyle =
const TextStyle(fontWeight: FontWeight.bold, fontSize: 60);

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
        Expanded(
          child: _MiddleContainer(
            voting: voting,
            humans: humans,
          ),
        ),
        Expanded(child: Container()),
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
  final Map<int, Human> humans;

  _MiddleContainer({@required this.voting, @required this.humans})
      : assert(voting != null),
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
              child: _RefereeWidget(referee: humans[refereeId]),
            );
          }).toList(),
        ).toList(),
      ),
    );
  }
}

class _RefereeWidget extends StatefulWidget {
  final Human referee;
  final int vote;

  _RefereeWidget({@required this.referee, this.vote}) : assert(referee != null);

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

                  if (v != null)
                    BlocProvider.of<VotingBloc>(context).add(
                      VotingVoteEvent(
                          candidate: null, referee: null, value: null),
                    );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
