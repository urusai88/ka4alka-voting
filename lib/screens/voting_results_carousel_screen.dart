import 'package:flutter/material.dart';
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

class VotingResultsCarouselScreen extends StatelessWidget {
  static const RouteWildcard =
      r'^\/events\/([\d]+)\/votings\/([\d]+)\/process\/carousel';

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
            if (snapshot.hasData &&
                snapshot.data.item1 is ApplicationLoaded &&
                snapshot.data.item2 is VotingLoadedState) {
              final applicationState = snapshot.data.item1 as ApplicationLoaded;
              final votingState = snapshot.data.item2 as VotingLoadedState;

              if (votingState.voting.isVotingCompleted) {
                return MultiProvider(
                  providers: [
                    Provider<ApplicationLoaded>(
                        create: (_) => applicationState),
                    Provider<VotingLoadedState>(create: (_) => votingState),
                  ],
                  child: _Body(voting: votingState.voting),
                );
              } else {
                return Center(child: Text('Голосование ещё не окончено'));
              }
            }
          }

          return LoadingPageWidget();
        },
      ),
    );
  }
}

class _Body extends StatefulWidget {
  final Voting voting;

  _Body({@required this.voting});

  @override
  State createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  int index;
  List<VoteResult> result;

  @override
  void initState() {
    super.initState();

    index = 0;
    result = widget.voting.getResult();
  }

  @override
  Widget build(BuildContext context) {
    final applicationState = Provider.of<ApplicationLoaded>(context);
    final votingState = Provider.of<VotingLoadedState>(context);
    final candidateId = result[index].candidateId;
    final place = result.length - index;

    return Row(
      children: <Widget>[
        Expanded(
          child: InkWell(
            onTap: () {
              if (index > 0) setState(() => index--);
            },
            child: Container(
              // color: Colors.blue,
              child: Center(child: Icon(Icons.chevron_left)),
            ),
          ),
        ),
        Expanded(
          flex: 10,
          child: _MiddleContainer(
            voting: votingState.voting,
            candidateId: candidateId,
            place: place,
          ),
        ),
        Expanded(
          child: InkWell(
            onTap: () {
              if (result.hasIndex(index + 1)) setState(() => index++);
            },
            child: Container(
              // color: Colors.green,
              child: Center(child: Icon(Icons.chevron_right)),
            ),
          ),
        ),
      ],
    );
  }
}

class _MiddleContainer extends StatelessWidget {
  final Voting voting;
  final int candidateId;
  final int place;

  _MiddleContainer(
      {@required this.voting,
      @required this.candidateId,
      @required this.place});

  @override
  Widget build(BuildContext context) {
    final candidate =
        Provider.of<ApplicationLoaded>(context).humans[candidateId];

    return _MiddleContainerBody(
      voting: voting,
      candidate: candidate,
      place: place,
    );
  }
}

class _MiddleContainerBody extends StatelessWidget {
  final Voting voting;
  final Human candidate;
  final int place;

  _MiddleContainerBody(
      {@required this.voting, @required this.candidate, @required this.place})
      : assert(voting != null),
        assert(candidate != null),
        assert(place != null);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(child: _UpperSubContainer(candidate: candidate, place: place)),
        Expanded(
          child: _MiddleSubContainer(
            voting: voting,
            candidate: candidate,
          ),
        ),
        Expanded(
          child: _LowerSubContainer(
            voting: voting,
            candidate: candidate,
          ),
        ),
      ],
    );
  }
}

class _UpperSubContainer extends StatelessWidget {
  final Human candidate;
  final int place;

  _UpperSubContainer({@required this.candidate, @required this.place})
      : assert(candidate != null),
        assert(place != null);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ApplicationBloc, ApplicationState>(
      builder: (context, state) {
        return Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('$place место', style: voteValueStyle),
              Text(candidate.title, style: voteValueStyle),
            ],
          ),
        );
      },
    );
  }
}

class _MiddleSubContainer extends StatelessWidget {
  final Voting voting;
  final Human candidate;

  _MiddleSubContainer({@required this.voting, @required this.candidate});

  @override
  Widget build(BuildContext context) {
    return _MiddleSubContainerTile(
      voting: voting,
      candidate: candidate,
      refereeList: Provider.of<ApplicationLoaded>(context)
          .humans
          .whereKeyFn((key) => voting.refereeIds.contains(key))
          .values
          .toList(),
    );
  }
}

class _MiddleSubContainerTile extends StatelessWidget {
  final Voting voting;
  final Human candidate;
  final List<Human> refereeList;

  _MiddleSubContainerTile(
      {@required this.voting,
      @required this.candidate,
      @required this.refereeList});

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

class _LowerSubContainer extends StatelessWidget {
  final Voting voting;
  final Human candidate;

  _LowerSubContainer({@required this.voting, @required this.candidate});

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
