import 'package:flutter/material.dart';

import '../../model/client.dart';

class JuicerDashboardPage extends StatelessWidget {
  final Client? client;
  const JuicerDashboardPage({Key? key, required this.client}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Juicer Dashboard'),
      ),
      body: Center(
        child: Text('Welcome, ${client!.fullName}!'),
      ),
    );
  }
}
