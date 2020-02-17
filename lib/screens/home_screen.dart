import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ka4alka_voting/blocs/blocs.dart';
import 'package:ka4alka_voting/screens/screens.dart';

class HomeScreen extends StatelessWidget {
  VotingBloc _createVotingBloc(BuildContext context, {int votingId}) {
    final bloc =
        VotingBloc(applicationBloc: BlocProvider.of<ApplicationBloc>(context));

    if (votingId != null) bloc.add(VotingLoadEvent(votingId: votingId));

    return bloc;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ScreenBloc, ScreenState>(
      listener: (context, state) {
        if (state is HumanListScreenState)
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => HumanListScreen()));

        if (state is VotingListScreenState)
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => VotingListScreen()));

        if (state is VotingScreenState)
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (context) => VotingBloc(
                  applicationBloc: BlocProvider.of<ApplicationBloc>(context),
                )..add(VotingLoadEvent(votingId: state.votingId)),
                child: VotingScreen(),
              ),
            ),
          );

        if (state is VotingProcessScreenState)
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (context) => VotingBloc(
                  applicationBloc: BlocProvider.of<ApplicationBloc>(context),
                )..add(VotingLoadEvent(votingId: state.voting.id)),
                child: VotingProcessScreen(candidateId: state.candidate.id),
              ),
            ),
          );

        if (state is VotingResultsScreenState)
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (context) =>
                    _createVotingBloc(context, votingId: state.votingId),
                child: VotingResultsScreen(),
              ),
            ),
          );

        if (state is VotingResultsCarouselScreenState)
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (context) =>
                    _createVotingBloc(context, votingId: state.votingId),
                child: VotingResultsCarouselScreen(),
              ),
            ),
          );
      },
      child: Scaffold(
        appBar: AppBar(),
        body: Container(
          color: Colors.red,
          child: Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  color: Colors.blue,
                  child: SizedBox.expand(
                    child: FlatButton(
                      onPressed: () {
                        BlocProvider.of<ScreenBloc>(context)
                            .add(HumanListScreenEvent());
                      },
                      child: Text('Люди'),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.green,
                  child: SizedBox.expand(
                    child: FlatButton(
                      onPressed: () {
                        BlocProvider.of<ScreenBloc>(context)
                            .add(VotingListScreenEvent());
                      },
                      child: Text('Голосования'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
