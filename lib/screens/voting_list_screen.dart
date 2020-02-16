import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ka4alka_voting/blocs/blocs.dart';
import 'package:ka4alka_voting/blocs/voting/voting.dart';
import 'package:ka4alka_voting/domain.dart';
import 'package:ka4alka_voting/extensions.dart';
import 'package:ka4alka_voting/screens/screens.dart';
import 'package:ka4alka_voting/widgets.dart';

class VotingListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListener<ScreenBloc, ScreenState>(
      listener: (context, state) {
        if (state is VotingEditScreenState)
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return BlocProvider<VotingBloc>(
                  create: (context) => VotingBloc(
                    applicationBloc: BlocProvider.of<ApplicationBloc>(context),
                  )..add(VotingLoadEvent(votingId: state.votingId)),
                  child: VotingEditScreen(),
                );
              },
            ),
          );
      },
      child: Scaffold(
        appBar: AppBar(),
        body: Column(
          children: <Widget>[
            Container(
              height: 75,
              child: SizedBox.expand(
                child: FlatButton(
                  onPressed: () {
                    BlocProvider.of<ApplicationBloc>(context)
                        .add(VotingCreateEvent());
                  },
                  child: Icon(Icons.add),
                ),
              ),
            ),
            Expanded(
              child: Container(
                child: BlocBuilder<ApplicationBloc, ApplicationState>(
                  builder: (context, state) {
                    if (state is ApplicationLoaded) {
                      final keys = state.votings.keys.toList();

                      return ListView.builder(
                        itemBuilder: (context, index) {
                          if (!keys.hasIndex(index)) return null;

                          return _VotingRow(voting: state.votings[keys[index]]);
                        },
                      );
                    }

                    return LoadingPageWidget();
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _VotingRow extends StatefulWidget {
  final Voting voting;

  _VotingRow({@required this.voting});

  @override
  _VotingRowState createState() => _VotingRowState();
}

class _VotingRowState extends State<_VotingRow> {
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
          InkWell(
            onTap: () {
              BlocProvider.of<ScreenBloc>(context).add(
                VotingEditingScreenEvent(votingId: widget.voting.id),
              );
            },
            child: Container(
              padding: EdgeInsets.all(10),
              child: Icon(Icons.edit),
            ),
          ),
          InkWell(
            onTap: () {
              BlocProvider.of<ApplicationBloc>(context).add(
                VotingDeleteEvent(voting: widget.voting),
              );
            },
            child: Container(
              padding: EdgeInsets.all(10),
              child: Icon(Icons.delete),
            ),
          ),
          Tooltip(
            message: 'К голосованию',
            child: InkWell(
              onTap: () {
                BlocProvider.of<ScreenBloc>(context).add(
                  VotingScreenEvent(votingId: widget.voting.id),
                );
              },
              child: Container(
                padding: EdgeInsets.all(10),
                child: Icon(Icons.chevron_right),
              ),
            ),
          ),
          Tooltip(
            message: 'Списком в возрастающем порядке',
            child: InkWell(
              onTap: () {
                BlocProvider.of<ScreenBloc>(context).add(
                  VotingResultsScreenEvent(voting: widget.voting),
                );
              },
              child: Container(
                padding: EdgeInsets.all(10),
                child: Icon(Icons.show_chart),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
