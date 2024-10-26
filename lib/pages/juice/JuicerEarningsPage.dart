import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../model/client.dart';

class JuicerEarningsPage extends StatelessWidget {
  final Client? client;
  JuicerEarningsPage({required this.client});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('JuicerEarningsPage'),
      ),
      body: Center(
        child: Text('List of vehicles assigned to you.'),
      ),
    );
  }
}
