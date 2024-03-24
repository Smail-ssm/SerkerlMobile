import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class Notfound extends StatefulWidget {
  @override
  _NotfoundState createState() => _NotfoundState();
}

class _NotfoundState extends State<Notfound> {
  late LatLng _currentLocation =
      const LatLng(0.0, 0.0); // Initialize with a default value

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
    );
  }
}
