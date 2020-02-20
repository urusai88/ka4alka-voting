import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
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
                : 'Список судей')),
        body: StreamBuilder<Tuple2<ApplicationState, VotingState>>(
            stream: Rx.combineLatest2(BlocProvider.of<ApplicationBloc>(context),
                BlocProvider.of<VotingBloc>(context), (a, b) => Tuple2(a, b)),
            builder: (context, snapshot) {
              if (snapshot.hasData &&
                  snapshot.data.item1 is ApplicationLoaded &&
                  snapshot.data.item2 is VotingLoadedState) {
                final applicationState =
                    snapshot.data.item1 as ApplicationLoaded;
                final votingState = snapshot.data.item2 as VotingLoadedState;

                return MultiProvider(providers: [
                  Provider(create: (_) => applicationState),
                  Provider(create: (_) => votingState),
                  Provider(create: (_) => humanType)
                ], child: _Body(voting: votingState.voting));
              }

              return LoadingPageWidget();
            }));
  }
}

class _Body extends StatefulWidget {
  final Voting voting;

  _Body({@required this.voting});

  @override
  State createState() => _BodyState();
}

class _BodyState extends State<_Body> with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
        vsync: this, value: 1.0, duration: Duration(milliseconds: 250));
    _animation =
        Tween<Offset>(begin: const Offset(0, 0), end: const Offset(1, 0))
            .animate(_animationController);
  }

  @override
  Widget build(BuildContext context) {
    final humanType = Provider.of<HumanList>(context, listen: false);
    final list = widget.voting.getHumanList(humanType);

    return Stack(children: <Widget>[
      Column(children: <Widget>[
        _UpperContainer(
            onOpenCopy: () => _animationController.reverse(),
            voting: widget.voting,
            humanType: humanType),
        Expanded(child: ListView.builder(itemBuilder: (context, index) {
          if (!list.hasIndex(index)) return null;

          return BlocProvider(
              key: ValueKey('human.${list[index]}'),
              create: (context) => HumanBloc(
                  applicationBloc: BlocProvider.of<ApplicationBloc>(context))
                ..add(HumanLoadEvent(id: list[index])),
              child: _ListTile(
                  key: ValueKey('humant.${list[index]}'),
                  humanId: list[index],
                  humanType: humanType));
        })),
      ]),
      Align(
          alignment: Alignment.centerRight,
          child: SlideTransition(
              position: _animation,
              child: FractionallySizedBox(
                  widthFactor: 0.5,
                  child: BlocProvider(
                      create: (context) {
                        return VotingListBloc(
                            applicationBloc:
                                BlocProvider.of<ApplicationBloc>(context))
                          ..add(VotingListLoadEvent());
                      },
                      child: _CopyFrom(
                          voting: widget.voting,
                          onClose: () => _animationController.forward())))))
    ]);
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
                        try {
                          final base64 = await getFile();
                          final response =
                              await http.post('/image', body: base64);

                          /// Имя файла. Например: 12313613.jpg
                          final contents =
                              utf8.decoder.convert(response.bodyBytes);
                          state.human.image = ImageSource.fromString(contents);

                          BlocProvider.of<HumanBloc>(context)
                              .add(HumanUpdateEvent(human: state.human));
                        } catch (e) {
                          print(e);
                        }
                      },
                      child: AspectRatio(
                          aspectRatio: 1,
                          child: Builder(
                              builder: (context) =>
                                  state.human.getAvatarWidget())))),
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
                    BlocProvider.of<VotingBloc>(context).add(VotingRemoveHuman(
                        humanId: state.human.id, humanType: widget.humanType));
                  },
                  child:
                      AspectRatio(aspectRatio: 1, child: Icon(Icons.delete))));
        }

        return ListTile();
      },
    );
  }
}

class _UpperContainer extends StatefulWidget {
  final Voting voting;
  final HumanList humanType;
  final VoidCallback onOpenCopy;

