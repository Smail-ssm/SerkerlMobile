// TaskDetailsPage to display more information about the selected task
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../model/task.dart';

class TaskDetailsPage extends StatelessWidget {
  final Task task;

  TaskDetailsPage({required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vehicle Model: ${task.vehicleModel}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Battery Level: ${task.batteryLevel}%', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('Task Type: ${task.taskType}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('Status: ${task.status}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('Address: ${task.address}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('Latitude: ${task.latitude}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('Longitude: ${task.longitude}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('Assigned To: ${task.assignedToName ?? 'Not Assigned'}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('Created At: ${DateFormat('yyyy-MM-dd – kk:mm').format(task.createdAt.toLocal())}', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}