import 'package:flutter/material.dart';

import '../../model/client.dart';

class TechWorkOrderManagementPage extends StatelessWidget {
  final Client client;

  const TechWorkOrderManagementPage({Key? key, required this.client}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Work Order Management'),
      ),
      body: const Center(
        child: Text('Manage your work orders here.'),
      ),
    );
  }
}
