import 'dart:convert';

import 'package:flight_app/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class Service extends ChangeNotifier {
  static Service instance = Service();
  BluetoothConnection connection;

  void setConnection(BluetoothConnection connection) {
    this.connection = connection;
    this.notifyListeners();
  }

  bool sendPositionCommand(COMMAND command, int position) {
    if (this.connection != null && this.connection.isConnected) {
      this.connection.output.add(utf8.encode("${command.index}$position\n"));
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
      this.connection.output.add(utf8.encode(
          "${COMMAND.LEFT_WING.index}$leftWingPos\n${COMMAND.RIGHT_WING.index}$rightWingPos\n${COMMAND.THROTTLE.index}$throttlePos\n"));
      return true;
    }
    return false;
  }

  bool sendRightJoystickCommand(double x, double y) {
    if (this.connection != null && this.connection.isConnected) {
      int rudderPos = _mapJoystickValToRange(x, 50, 130).toInt();
      int flapsPos = _mapJoystickValToRange(y, 50, 130).toInt();
      this.connection.output.add(utf8.encode(
          "${COMMAND.RUDDER.index}$rudderPos\n${COMMAND.FLAPS.index}$flapsPos\n"));
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
}
