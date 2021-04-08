import 'dart:math';

import 'package:flight_app/service.dart';
import 'package:flutter/material.dart';

import 'package:control_pad/control_pad.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

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
      DeviceOrientation.landscapeLeft,
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

    return Point(dist * cos(rad), dist * sin(rad));
  }

  @override
  Widget build(BuildContext context) {
    var service = Provider.of<Service>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Menu'),
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          JoystickView(
            onDirectionChanged: (deg, dist) {
              Point p = getPointFromDegDist(deg, dist);

              service.sendLeftJoystickCommand(p.x, p.y);
            },
            interval: Duration(milliseconds: 250),
          ),
          JoystickView(
            onDirectionChanged: (deg, dist) {
              Point p = getPointFromDegDist(deg, dist);

              service.sendRightJoystickCommand(p.x, p.y);
            },
            interval: Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }
}
