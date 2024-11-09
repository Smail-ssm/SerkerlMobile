// TaskDetailsPage to display more information about the selected task
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../model/task.dart';

class TaskDetailsPage extends StatelessWidget {
  final Task task;

  const TaskDetailsPage({Key? key, required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vehicle Model: ${task.vehicleModel}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Battery Level: ${task.batteryLevel}%', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text('Task Type: ${task.taskType}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text('Status: ${task.status}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text('Address: ${task.address}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text('Latitude: ${task.latitude}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text('Longitude: ${task.longitude}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text('Assigned To: ${task.assignedToName ?? 'Not Assigned'}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text('Created At: ${DateFormat('yyyy-MM-dd – kk:mm').format(task.createdAt.toLocal())}', style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}