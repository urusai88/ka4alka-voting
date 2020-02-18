import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ka4alka_voting/blocs/blocs.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListener<ScreenBloc, ScreenState>(
      listener: (context, state) {
        final navigator = Navigator.of(context);

        if (state is EventListScreenState) navigator.pushNamed('/events');
        if (state is EventViewScreenState)
          navigator.pushNamed('/events/${state.id}');
        if (state is VotingListScreenState)
          navigator.pushNamed('/events/${state.eventId}/votings');
        if (state is VotingEditScreenState)
          navigator.pushNamed(
              '/events/${state.eventId}/votings/${state.votingId}/edit');
        if (state is VotingHumanListScreenState)
          navigator.pushNamed(
              '/events/${state.eventId}/votings/${state.votingId}/${state.type.index}');
        if (state is VotingProcessScreenState)
          navigator.pushNamed(
            '/events/${state.eventId}/votings/${state.votingId}/process',
          );
        if (state is VotingProcessCandidateScreenState)
          navigator.pushNamed(
            '/events/${state.eventId}/votings/${state.votingId}/process/${state.candidateId}',
          );
        if (state is VotingResultsCarouselScreenState)
          navigator.pushNamed(
              '/events/${state.eventId}/votings/${state.votingId}/process/carousel');
      },
      child: Scaffold(
        appBar: AppBar(),
        body: Container(
          child: Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  color: Colors.blue,
                  child: SizedBox.expand(
                    child: FlatButton(
                      onPressed: () {
                        BlocProvider.of<ScreenBloc>(context)
                            .add(EventListScreenEvent());
                      },
                      child: Text('События'),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
