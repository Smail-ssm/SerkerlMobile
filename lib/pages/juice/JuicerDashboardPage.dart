import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../model/client.dart';

class JuicerDashboardPage extends StatelessWidget {
  final Client? client;
  JuicerDashboardPage({required this.client});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Juicer Dashboard'),
      ),
      body: Center(
        child: Text('Welcome, ${client!.fullName}!'),
      ),
    );
  }
}
