import 'dart:math';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart';
import 'package:latlong/latlong.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  LocationData _currentLocation;
  var location = new Location();
  String _error;

  List tasks = [
    {"title": "家に帰る", "latitude": 34.7020791, "longitude": 137.4052283},
    {"title": "ジムに行く", "latitude": 34.7008209, "longitude": 137.4061786},
    {"title": "研究室に行く", "latitude": 34.7017439, "longitude": 137.4092489}
  ];

  @override
  void initState() {
    print("init");
    super.initState();
    // Platform messages may fail, so we use a try/catch PlatformException.
    initLocation();
  }

  initLocation() async {
    try {
      _currentLocation = await location.getLocation();
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        _error = 'Permission denied';
      }
      _currentLocation = null;
    }
    location.onLocationChanged().listen((LocationData currentLocation) {
      print("detect location change");
      setState(() {
        _currentLocation = currentLocation;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(
              children: tasks
                  .map((task) => Container(
                          child: Row(children: [
                        Text(task["title"].toString()),
                        Text(task["latitude"].toString()),
                        Text(task["longitude"].toString()),
                        Text(isInLocation(task) ? "OK" : ""),
                      ])))
                  .toList(),
            ),
            Text("accuracy: " + _currentLocation?.accuracy.toString() + " m"),
            Text("latitude: " + _currentLocation?.latitude.toString()),
            Text("longitude: " + _currentLocation?.longitude.toString()),
            Text("error: " + _error.toString()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // onPressed: ,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  isInLocation(task) {
    if (_currentLocation == null) return false;
    const int radius = 50; // meter

    final Distance distance = new Distance();

    // meter = 422591.551
    final meter = distance(
        new LatLng(_currentLocation?.latitude, _currentLocation?.longitude),
        new LatLng(task["latitude"], task["longitude"]));

    return meter <= radius;
  }
}
