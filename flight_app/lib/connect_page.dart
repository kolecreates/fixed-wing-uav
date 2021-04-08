import 'package:flight_app/service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class ConnectPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ConnectPageState();
  }
}

class _ConnectPageState extends State<ConnectPage> {
  List<BluetoothDevice> devices = List<BluetoothDevice>();
  @override
  void initState() {
    super.initState();

    FlutterBluetoothSerial.instance.getBondedDevices().then((value) {
      setState(() {
        devices = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BT Connect'),
      ),
      body: ListView(
        children: devices.map((device) {
          return _ConnectListItem(
            device: device,
          );
        }).toList(),
      ),
    );
  }
}

class _ConnectListItem extends StatefulWidget {
  final BluetoothDevice device;
  _ConnectListItem({this.device});
  @override
  State<StatefulWidget> createState() {
    return _ConnectListItemState();
  }
}

class _ConnectListItemState extends State<_ConnectListItem> {
  bool isConnected = false;
  bool connecting = false;

  @override
  void initState() {
    super.initState();
    isConnected = widget.device.isConnected;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: connecting
          ? CircularProgressIndicator()
          : Icon(
              isConnected ? Icons.check_circle : Icons.circle,
            ),
      title: Text(widget.device.name),
      onTap: () {
        if (!isConnected) {
          setState(() {
            connecting = true;
          });
          BluetoothConnection.toAddress(widget.device.address).then((value) {
            setState(() {
              Service.instance.setConnection(value);
              isConnected = true;
              connecting = false;
            });
            Navigator.of(context).pop();
          }).catchError(() {
            setState(() {
              connecting = false;
            });
          });
        }
      },
    );
  }
}
