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
                      Service.instance.sendCommand(COMMAND.THROTTLE_UP);
                    },
                    onDownPressed: () {
                      Service.instance.sendCommand(COMMAND.THROTTLE_DOWN);
                    },
                  ),
                ),
                IconButton(
                    icon: Icon(Icons.flight_takeoff),
                    onPressed: () {
                      Service.instance.sendCommand(COMMAND.TAKE_OFF);
                    }),
                IconButton(
                    icon: Icon(Icons.flight),
                    onPressed: () {
                      Service.instance.sendCommand(COMMAND.CRUISE);
                    }),
                IconButton(
                    icon: Icon(Icons.flight_land),
                    onPressed: () {
                      Service.instance.sendCommand(COMMAND.LAND);
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
                      Service.instance.sendCommand(COMMAND.PITCH_UP);
                    },
                    onDownPressed: () {
                      Service.instance.sendCommand(COMMAND.PITCH_DOWN);
                    },
                    onLeftPressed: () {
                      Service.instance.sendCommand(COMMAND.ROLL_LEFT);
                    },
                    onRightPressed: () {
                      Service.instance.sendCommand(COMMAND.ROLL_RIGHT);
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
