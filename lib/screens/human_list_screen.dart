import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ka4alka_voting/blocs/application/application.dart';
import 'package:ka4alka_voting/domain.dart';
import 'package:ka4alka_voting/html/file_picker.dart';
import 'package:ka4alka_voting/widgets.dart';

class HumanListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: <Widget>[
          Container(
            height: 75,
            child: SizedBox.expand(
              child: FlatButton(
                onPressed: () {
                  BlocProvider.of<ApplicationBloc>(context)
                      .add(HumanCreateEvent());
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
                    final humans = state.humans.values.toList();

                    return ListView.builder(
                      itemBuilder: (context, index) {
                        try {
                          return _HumanRow(
                              key: UniqueKey(), human: humans[index]);
                        } on RangeError catch (e) {
                          return null;
                        }
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
    );
  }
}

class _HumanRow extends StatefulWidget {
  final Human human;

  _HumanRow({@required this.human, Key key}) : super(key: key);

  @override
  _HumanRowState createState() => _HumanRowState();
}

class _HumanRowState extends State<_HumanRow> {
  TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(text: widget.human.title);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        child: InkWell(
          onTap: () async {
            var base64 = await getFile();
            if (base64.startsWith('data:'))
              base64 = base64.substring(base64.indexOf(',') + 1);

            widget.human.image = ImageSourceBase64(base64: base64);

            BlocProvider.of<ApplicationBloc>(context)
                .add(HumanUpdateEvent(human: widget.human));
          },
          child: Builder(
            builder: (context) {
              if (widget.human.image is ImageSourceBase64) {
                try {
                  return Image.memory(base64.decode(
                      (widget.human.image as ImageSourceBase64).base64));
                } catch (e) {
                  print(e);
                }
              }

              return Icon(Icons.photo_camera);
            },
          ),
        ),
      ),
      title: TextField(
        controller: _controller,
        onChanged: (value) {
          widget.human.title = value;

          BlocProvider.of<ApplicationBloc>(context)
              .add(HumanUpdateEvent(human: widget.human));
        },
      ),
      trailing: InkWell(
        onTap: () {
          BlocProvider.of<ApplicationBloc>(context)
              .add(HumanDeleteEvent(human: widget.human));
        },
        child: Icon(Icons.delete),
      ),
    );
  }
}
