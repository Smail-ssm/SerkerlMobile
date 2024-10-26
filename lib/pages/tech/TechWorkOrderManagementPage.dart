import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../model/client.dart';

class TechWorkOrderManagementPage extends StatelessWidget {
  final Client client;

  TechWorkOrderManagementPage({required this.client});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Work Order Management'),
      ),
      body: Center(
        child: Text('Manage your work orders here.'),
      ),
    );
  }
}
