import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ka4alka_voting/blocs/blocs.dart';
import 'package:ka4alka_voting/domain.dart';
import 'package:ka4alka_voting/extensions.dart';
import 'package:ka4alka_voting/widgets.dart';

class EventListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Список мероприятий'),
      ),
      body: BlocBuilder<ApplicationBloc, ApplicationState>(
        builder: (context, state) {
          if (state is ApplicationLoaded) {
            final eventList = state.events.values.toList();

            return Column(
              children: <Widget>[
                Container(
                  height: 75,
                  child: SizedBox.expand(
                    child: FlatButton(
                      onPressed: () {
                        BlocProvider.of<ApplicationBloc>(context)
                            .add(EventCreateEvent());
                      },
                      child: Icon(Icons.add),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      if (!eventList.hasIndex(index)) return null;
                      final event = eventList[index];
                      return _EventListBody(
                        key: ValueKey('event.list.${event.id}'),
                        event: event,
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

class _EventListBody extends StatefulWidget {
  final Event event;

  _EventListBody({Key key, @required this.event}) : super(key: key);

  @override
  State createState() => _EventListBodyState();
}

class _EventListBodyState extends State<_EventListBody> {
  TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(text: widget.event.title);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: TextField(
        controller: _controller,
        decoration: InputDecoration(hintText: 'Название'),
        onChanged: (value) {
          widget.event.title = value;

          BlocProvider.of<ApplicationBloc>(context)
              .add(EventUpdateEvent(event: widget.event));
        },
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          InkWell(
            onTap: () {
              BlocProvider.of<ApplicationBloc>(context).add(
                EventDeleteEvent(event: widget.event),
              );
            },
            child: AspectRatio(
              aspectRatio: 1,
              child: Icon(Icons.delete),
            ),
          ),
          Tooltip(
            message: 'К номинациям',
            child: InkWell(
              onTap: () {
                BlocProvider.of<ScreenBloc>(context).add(
                  VotingListScreenEvent(eventId: widget.event.id),
                );
              },
              child: AspectRatio(
                aspectRatio: 1,
                child: Icon(Icons.chevron_right),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
