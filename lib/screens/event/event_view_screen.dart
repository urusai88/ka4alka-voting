import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ka4alka_voting/blocs/blocs.dart';
import 'package:ka4alka_voting/widgets.dart';

class EventViewScreen extends StatelessWidget {
  static const RouteWildcard = r'\/events\/([\d+])';

  final int eventId;

  EventViewScreen({@required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocBuilder<ApplicationBloc, ApplicationState>(
        builder: (context, state) {
          if (state is ApplicationLoaded) {
            final event = state.events[eventId];

            return Column(
              children: <Widget>[
                Container(
                  alignment: Alignment.center,
                  height: 75,
                  child: Text(event.title),
                ),
                Expanded(
                  child: ListView(
                    children: <Widget>[
                      ListTile(
                        title: Text('Список номинаций'),
                        trailing: InkWell(
                          onTap: () {
                            BlocProvider.of<ScreenBloc>(context).add(
                              VotingListScreenEvent(eventId: event.id),
                            );
                          },
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return Container(
                                height: constraints.maxHeight,
                                width: constraints.maxHeight,
                                child: Icon(Icons.chevron_right),
                              );
                            },
                          ),
                        ),
                      )
                    ],
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
