import 'dart:convert';

import 'package:flight_app/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class Service extends ChangeNotifier {
  BluetoothConnection connection;

  void setConnection(BluetoothConnection connection) {
    this.connection = connection;
    this.notifyListeners();
  }

  bool sendPositionCommand(COMMAND command, int position) {
    if (this.connection != null && this.connection.isConnected) {
      this.connection.output.add(_encodePositionCommand(command, position));
      return true;
    } else {
      return false;
    }
  }

  bool sendLeftJoystickCommand(double x, double y) {
    if (this.connection != null && this.connection.isConnected) {
      int leftWingPos = _mapJoystickValToRange(x, 50, 130).toInt();
      int rightWingPos = _mapJoystickValToRange(x, 130, 50).toInt();
      int throttlePos = _mapJoystickValToRange(y - 1, 0, 360)
          .toInt(); // force only upper half of joystick to control throttle
      List<int> data = _encodePositionCommand(COMMAND.LEFT_WING, leftWingPos);
      data.addAll(_encodePositionCommand(COMMAND.RIGHT_WING, rightWingPos));
      data.addAll(_encodePositionCommand(COMMAND.THROTTLE, throttlePos));
      this.connection.output.add(data);
      return true;
    }
    return false;
  }

  bool sendRightJoystickCommand(double x, double y) {
    if (this.connection != null && this.connection.isConnected) {
      int rudderPos = _mapJoystickValToRange(x, 50, 130).toInt();
      int flapsPos = _mapJoystickValToRange(y, 50, 130).toInt();
      List<int> data = _encodePositionCommand(COMMAND.RUDDER, rudderPos);
      data.addAll(_encodePositionCommand(COMMAND.FLAPS, flapsPos));
      this.connection.output.add(data);
      return true;
    }
    return false;
  }

  num _mapJoystickValToRange(num x, num min, num max) {
    return min + ((max - min) * _normalize(x.clamp(-1, 1), -1, 1));
  }

  num _normalize(num x, num min, num max) {
    return (x - min) / (max - min);
  }

  List<int> _encodePositionCommand(COMMAND command, int pos) {
    return utf8.encode("${command.index.toString()}${pos.toString()}\n");
  }
}
