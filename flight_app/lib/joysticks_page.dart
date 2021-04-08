import 'dart:math';

import 'package:flight_app/service.dart';
import 'package:flutter/material.dart';

import 'package:control_pad/control_pad.dart';
import 'package:flutter/services.dart';

class JoysticksPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _JoystickPageState();
  }
}

class _JoystickPageState extends State<JoysticksPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  Point getPointFromDegDist(double deg, double dist) {
    double rad = deg * 0.0174533;

    return Point(dist * cos(rad), dist * sin(rad) * -1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Joystick Control'),
      ),
      body: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            JoystickView(
              onDirectionChanged: (deg, dist) {
                Point p = getPointFromDegDist(deg, dist);

                Service.instance.sendLeftJoystickCommand(
                    p.y, p.x); //flip x/y because landscape orientation
              },
              interval: Duration(milliseconds: 500),
            ),
            JoystickView(
              onDirectionChanged: (deg, dist) {
                Point p = getPointFromDegDist(deg, dist);

                Service.instance.sendRightJoystickCommand(
                    p.y, p.x); //flip x/y because landscape orientation
              },
              interval: Duration(milliseconds: 500),
            ),
          ],
        ),
      ),
    );
  }
}
