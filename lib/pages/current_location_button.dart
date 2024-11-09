import 'package:flutter/material.dart';

class CurrentLocationButton extends StatelessWidget {
  final Function() onPressed;

  const CurrentLocationButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final buttonColor = Theme.of(context).colorScheme.primary;
    final iconColor = Theme.of(context).colorScheme.onPrimary;

    return Positioned(
      bottom: 60,
      right: 20,
      child: Tooltip(
        message: 'Current Location',
        child: RawMaterialButton(
          onPressed: onPressed,
          fillColor: buttonColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          constraints: const BoxConstraints.tightFor(
            width: 40.0,
            height: 40.0,
          ),
          child: Icon(Icons.my_location, size: 24.0, color: iconColor),
        ),
      ),
    );
  }
}
