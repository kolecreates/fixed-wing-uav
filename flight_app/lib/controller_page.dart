import 'package:flight_app/constants.dart';
import 'package:flight_app/service.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:joystick/joystick.dart';

class ControllerPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ControllerPageState();
  }
}

class _ControllerPageState extends State<ControllerPage> {
  double circleSize = 175;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Controller'),
      ),
      body: Container(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: this.circleSize,
                  height: this.circleSize,
                  child: Joystick(
                    size: this.circleSize,
                    isDraggable: false,
                    backgroundColor: Colors.black,
                    iconColor: Colors.white,
                    joystickMode: JoystickModes.vertical,
                    onUpPressed: () {
                      Service.instance.throttleUp();
                    },
                    onDownPressed: () {
                      Service.instance.throttleDown();
                    },
                  ),
                ),
                IconButton(
                    icon: Icon(Icons.flight_takeoff),
                    onPressed: () {
                      Service.instance.takeoff();
                    }),
                IconButton(
                    icon: Icon(Icons.flight),
                    onPressed: () {
                      Service.instance.cruise();
                    }),
                IconButton(
                    icon: Icon(Icons.flight_land),
                    onPressed: () {
                      Service.instance.land();
                    }),
                Container(
                  width: this.circleSize,
                  height: this.circleSize,
                  child: Joystick(
                    size: this.circleSize,
                    isDraggable: false,
                    backgroundColor: Colors.black,
                    iconColor: Colors.white,
                    joystickMode: JoystickModes.all,
                    onUpPressed: () {
                      Service.instance.pitchUp();
                    },
                    onDownPressed: () {
                      Service.instance.pitchDown();
                    },
                    onLeftPressed: () {
                      Service.instance.rollLeft();
                    },
                    onRightPressed: () {
                      Service.instance.rollRight();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
