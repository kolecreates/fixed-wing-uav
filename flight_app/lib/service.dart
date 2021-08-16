import 'dart:async';
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
            DateTime.now().millisecondsSinceEpoch - _lastSend >= 333) {
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

  void rollLeft() {
    var rw = _servoPositions[SERVO.RIGHT_WING];
    var trimmed = (rw - ROLL_TRIM).clamp(WING_POS_MIN, WING_POS_MAX);
    if (trimmed != rw) {
      _servoPositions[SERVO.RIGHT_WING] = trimmed;
      _servoPositions[SERVO.LEFT_WING] = trimmed;
      _servoPositions[SERVO.RUDDER] = 90 + ROLL_RUDDER_TRIM;
      _shouldSendNextTick = true;
    }
  }

  void rollRight() {
    var lw = _servoPositions[SERVO.LEFT_WING];
    var trimmed = (lw + ROLL_TRIM).clamp(WING_POS_MIN, WING_POS_MAX);
    if (trimmed != lw) {
      _servoPositions[SERVO.LEFT_WING] = trimmed;
      _servoPositions[SERVO.RIGHT_WING] = trimmed;
      _servoPositions[SERVO.RUDDER] = 90 - ROLL_RUDDER_TRIM;
      _shouldSendNextTick = true;
    }
  }

  void pitchUp() {
    var e = _servoPositions[SERVO.ELEVATOR];
    var trimmed = (e - PITCH_TRIM).clamp(ELEVATOR_POS_MIN, ELEVATOR_POS_MAX);
    if (trimmed != e) {
      _servoPositions[SERVO.ELEVATOR] = trimmed;
      _shouldSendNextTick = true;
    }
  }

  void pitchDown() {
    var e = _servoPositions[SERVO.ELEVATOR];
    var trimmed = (e + PITCH_TRIM).clamp(ELEVATOR_POS_MIN, ELEVATOR_POS_MAX);
    if (trimmed != e) {
      _servoPositions[SERVO.ELEVATOR] = trimmed;
      _shouldSendNextTick = true;
    }
  }

  void throttleUp() {
    var t = _servoPositions[SERVO.THROTTLE];
    var trimmed = (t + THROTTLE_TRIM).clamp(THROTTLE_MIN, THROTTLE_MAX);
    if (trimmed != t) {
      _servoPositions[SERVO.THROTTLE] = trimmed;
      _shouldSendNextTick = true;
    }
  }

  void throttleDown() {
    var t = _servoPositions[SERVO.THROTTLE];
    var trimmed = (t - THROTTLE_TRIM).clamp(THROTTLE_MIN, THROTTLE_MAX);
    if (trimmed != t) {
      _servoPositions[SERVO.THROTTLE] = trimmed;
      _shouldSendNextTick = true;
    }
  }

  void takeoff() {
    _servoPositions[SERVO.THROTTLE] = THROTTLE_MAX;
    _servoPositions[SERVO.LEFT_WING] = 90;
    _servoPositions[SERVO.RIGHT_WING] = 90;
    _servoPositions[SERVO.RUDDER] = 90;
    _servoPositions[SERVO.ELEVATOR] = 90;
    _wingTrim = FLAP_TRIM;
    _shouldSendNextTick = true;
  }

  void cruise() {
    _servoPositions[SERVO.THROTTLE] = CRUISE_THROTTLE;
    _wingTrim = 0;
    _shouldSendNextTick = true;
  }

  void land() {
    _servoPositions[SERVO.THROTTLE] = THROTTLE_MIN;
    _wingTrim = FLAP_TRIM;
    _shouldSendNextTick = true;
  }
}
