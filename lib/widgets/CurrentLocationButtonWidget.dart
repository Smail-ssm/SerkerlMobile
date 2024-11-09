import 'package:flutter/material.dart';

class CurrentLocationButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;

  const CurrentLocationButtonWidget({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 80, // Adjusted above the Scan button
      right: 20, // Positioned close to the right edge
      child: Tooltip(
        message: 'Current Location',
        child: RawMaterialButton(
          onPressed: onPressed,
          fillColor: Theme.of(context).colorScheme.primary,
          // Use theme-based color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          constraints: const BoxConstraints.tightFor(
            width: 40.0,
            height: 40.0,
          ),
          child: Icon(
            Icons.my_location,
            size: 24.0,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }
}
