import 'package:flight_app/connect_page.dart';
import 'package:flight_app/controller_page.dart';
import 'package:flight_app/service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => Service.instance,
      child: MaterialApp(
        title: 'Flight App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MenuPage(),
      ),
    );
  }
}

class MenuPage extends StatelessWidget {
  MenuPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menu'),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        children: List.from([
          MenuButton(
            label: "Connect",
            routeBuilder: (_) => ConnectPage(),
          ),
          MenuButton(
            label: "Controller",
            routeBuilder: (_) => ControllerPage(),
          ),
        ]),
      ),
    );
  }
}

class MenuButton extends StatelessWidget {
  final String label;
  final Widget Function(BuildContext context) routeBuilder;
  MenuButton({this.label, this.routeBuilder});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: routeBuilder),
          );
        },
        child: Text(label));
  }
}
