import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../model/client.dart';

class TechPerformanceMetricsPage extends StatelessWidget {
  final Client client;

  TechPerformanceMetricsPage({required this.client});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Performance Metrics'),
      ),
      body: Center(
        child: Text('View performance metrics and statistics here.'),
      ),
    );
  }
}
