import 'package:flutter/material.dart';

class JuicerOperationsBottomSheet extends StatelessWidget {
  const JuicerOperationsBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).canvasColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Juicer Operations',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.report_problem),
            title: const Text('Report a Problem'),
            onTap: () {
              // Handle reporting a problem
              Navigator.pop(context);
              // Add your problem reporting logic here
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock_open),
            title: const Text('Unlock Vehicle to Change Battery'),
            onTap: () {
              // Handle unlocking vehicle
              Navigator.pop(context);
              // Add your unlocking logic here
            },
          ),
          ListTile(
            leading: const Icon(Icons.battery_charging_full),
            title: const Text('Check Battery Level'),
            onTap: () {
              // Handle checking battery level
              Navigator.pop(context);
              // Add your battery level checking logic here
            },
          ),
          ListTile(
            leading: const Icon(Icons.military_tech),
            title: const Text('Perform Maintenance'),
            onTap: () {
              // Handle maintenance operation
              Navigator.pop(context);
              // Add your maintenance logic here
            },
          ),
        ],
      ),
    );
  }
}
