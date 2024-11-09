import 'package:flutter/material.dart';

import '../../model/client.dart';

class JuicerEarningsPage extends StatelessWidget {
  final Client? client;
  const JuicerEarningsPage({Key? key, required this.client}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JuicerEarningsPage'),
      ),
      body: const Center(
        child: Text('List of vehicles assigned to you.'),
      ),
    );
  }
}
