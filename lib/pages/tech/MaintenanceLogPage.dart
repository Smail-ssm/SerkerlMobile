import 'package:ebike/model/MaintenanceLog.dart';
import 'package:ebike/services/Vehicleservice.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MaintenanceLogPage extends StatefulWidget {
  final String vehicleId;

  const MaintenanceLogPage({Key? key, required this.vehicleId}) : super(key: key);

  @override
  _MaintenanceLogPageState createState() => _MaintenanceLogPageState();
}

class _MaintenanceLogPageState extends State<MaintenanceLogPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _technicianController = TextEditingController();
  final TextEditingController _costController = TextEditingController();

  bool batteryCheck = false;
  bool brakesCheck = false;
  bool lightsCheck = false;
  bool tireCheck = false;
  bool componentCleaning = false;
  bool chainLubrication = false;
  bool boltTightening = false;
  bool brakeInspection = false;
  bool batteryHealthCheck = false;
  bool drivetrainCheck = false;
  bool wheelAlignmentCheck = false;

  final Vehicleservice _vehicleService = Vehicleservice();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Maintenance Log'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _saveMaintenanceLog();
          }
        },
        label: const Text('Save Log'),
        icon: const Icon(Icons.save),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Log Details',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10.0),
              _buildDateField(),
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                icon: Icons.description,
              ),
              _buildTextField(
                controller: _technicianController,
                label: 'Technician Name',
                icon: Icons.person,
              ),
              _buildTextField(
                controller: _costController,
                label: 'Cost',
                icon: Icons.attach_money,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20.0),
              const Text(
                'Maintenance Checks',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10.0),
              _buildChecksCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChecksCard() {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: SizedBox(
        height: 300, // Limit the height of the Card to make it scrollable
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildCheckbox('Battery Check', batteryCheck, (value) {
                setState(() => batteryCheck = value);
              }),
              _buildCheckbox('Brakes Check', brakesCheck, (value) {
                setState(() => brakesCheck = value);
              }),
              _buildCheckbox('Lights Check', lightsCheck, (value) {
                setState(() => lightsCheck = value);
              }),
              _buildCheckbox('Tire Check', tireCheck, (value) {
                setState(() => tireCheck = value);
              }),
              _buildCheckbox('Component Cleaning', componentCleaning, (value) {
                setState(() => componentCleaning = value);
              }),
              _buildCheckbox('Chain Lubrication', chainLubrication, (value) {
                setState(() => chainLubrication = value);
              }),
              _buildCheckbox('Bolt Tightening', boltTightening, (value) {
                setState(() => boltTightening = value);
              }),
              _buildCheckbox('Brake Inspection', brakeInspection, (value) {
                setState(() => brakeInspection = value);
              }),
              _buildCheckbox('Battery Health Check', batteryHealthCheck, (value) {
                setState(() => batteryHealthCheck = value);
              }),
              _buildCheckbox('Drivetrain Check', drivetrainCheck, (value) {
                setState(() => drivetrainCheck = value);
              }),
              _buildCheckbox('Wheel Alignment Check', wheelAlignmentCheck, (value) {
                setState(() => wheelAlignmentCheck = value);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveMaintenanceLog() async {
    final log = MaintenanceLog(
      id: UniqueKey().toString(),
      vehicleId: widget.vehicleId,
      date: DateTime.parse(_dateController.text),
      technicianName: _technicianController.text,
      type: 'Custom',
      cost: double.parse(_costController.text),
      batteryCheck: batteryCheck,
      brakesCheck: brakesCheck,
      lightsCheck: lightsCheck,
      tireCheck: tireCheck,
      componentCleaning: componentCleaning,
      chainLubrication: chainLubrication,
      boltTightening: boltTightening,
      brakeInspection: brakeInspection,
      batteryHealthCheck: batteryHealthCheck,
      drivetrainCheck: drivetrainCheck,
      wheelAlignmentCheck: wheelAlignmentCheck,
      notes: _descriptionController.text,
    );

    // Save the maintenance log using the VehicleService
    await _vehicleService.addMaintenanceLog(widget.vehicleId, log);

    // Show confirmation dialog after saving
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Maintenance Log Saved"),
          content: Text(
              "The maintenance log for vehicle ID ${widget.vehicleId} has been saved successfully."),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDateField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: _dateController,
        decoration: const InputDecoration(
          labelText: 'Date',
          hintText: 'Select date',
          prefixIcon: Icon(Icons.calendar_today),
          border: OutlineInputBorder(),
        ),
        readOnly: true,
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2101),
          );
          if (pickedDate != null) {
            setState(() {
              _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
            });
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a date';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildCheckbox(String label, bool value, ValueChanged<bool> onChanged) {
    return CheckboxListTile(
      title: Text(label),
      value: value,
      onChanged: (bool? newValue) {
        onChanged(newValue ?? false);
      },
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}