  _UpperContainer(
      {@required this.humanType,
      @required this.voting,
      @required this.onOpenCopy});

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
                child: Container(
                    padding: EdgeInsets.all(10),
                    child: TextField(
                        autofocus: true,
                        focusNode: _focusNode,
                        controller: _controller,
                        decoration: InputDecoration(hintText: 'Имя')))),
            InkWell(
                onTap: () {
                  final input = _controller.text.trim();

                  if (input.isEmpty) return;

                  BlocProvider.of<VotingBloc>(context).add(
                      VotingAddHumanByNameEvent(
                          name: input, type: widget.humanType));

                  _controller.text = '';
                  FocusScope.of(context).requestFocus(_focusNode);
                },
                child: AspectRatio(
                    aspectRatio: 1, child: Center(child: Icon(Icons.add)))),
            Tooltip(
                message: 'Скопировать из другой номинации',
                child: InkWell(
                    onTap: () => widget.onOpenCopy?.call(),
                    child: AspectRatio(
                        aspectRatio: 1,
                        child: Center(child: Icon(Icons.content_copy)))))
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

class _CopyFrom extends StatelessWidget {
  final Voting voting;
  final VoidCallback onClose;

  _CopyFrom({@required this.voting, @required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border(left: BorderSide(color: Colors.grey))),
        child: Material(
            child: Column(children: <Widget>[
          Container(
              height: 75,
              alignment: Alignment.center,
              child: Row(children: [
                InkWell(
                    onTap: () => onClose?.call(),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Icon(Icons.close),
                    )),
                Text('Скопировать из: ')
              ])),
          Expanded(child: BlocBuilder<VotingListBloc, VotingListState>(
              builder: (context, state) {
            if (state is VotingListLoadedState) {
              final votingList = state.votings.values
                  .where((element) => element.id != voting.id)
                  .toList();

              return ListView.separated(
                  itemCount: votingList.length,
                  separatorBuilder: (context, index) => Divider(),
                  itemBuilder: (context, index) {
                    if (!votingList.hasIndex(index)) return null;

                    return _CopyFromTile(voting: votingList[index]);
                  });
            }

            return LoadingPageWidget();
          }))
        ])));
  }
}

class _CopyFromTile extends StatefulWidget {
  final Voting voting;

  _CopyFromTile({@required this.voting});

  @override
  State createState() => _CopyFromTileState();
}

class _CopyFromTileState extends State<_CopyFromTile> {
  bool isOpen = false;

  @override
  Widget build(BuildContext context) {
    final humanType = Provider.of<HumanList>(context, listen: false);

    return Column(children: <Widget>[
      ListTile(
          title: Text(widget.voting.title),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
            Tooltip(
                message: 'Скопировать всех',
                child: InkWell(
                    onTap: () => BlocProvider.of<VotingBloc>(context)
                      ..add(VotingCopyHuman(
                          votingId: widget.voting.id,
                          humanType:
                              Provider.of<HumanList>(context, listen: false))),
                    child: AspectRatio(
                        aspectRatio: 1, child: Icon(Icons.content_copy)))),
            Tooltip(
                message: 'Развернуть',
                child: InkWell(
                    onTap: () => setState(() => isOpen = !isOpen),
                    child: AspectRatio(
                        aspectRatio: 1,
                        child: Icon(isOpen
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down))))
          ])),
      if (isOpen)
        BlocProvider(
            create: (context) => VotingHumanListBloc(
                applicationBloc: BlocProvider.of<ApplicationBloc>(context))
              ..add(VotingHumanListLoadEvent(
                  keys: widget.voting.getHumanList(humanType))),
            child: BlocBuilder<VotingHumanListBloc, VotingHumanListState>(
                builder: (context, state) {
              if (state is VotingHumanListLoadedState) {
                final humanList = state.humans.values.toList();

                return Container(
                    padding: EdgeInsets.only(left: 25),
                    child: Column(
                      children: humanList.map((human) {
                        return ListTile(
                            leading: human.getAvatarWidget(),
                            title: Text(human.title),
                            trailing: Tooltip(
                                message: 'Скопировать',
                                child: InkWell(
                                    onTap: () {
                                      BlocProvider.of<VotingBloc>(context).add(
                                          VotingAddHumanByIdEvent(
                                              id: human.id,
                                              type: Provider.of<HumanList>(
                                                  context,
                                                  listen: false)));
                                    },
                                    child: AspectRatio(
                                        aspectRatio: 1,
                                        child: Icon(Icons.content_copy)))));
                      }).toList(),
                    ));
              }

              return LoadingPageWidget();
            }))
    ]);
  }
}
