import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flight_app/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class Service extends ChangeNotifier {
  static Service instance = Service();
  BluetoothConnection connection;
  Timer _timer;
  void setConnection(BluetoothConnection connection) {
    this.connection = connection;
    this._setTimer();
  }

  void sendCommand(COMMAND c) {
    if (this.connection.isConnected) {
      if (this._timer != null) {
        this._timer.cancel();
      }
      this.connection.output.add(Uint8List.fromList([
            (c.index + 1),
          ]));

      this._setTimer();
    }
  }

  void _setTimer() {
    this._timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (this.connection.isConnected) {
        this.connection.output.add(Uint8List.fromList([
              (COMMAND.PING.index + 1),
            ]));
      } else {
        this._timer.cancel();
        this._timer = null;
      }
    });
  }
}
