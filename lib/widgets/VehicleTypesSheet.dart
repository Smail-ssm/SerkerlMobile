import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class VehicleTypesSheet extends StatefulWidget {
  const VehicleTypesSheet({Key? key}) : super(key: key);

  @override
  State<VehicleTypesSheet> createState() => _VehicleTypesSheetState();
}

class _VehicleTypesSheetState extends State<VehicleTypesSheet> {
  List<String> _selectedVehicles = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Vehicle types',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              IconButton(
                onPressed: () => Navigator.pop(context, _selectedVehicles),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 24.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildVehicleTypeButton(Icons.pedal_bike, 'Bikes'),
              _buildVehicleTypeButton(Icons.electric_scooter, 'Scooters'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleTypeButton(IconData icon, String label) {
    return InkWell(
      onTap: () {
        setState(() {
          // Toggle selection state
          if (_selectedVehicles.contains(label)) {
            _selectedVehicles.remove(label);
          } else {
            _selectedVehicles.add(label);
          }
        });
      },
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[200],
            ),
            child: Icon(icon, size: 48.0),
          ),
          if (_selectedVehicles.contains(label))
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
