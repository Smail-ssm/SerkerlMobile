import 'package:flutter/material.dart';

class MapStyleButton extends StatelessWidget {
  final Function() onPressed;

  MapStyleButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final buttonColor = Theme.of(context).colorScheme.primary;
    final iconColor = Theme.of(context).colorScheme.onPrimary;

    return Positioned(
      bottom: 120,
      left: 20,
      child: Tooltip(
        message: 'Change Map Style',
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
          child: Icon(Icons.style_outlined, size: 20.0, color: iconColor),
        ),
      ),
    );
  }
}
