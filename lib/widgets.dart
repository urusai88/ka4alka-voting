import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ka4alka_voting/constants.dart';
import 'package:ka4alka_voting/domain.dart';

import 'blocs/blocs.dart';

class LoadingPageWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: CircularProgressIndicator());
  }
}

class RefereeWidget extends StatefulWidget {
  final Human referee;
  final Human candidate;
  final int vote;
  final bool readOnly;

  RefereeWidget({
    @required this.referee,
    @required this.candidate,
    this.vote,
    this.readOnly = false,
    Key key,
  })  : assert(referee != null),
        assert(candidate != null),
        super(key: key);

  @override
  State createState() => RefereeWidgetState();
}

class RefereeWidgetState extends State<RefereeWidget> {
  TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(
        text: '${widget.vote == null ? '' : widget.vote}');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey)),
              ),
              child: Row(
                children: <Widget>[
                  if (widget.referee.image is ImageSourceBase64)
                    FittedBox(
                      fit: BoxFit.fitHeight,
                      child: CircleAvatar(
                        backgroundImage: MemoryImage(
                            (widget.referee.image as ImageSourceBase64)
                                .toByteArray()),
                      ),
                    ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        widget.referee.title,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              child: TextField(
                controller: _controller,
                textAlign: TextAlign.center,
                readOnly: widget.readOnly,
                decoration: InputDecoration(border: InputBorder.none),
                style: voteValueStyle,
                keyboardType: TextInputType.number,
                inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  int v = int.tryParse(value);

                  if (v != null) {
                    BlocProvider.of<VotingBloc>(context).add(
                      VotingVoteEvent(
                        candidate: widget.candidate,
                        referee: widget.referee,
                        value: v,
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
