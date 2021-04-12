import 'package:flight_app/constants.dart';
import 'package:flight_app/joystick_view.dart';
import 'package:flight_app/service.dart';
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Joystick Control'),
      ),
      body: Container(
        child: Column(
          children: [
            _WingTrimSlider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                JoystickView(
                  onDirectionChanged: (p) {
                    Service.instance.sendLeftJoystickCommand(p.dx, p.dy * -1);
                  },
                ),
                JoystickView(
                  onDirectionChanged: (p) {
                    Service.instance.sendRightJoystickCommand(p.dx, p.dy * -1);
                  },
                ),
              ],
            ),
            _ThrottleSlider(),
          ],
        ),
      ),
    );
  }
}

class _WingTrimSlider extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WingTrimSliderState();
  }
}

class _WingTrimSliderState extends State<_WingTrimSlider> {
  double value = 0;
  @override
  Widget build(BuildContext context) {
    return Slider(
        value: this.value,
        onChanged: (newValue) {
          setState(() {
            value = newValue;
          });
        },
        onChangeEnd: (endValue) {
          Service.instance.setWingTrim(value);
        });
  }
}

class _ThrottleSlider extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ThrottleSliderState();
  }
}

class _ThrottleSliderState extends State<_ThrottleSlider> {
  double value = 0;
  @override
  Widget build(BuildContext context) {
    return Slider(
        min: 0,
        max: 180,
        value: this.value,
        onChanged: (newValue) {
          setState(() {
            value = newValue;
          });
        },
        onChangeEnd: (endValue) {
          Service.instance
              .sendPositionCommand(SERVO.THROTTLE, value.clamp(0, 180).toInt());
        });
  }
}
