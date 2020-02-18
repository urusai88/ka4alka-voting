import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:ka4alka_voting/blocs/blocs.dart';
import 'package:ka4alka_voting/domain.dart';
import 'package:ka4alka_voting/extensions.dart';
import 'package:ka4alka_voting/html/file_picker.dart';
import 'package:ka4alka_voting/widgets.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

class VotingHumanListScreen extends StatelessWidget {
  static const RouteWildcard =
      r'^\/events\/(?<eventId>[\d]+)\/votings\/(?<votingId>[\d]+)\/(?<humanType>[\d]+)';
  final int eventId;
  final HumanList humanType;

  VotingHumanListScreen({@required this.eventId, @required this.humanType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(humanType == HumanList.Candidate
            ? 'Список участников'
            : 'Список судей'),
      ),
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

            return MultiProvider(
              providers: [
                Provider(create: (_) => applicationState),
                Provider(create: (_) => votingState),
              ],
              child: _Body(voting: votingState.voting, humanType: humanType),
            );
          }

          return LoadingPageWidget();
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final Voting voting;
  final HumanList humanType;

  _Body({@required this.voting, @required this.humanType});

  @override
  Widget build(BuildContext context) {
    final list = humanType == HumanList.Candidate
        ? voting.candidateIds
        : voting.refereeIds;

    return Column(
      children: <Widget>[
        _UpperContainer(voting: voting, humanType: humanType),
        Expanded(
          child: ListView.builder(
            itemBuilder: (context, index) {
              if (!list.hasIndex(index)) return null;

              return BlocProvider(
                key: ValueKey('human.${list[index]}'),
                create: (context) => HumanBloc(
                    applicationBloc: BlocProvider.of<ApplicationBloc>(context))
                  ..add(HumanLoadEvent(id: list[index])),
                child: _ListTile(
                  key: ValueKey('humant.${list[index]}'),
                  humanId: list[index],
                  humanType: humanType,
                ),
              );

              return _ListTile(humanId: list[index], humanType: humanType);
            },
          ),
        ),
      ],
    );
  }
}

class _ListTile extends StatefulWidget {
  // final Human human;
  final int humanId;
  final HumanList humanType;

  _ListTile({Key key, @required this.humanId, @required this.humanType})
      : assert(humanId != null),
        assert(humanType != null),
        super(key: key);

  @override
  State createState() => _ListTileState();
}

class _ListTileState extends State<_ListTile> {
  TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HumanBloc, HumanState>(
      builder: (context, state) {
        if (state is HumanLoadedState) {
          if (_controller.text.isEmpty) _controller.text = state.human.title;

          return ListTile(
            leading: Container(
              child: InkWell(
                onTap: () async {
                  state.human.image = ImageSource.fromString(await getFile());

                  BlocProvider.of<HumanBloc>(context)
                      .add(HumanUpdateEvent(human: state.human));
                },
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Builder(
                    builder: (context) {
                      if (state.human.image is ImageSourceBase64) {
                        try {
                          return Image.memory(base64.decode(
                              (state.human.image as ImageSourceBase64).base64));
                        } catch (e) {
                          print(e);
                        }
                      }

                      return Icon(Icons.photo_camera);
                    },
                  ),
                ),
              ),
            ),
            title: TextField(
              controller: _controller,
              onChanged: (value) {
                state.human.title = value;

                BlocProvider.of<HumanBloc>(context)
                    .add(HumanUpdateEvent(human: state.human));
              },
            ),
            trailing: InkWell(
              onTap: () {
                BlocProvider.of<VotingBloc>(context).add(
                  VotingRemoveHuman(
                      humanId: state.human.id, humanType: widget.humanType),
                );
              },
              child: AspectRatio(
                aspectRatio: 1,
                child: Icon(Icons.delete),
              ),
            ),
          );
        }

        return ListTile();
      },
    );
  }
}

class _UpperContainer extends StatefulWidget {
  final Voting voting;
  final HumanList humanType;

  _UpperContainer({@required this.humanType, @required this.voting});

  @override
  State createState() => _UpperContainerState();
}

class _UpperContainerState extends State<_UpperContainer> {
  TextEditingController _controller;
  FocusNode _focusNode;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,
      child: SizedBox.expand(
        child: Row(
          children: [
            Expanded(
              child: TypeAheadField(
                textFieldConfiguration: TextFieldConfiguration(
                  autofocus: true,
                  focusNode: _focusNode,
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Имя',
                  ),
                ),
                suggestionsCallback: (pattern) async {
                  print(pattern);
                  return null;
                },
                itemBuilder: (context, suggestion) {
                  return null;
                },
                onSuggestionSelected: (suggestion) {},
              ),
              /*
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Имя',
                ),
              ),
              */
            ),
            InkWell(
              onTap: () {
                final input = _controller.text.trim();

                if (input.isEmpty) return;

                BlocProvider.of<VotingBloc>(context).add(
                  VotingAddHumanByNameEvent(
                    name: input,
                    type: widget.humanType,
                  ),
                );

                _controller.text = '';
                FocusScope.of(context).requestFocus(_focusNode);
              },
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

  @override
  void dispose() {
    super.dispose();

    _focusNode.dispose();
  }
}
