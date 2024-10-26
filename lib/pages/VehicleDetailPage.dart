import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import '../model/vehicule.dart';
import 'tech/MaintenanceLogPage.dart';

class VehicleDetailPage extends StatefulWidget {
  final Vehicle vehicle;
  final String userRole;

  VehicleDetailPage({required this.vehicle, required this.userRole});

  @override
  _VehicleDetailPageState createState() => _VehicleDetailPageState();
}

class _VehicleDetailPageState extends State<VehicleDetailPage> {
  bool _isLogExpanded = false;

  Future<void> _addMaintenanceLog() async {
    // Navigate to MaintenanceLogPage to create a new log and receive it back
    final newLog = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MaintenanceLogPage(vehicleId: widget.vehicle.id),
      ),
    );

    // Add the returned log to the vehicle's maintenance log list, if available
    if (newLog != null) {
      setState(() {
        widget.vehicle.maintenanceLog ??= []; // Initialize if null
        widget.vehicle.maintenanceLog!.add(newLog);
      });

      // Show feedback message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Maintenance log added successfully!'.tr())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicle = widget.vehicle;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isJuicer = widget.userRole == "juicer";

    return Scaffold(
      appBar: AppBar(
        title: Text(vehicle.model ?? 'Vehicle Details'.tr()),
      ),
      floatingActionButton: _buildExpandableFAB(isJuicer, vehicle),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              context,
              icon: Icons.directions_bike,
              title: 'Vehicle Information'.tr(),
              isDarkMode: isDarkMode,
            ),
            _buildCard(isDarkMode, [
              ListTile(
                leading: const Icon(Icons.battery_full),
                title: Text('Current Battery Level'.tr()),
                trailing: Text('${vehicle.battery.level ?? 'N/A'}%'),
              ),
              ListTile(
                leading: const Icon(Icons.date_range),
                title: Text('Last Maintenance Date'.tr()),
                trailing: Text(vehicle.nextMaintenanceDate != null
                    ? DateFormat('yyyy-MM-dd')
                    .format(vehicle.nextMaintenanceDate!)
                    : 'N/A'),
              ),
            ]),
            const SizedBox(height: 10.0),

            // Expandable Maintenance Log Section
            _buildExpandableLogSection(vehicle),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableFAB(bool isJuicer, Vehicle vehicle) {
    return SpeedDial(
      icon: Icons.menu,
      activeIcon: Icons.close,
      backgroundColor: Theme.of(context).primaryColor,
      overlayColor: Colors.black,
      overlayOpacity: 0.5,
      spacing: 8.0,
      spaceBetweenChildren: 8.0,
      children: isJuicer
          ? _buildJuicerFABActions(vehicle)
          : _buildTechnicianFABActions(vehicle),
    );
  }

  List<SpeedDialChild> _buildJuicerFABActions(Vehicle vehicle) {
    return [
      SpeedDialChild(
        child: const Icon(Icons.battery_charging_full, color: Colors.white),
        backgroundColor: Colors.blue,
        label: 'Replace Battery'.tr(),
        onTap: () => _replaceBattery(vehicle),
      ),
      SpeedDialChild(
        child: const Icon(Icons.report, color: Colors.white),
        backgroundColor: Colors.red,
        label: 'Report a Problem'.tr(),
        onTap: () => _reportProblem(vehicle),
      ),
    ];
  }

  List<SpeedDialChild> _buildTechnicianFABActions(Vehicle vehicle) {
    return [
      SpeedDialChild(
        child: const Icon(Icons.not_interested, color: Colors.white),
        backgroundColor: Colors.red,
        label: 'Mark as Unavailable'.tr(),
        onTap: () => _markVehicleAsUnavailable(vehicle),
      ),
      SpeedDialChild(
        child: const Icon(Icons.build, color: Colors.white),
        backgroundColor: Colors.orange,
        label: 'Mark as Under Maintenance'.tr(),
        onTap: () => _markVehicleAsUnderMaintenance(vehicle),
      ),
      SpeedDialChild(
        child: const Icon(Icons.event_available, color: Colors.white),
        backgroundColor: Colors.green,
        label: 'Schedule Maintenance'.tr(),
        onTap: _addMaintenanceLog, // Directly add maintenance log
      ),
      SpeedDialChild(
        child: const Icon(Icons.restart_alt, color: Colors.white),
        backgroundColor: Colors.purple,
        label: 'Reset Vehicle System'.tr(),
        onTap: () => _resetVehicleSystem(vehicle),
      ),
      SpeedDialChild(
        child: const Icon(Icons.report, color: Colors.white),
        backgroundColor: Colors.red,
        label: 'Report a Problem'.tr(),
        onTap: () => _reportProblem(vehicle),
      ),
    ];
  }

  Widget _buildExpandableLogSection(Vehicle vehicle) {
    return ExpansionPanelList(
      expandedHeaderPadding: const EdgeInsets.all(0),
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          _isLogExpanded = !isExpanded;
        });
      },
      children: [
        ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              leading: const Icon(Icons.history),
              title: Text('Maintenance Logs'.tr()),
            );
          },
          body: vehicle.maintenanceLog != null &&
              vehicle.maintenanceLog!.isNotEmpty
              ? Column(
            children: vehicle.maintenanceLog!
                .map((log) => ListTile(
              title: Text(
                  '${DateFormat('yyyy-MM-dd').format(log.date)}: ${log.notes}'),
              subtitle: Text(
                  'Technician: ${log.technicianName ?? 'Unknown'}'),
            ))
                .toList(),
          )
              : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('No maintenance logs available'.tr()),
          ),
          isExpanded: _isLogExpanded,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context,
      {required IconData icon,
        required String title,
        required bool isDarkMode}) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor),
        const SizedBox(width: 8.0),
        Text(
          title,
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildCard(bool isDarkMode, List<Widget> children) {
    return Card(
      color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: children),
      ),
    );
  }

  void _markVehicleAsUnavailable(Vehicle vehicle) {
    setState(() {
      vehicle.isAvailable = false;
    });
  }

  void _markVehicleAsUnderMaintenance(Vehicle vehicle) {
    setState(() {
      vehicle.isAvailable = false;
      vehicle.nextMaintenanceDate = DateTime.now().add(const Duration(days: 7));
    });
  }

  void _replaceBattery(Vehicle vehicle) {
    setState(() {
      vehicle.battery.level = 100;
    });
  }

  void _resetVehicleSystem(Vehicle vehicle) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Vehicle system reset for ${vehicle.id}')),
    );
  }

  void _reportProblem(Vehicle vehicle) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Problem reported for vehicle ${vehicle.id}')),
    );
  }
}
