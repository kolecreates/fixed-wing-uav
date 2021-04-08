import 'package:flight_app/constants.dart';
import 'package:flight_app/service.dart';
import 'package:flutter/material.dart';

class IncrementerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Incrementer'),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        children: List.from([
          _Incrementer(
            command: COMMAND.THROTTLE,
            initialPos: 0,
          ),
          _Incrementer(
            command: COMMAND.LEFT_WING,
            initialPos: 90,
          ),
          _Incrementer(
            command: COMMAND.RIGHT_WING,
            initialPos: 90,
          ),
          _Incrementer(
            command: COMMAND.RUDDER,
            initialPos: 90,
          ),
          _Incrementer(
            command: COMMAND.FLAPS,
            initialPos: 90,
          ),
        ]),
      ),
    );
  }
}

class _Incrementer extends StatefulWidget {
  final COMMAND command;
  final int initialPos;
  final int step;
  final int min;
  final int max;
  _Incrementer({
    this.command,
    this.initialPos,
    this.step = 5,
    this.min = 0,
    this.max = 180,
  });
  @override
  State<StatefulWidget> createState() {
    return _IncrementerState();
  }
}

class _IncrementerState extends State<_Incrementer> {
  int pos = 0;
  @override
  void initState() {
    super.initState();
    pos = widget.initialPos;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(widget.command.toString().split(".")[1]),
        ElevatedButton.icon(
          onPressed: () {
            setState(() {
              pos += widget.step;
              pos = pos.clamp(widget.min, widget.max);
            });

            Service.instance.sendPositionCommand(widget.command, pos);
          },
          icon: Icon(Icons.add),
          label: Text("Inc"),
        ),
        Text(this.pos.toString()),
        ElevatedButton.icon(
          onPressed: () {
            setState(() {
              pos -= widget.step;
              pos = pos.clamp(widget.min, widget.max);
            });
            Service.instance.sendPositionCommand(widget.command, pos);
          },
          icon: Icon(Icons.remove),
          label: Text("Dec"),
        ),
      ],
    );
  }
}
