import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ka4alka_voting/blocs/blocs.dart';
import 'package:ka4alka_voting/domain.dart';
import 'package:ka4alka_voting/extensions.dart';
import 'package:ka4alka_voting/widgets.dart';

class VotingListScreen extends StatelessWidget {
  static const RouteWildcard = r'\/events\/(?<eventId>[\d]+)\/votings';

  final int eventId;

  VotingListScreen({@required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocBuilder<ApplicationBloc, ApplicationState>(
        builder: (context, state) {
          if (state is ApplicationLoaded) {
            final event = state.events[eventId];
            final votingList = state.votings
                .whereKeyFn((key) => event.votingIds.contains(key))
                .values
                .toList();

            return Column(
              children: <Widget>[
                Container(
                  height: 75,
                  child: SizedBox.expand(
                    child: FlatButton(
                      onPressed: () {
                        BlocProvider.of<ApplicationBloc>(context)
                            .add(VotingCreateEvent(eventId: eventId));
                      },
                      child: Icon(Icons.add),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      if (!votingList.hasIndex(index)) return null;
                      final voting = votingList[index];
                      return _VotingListBody(
                        key: ValueKey('voting.list.${voting.id}'),
                        voting: voting,
                        eventId: eventId,
                      );
                    },
                  ),
                ),
              ],
            );
          }

          return LoadingPageWidget();
        },
      ),
    );
  }
}

class _VotingListBody extends StatefulWidget {
  final int eventId;
  final Voting voting;

  _VotingListBody({Key key, @required this.voting, @required this.eventId})
      : super(key: key);

  @override
  _VotingListBodyState createState() => _VotingListBodyState();
}

class _VotingListBodyState extends State<_VotingListBody> {
  TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(text: widget.voting.title);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: TextField(
        controller: _controller,
        decoration: InputDecoration(hintText: 'Название'),
        onChanged: (value) {
          widget.voting.title = value;

          BlocProvider.of<ApplicationBloc>(context)
              .add(VotingUpdateEvent(voting: widget.voting));
        },
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Tooltip(
            message: 'Участники',
            child: InkWell(
              onTap: () {
                BlocProvider.of<ScreenBloc>(context).add(
                  VotingHumanListScreenEvent(
                    eventId: widget.eventId,
                    votingId: widget.voting.id,
                    type: HumanList.Candidate,
                  ),
                );
              },
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    height: constraints.maxHeight,
                    width: constraints.maxHeight,
                    child: Icon(Icons.people, color: Colors.blue),
                  );
                },
              ),
            ),
          ),
          Tooltip(
            message: 'Судьи',
            child: InkWell(
              onTap: () {
                BlocProvider.of<ScreenBloc>(context).add(
                  VotingHumanListScreenEvent(
                    eventId: widget.eventId,
                    votingId: widget.voting.id,
                    type: HumanList.Referee,
                  ),
                );
              },
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    height: constraints.maxHeight,
                    width: constraints.maxHeight,
                    child: Icon(Icons.people, color: Colors.red),
                  );
                },
              ),
            ),
          ),
          InkWell(
            onTap: () {
              BlocProvider.of<ApplicationBloc>(context).add(
                VotingDeleteEvent(voting: widget.voting),
              );
            },
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  height: constraints.maxHeight,
                  width: constraints.maxHeight,
                  child: Icon(Icons.delete),
                );
              },
            ),
          ),
          Tooltip(
            message: 'К голосованию',
            child: InkWell(
              onTap: () {
                BlocProvider.of<ScreenBloc>(context).add(
                  VotingProcessScreenEvent(
                      eventId: widget.eventId, votingId: widget.voting.id),
                );
              },
              child: Container(
                padding: EdgeInsets.all(10),
                child: Icon(Icons.chevron_right),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
