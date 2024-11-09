import 'package:flutter/material.dart';

class VehicleUtils {
  static void applyFilters({
    required List<String> selectedVehicleTypes,
    required ValueChanged<List<String>> updateVehicleTypes,
    required VoidCallback fetchVehicles,
  }) {
    updateVehicleTypes(selectedVehicleTypes); // Update filter criteria
    fetchVehicles(); // Fetch vehicles with new filters
  }
}
