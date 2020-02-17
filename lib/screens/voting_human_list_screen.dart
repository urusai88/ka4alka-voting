import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ka4alka_voting/blocs/blocs.dart';
import 'package:ka4alka_voting/domain.dart';
import 'package:ka4alka_voting/widgets.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

class VotingHumanListScreen extends StatelessWidget {
  final int eventId;
  final HumanList humanType;

  VotingHumanListScreen({@required this.eventId, @required this.humanType});

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

            return _Body(voting: votingState.voting);
          }

          return LoadingPageWidget();
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final Voting voting;

  _Body({@required this.voting});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _UpperContainer(),
      ],
    );
  }
}

class _UpperContainer extends StatefulWidget {
  @override
  State createState() => _UpperContainerState();
}

class _UpperContainerState extends State<_UpperContainer> {
  TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,
      child: SizedBox.expand(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Имя',
                ),
              ),
            ),
            InkWell(
              onTap: () {},
              child: AspectRatio(
                aspectRatio: 1,
                child: Center(child: Icon(Icons.add)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
