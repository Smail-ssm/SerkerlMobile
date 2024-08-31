 import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'MarkerInfo.dart';

class vhBottomSheet extends StatelessWidget {
  const vhBottomSheet({
    Key? key,
    required this.context,
    required this.markerInfo,
  }) : super(key: key);

  final BuildContext context;
  final MarkerInfo markerInfo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            markerInfo.vehicle!.model,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.0),
          Text(markerInfo.vehicle!.isAvailable ? 'Available' : 'Not Available'),
          SizedBox(height: 16.0),
          Text('Battery ID: ${markerInfo.vehicle?.batteryID}'),
          Text('Speed: ${markerInfo.vehicle?.speed ?? 'N/A'}'),
          Text('Temperature: ${markerInfo.vehicle?.temperature ?? 'N/A'}'),
          Text('Acceleration: ${markerInfo.vehicle?.acceleration ?? 'N/A'}'),
          Text('Next Maintenance Date: ${markerInfo.vehicle?.nextMaintenanceDate?.toLocal().toString() ?? 'N/A'}'),
          SizedBox(height: 16.0),
          if (markerInfo.vehicle?.deviceInfo != null) ...[
            Text('Device Info:'),
            Text('  ID: ${markerInfo.vehicle?.deviceInfo!.id}'),
            Text('  UID: ${markerInfo.vehicle?.deviceInfo!.uid}'),
            Text('  Mileage: ${markerInfo.vehicle?.deviceInfo!.mileage}'),
            Text('  Serial Number: ${markerInfo.vehicle?.deviceInfo!.serialNumber}'),
            Text('  Firmware Version: ${markerInfo.vehicle?.deviceInfo!.firmwareVersion}'),
          ],
          if (markerInfo.vehicle?.maintenanceLog != null ) ...[
            Text('Maintenance Logs:'),
            ...?markerInfo.vehicle?.maintenanceLog!.map((log) => Text('  ${log.toJson()}')).toList(),
          ],
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the bottom sheet
            },
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}