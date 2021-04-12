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
            servo: SERVO.THROTTLE,
            initialPos: 0,
          ),
          _Incrementer(
            servo: SERVO.LEFT_WING,
            initialPos: 90,
          ),
          _Incrementer(
            servo: SERVO.RIGHT_WING,
            initialPos: 90,
          ),
          _Incrementer(
            servo: SERVO.RUDDER,
            initialPos: 90,
          ),
          _Incrementer(
            servo: SERVO.ELEVATOR,
            initialPos: 90,
          ),
        ]),
      ),
    );
  }
}

class _Incrementer extends StatefulWidget {
  final SERVO servo;
  final int initialPos;
  final int step;
  final int min;
  final int max;
  _Incrementer({
    this.servo,
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
        Text(widget.servo.toString().split(".")[1]),
        ElevatedButton.icon(
          onPressed: () {
            setState(() {
              pos += widget.step;
              pos = pos.clamp(widget.min, widget.max);
            });

            Service.instance.sendPositionCommand(widget.servo, pos);
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
            Service.instance.sendPositionCommand(widget.servo, pos);
          },
          icon: Icon(Icons.remove),
          label: Text("Dec"),
        ),
      ],
    );
  }
}
