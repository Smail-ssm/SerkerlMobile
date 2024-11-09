import 'package:flutter/material.dart';

import '../../model/client.dart';

class TechPerformanceMetricsPage extends StatelessWidget {
  final Client client;

  const TechPerformanceMetricsPage({Key? key, required this.client}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Metrics'),
      ),
      body: const Center(
        child: Text('View performance metrics and statistics here.'),
      ),
    );
  }
}
