import 'package:easy_localization/easy_localization.dart';
import 'package:ebike/model/MaintenanceLog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../model/vehicule.dart';
import 'tech/MaintenanceLogPage.dart';

class VehicleDetailPage extends StatefulWidget {
  final Vehicle vehicle;
  final String userRole;

  const VehicleDetailPage({Key? key, required this.vehicle, required this.userRole}) : super(key: key);

  @override
  _VehicleDetailPageState createState() => _VehicleDetailPageState();
}

class _VehicleDetailPageState extends State<VehicleDetailPage> {
  bool _isLogVisible = false;
  bool _isSearchVisible = false;
  final TextEditingController _searchController = TextEditingController();
  DateTime? _selectedDate;
  List<MaintenanceLog> _filteredLogs = [];

  @override
  void initState() {
    super.initState();
    _filteredLogs = widget.vehicle.maintenanceLog ?? [];
  }

  Future<void> _addMaintenanceLog() async {
    final newLog = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MaintenanceLogPage(vehicleId: widget.vehicle.id),
      ),
    );

    if (newLog != null) {
      setState(() {
        widget.vehicle.maintenanceLog ??= [];
        widget.vehicle.maintenanceLog!.add(newLog);
        _filteredLogs = widget.vehicle.maintenanceLog!;
      });

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.battery_full, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Battery Level'.tr(),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('${vehicle.battery.level ?? 'N/A'}%', style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(Icons.date_range, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Last Maintenance'.tr(),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              vehicle.nextMaintenanceDate != null
                                  ? DateFormat('yyyy-MM-dd').format(vehicle.nextMaintenanceDate!)
                                  : 'N/A',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ]),
            const SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionHeader(
                  context,
                  icon: Icons.history,
                  title: 'Maintenance Logs'.tr(),
                  isDarkMode: isDarkMode,
                ),
                IconButton(
                  icon: Icon(_isSearchVisible ? Icons.close : Icons.search),
                  onPressed: () {
                    setState(() {
                      _isSearchVisible = !_isSearchVisible;
                      if (!_isSearchVisible) {
                        _searchController.clear();
                        _selectedDate = null;
                        _filteredLogs = widget.vehicle.maintenanceLog ?? [];
                      }
                    });
                  },
                ),
              ],
            ),
            if (_isSearchVisible) _buildSearchBar(),
            _buildMaintenanceLogSection(vehicle),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search logs...'.tr(),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _applyFilters();
                },
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
            ),
            onChanged: (value) => _applyFilters(),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Filter by Date'.tr(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () => _selectDate(),
              ),
            ],
          ),
          if (_selectedDate != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Selected Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}',
                    style: const TextStyle(fontSize: 14.0),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _selectedDate = null;
                        _applyFilters();
                      });
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _applyFilters() {
    setState(() {
      _filteredLogs = widget.vehicle.maintenanceLog!.where((log) {
        final searchMatch = _searchController.text.isEmpty ||
            log.notes.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            log.technicianName.toLowerCase().contains(_searchController.text.toLowerCase());
        final dateMatch = _selectedDate == null ||
            DateFormat('yyyy-MM-dd').format(log.date) == DateFormat('yyyy-MM-dd').format(_selectedDate!);
        return searchMatch && dateMatch;
      }).toList();
    });
  }

  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _applyFilters();
      });
    }
  }

  Widget _buildMaintenanceLogSection(Vehicle vehicle) {
    return Card(
      color: Theme.of(context).cardColor,
      elevation: 5.0,
      shadowColor: Colors.grey.withOpacity(0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ListTile(
              title: Text('Maintenance Logs'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
              trailing: IconButton(
                icon: Icon(_isLogVisible ? Icons.expand_less : Icons.expand_more),
                onPressed: () {
                  setState(() {
                    _isLogVisible = !_isLogVisible;
                  });
                },
              ),
            ),
            if (_isLogVisible)
              _filteredLogs.isNotEmpty
                  ? Column(
                children: _filteredLogs
                    .map((log) => GestureDetector(
                  onTap: () => _showLogDetails(log),
                  child: Card(
                    color: Theme.of(context).cardColor.withOpacity(0.95),
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.info, color: Colors.blueAccent),
                      title: Text(
                        DateFormat('yyyy-MM-dd').format(log.date),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Technician: ${log.technicianName}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ))
                    .toList(),
              )
                  : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('No logs found matching criteria'.tr(), style: const TextStyle(fontSize: 14)),
              ),
          ],
        ),
      ),
    );
  }

  void _showLogDetails(MaintenanceLog log) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Maintenance Log Details'.tr(),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Divider(),
                const SizedBox(height: 8),
                Text('Date: ${DateFormat('yyyy-MM-dd').format(log.date)}'),
                Text('Technician: ${log.technicianName}'),
                Text('Type: ${log.type}'),
                Text('Cost: ${log.cost.toStringAsFixed(2)}'),
                const SizedBox(height: 16),
                Text('Notes: ${log.notes}'),
                const SizedBox(height: 20),
                Text('Maintenance Checks'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ..._buildCheckDetail(log),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildCheckDetail(MaintenanceLog log) {
    final checks = {
      'Battery Check': log.batteryCheck,
      'Brakes Check': log.brakesCheck,
      'Lights Check': log.lightsCheck,
      'Tire Check': log.tireCheck,
      'Component Cleaning': log.componentCleaning,
      'Chain Lubrication': log.chainLubrication,
      'Bolt Tightening': log.boltTightening,
      'Brake Inspection': log.brakeInspection,
      'Battery Health Check': log.batteryHealthCheck,
      'Drivetrain Check': log.drivetrainCheck,
      'Wheel Alignment Check': log.wheelAlignmentCheck,
    };

    return checks.entries.map((entry) {
      return ListTile(
        leading: Icon(
          entry.value ? Icons.check_circle : Icons.cancel,
          color: entry.value ? Colors.green : Colors.red,
        ),
        title: Text(entry.key.tr()),
      );
    }).toList();
  }

  Widget _buildSectionHeader(BuildContext context,
      {required IconData icon, required String title, required bool isDarkMode}) {
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
        onTap: _addMaintenanceLog,
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
