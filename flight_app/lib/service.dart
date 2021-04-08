import 'dart:async';
import 'dart:convert';

import 'package:flight_app/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class Service extends ChangeNotifier {
  static Service instance = Service();
  BluetoothConnection connection;
  Timer _pingTimer;

  void setConnection(BluetoothConnection connection) {
    this.connection = connection;
    _resetPingTimer();
  }

  bool sendPositionCommand(COMMAND command, int position) {
    if (this.connection != null && this.connection.isConnected) {
      _resetPingTimer();
      this.connection.output.add(utf8.encode("${command.index}$position\n"));
      return true;
    } else {
      return false;
    }
  }

  bool sendLeftJoystickCommand(double x, double y) {
    if (this.connection != null && this.connection.isConnected) {
      _resetPingTimer();
      int leftWingPos = _mapJoystickValToRange(x, 50, 130).toInt();
      int rightWingPos = _mapJoystickValToRange(x, 130, 50).toInt();
      this.connection.output.add(utf8.encode(
          "${COMMAND.LEFT_WING.index}$leftWingPos\n${COMMAND.RIGHT_WING.index}$rightWingPos\n"));
      return true;
    }
    return false;
  }

  bool sendRightJoystickCommand(double x, double y) {
    if (this.connection != null && this.connection.isConnected) {
      _resetPingTimer();
      int rudderPos = _mapJoystickValToRange(x, 50, 130).toInt();
      int flapsPos = _mapJoystickValToRange(y, 50, 130).toInt();
      this.connection.output.add(utf8.encode(
          "${COMMAND.RUDDER.index}$rudderPos\n${COMMAND.FLAPS.index}$flapsPos\n"));
      return true;
    }
    return false;
  }

  void sendPingCommand() {
    if (this.connection != null && this.connection.isConnected) {
      this.connection.output.add(utf8.encode("${COMMAND.PING.index}0\n"));
      _resetPingTimer();
    }
  }

  num _mapJoystickValToRange(num x, num min, num max) {
    return min + ((max - min) * _normalize(x.clamp(-1, 1), -1, 1));
  }

  num _normalize(num x, num min, num max) {
    return (x - min) / (max - min);
  }

  void _resetPingTimer() {
    if (_pingTimer != null && _pingTimer.isActive) {
      _pingTimer.cancel();
    }
    _pingTimer = Timer(Duration(milliseconds: 2000), sendPingCommand);
  }
}
