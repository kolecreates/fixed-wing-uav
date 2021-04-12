import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flight_app/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class Service extends ChangeNotifier {
  static Service instance = Service();
  BluetoothConnection connection;
  bool _shouldSendNextTick = false;
  int _lastSend = 0;
  int _wingTrim = 0;
  Map<SERVO, int> _servoPositions = {
    SERVO.THROTTLE: 0,
    SERVO.LEFT_WING: 90,
    SERVO.RIGHT_WING: 90,
    SERVO.RUDDER: 90,
    SERVO.ELEVATOR: 90,
  };

  void setConnection(BluetoothConnection connection) {
    this.connection = connection;
    Timer.periodic(Duration(milliseconds: 33), (timer) {
      if (this.connection != null && this.connection.isConnected) {
        if (_shouldSendNextTick ||
            DateTime.now().millisecondsSinceEpoch - _lastSend > 250) {
          this.connection.output.add(Uint8List.fromList([
                _servoPositions[SERVO.THROTTLE],
                (_servoPositions[SERVO.LEFT_WING] + _wingTrim)
                    .clamp(WING_POS_MIN, WING_POS_MAX),
                (_servoPositions[SERVO.RIGHT_WING] - _wingTrim)
                    .clamp(WING_POS_MIN, WING_POS_MAX),
                _servoPositions[SERVO.RUDDER],
                _servoPositions[SERVO.ELEVATOR],
              ]));
          _shouldSendNextTick = false;
          _lastSend = DateTime.now().millisecondsSinceEpoch;
        }
      } else {
        timer.cancel();
      }
    });
  }

  void sendPositionCommand(SERVO servo, int position) {
    if (_servoPositions[servo] != position) {
      _servoPositions[servo] = position;
      _shouldSendNextTick = true;
    }
  }

  void sendLeftJoystickCommand(double x, double y) {
    int wingPos = _mapJoystickToServoPos(x * -1, WING_POS_MIN, WING_POS_MAX);
    sendPositionCommand(SERVO.LEFT_WING, wingPos);
    sendPositionCommand(SERVO.RIGHT_WING, wingPos);
  }

  void sendRightJoystickCommand(double x, double y) {
    int rudderPos = _mapJoystickToServoPos(y, 30, 150);
    int elevatorPos = _mapJoystickToServoPos(x * -1, 20, 160);
    sendPositionCommand(SERVO.RUDDER, rudderPos);
    sendPositionCommand(SERVO.ELEVATOR, elevatorPos);
  }

  void setWingTrim(double normal) {
    _wingTrim = (normal * 70).toInt();
    _shouldSendNextTick = true;
  }

  int _mapJoystickToServoPos(double x, int min, int max) {
    double normal = _normalize(x.clamp(-1, 1), -1, 1);
    double inRange = min + ((max - min) * normal);
    return _roundToInterval(inRange, MIN_SERVO_STEP);
  }

  double _normalize(double x, double min, double max) {
    return (x - min) / (max - min);
  }

  int _roundToInterval(double x, int interval) {
    return (x / interval).round() * interval;
  }
}
