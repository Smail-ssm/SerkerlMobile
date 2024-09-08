import 'package:flutter/material.dart';

class MapGuideButton extends StatelessWidget {
  final Function() onPressed;
  final bool isGuideOpen;

  MapGuideButton({required this.onPressed, required this.isGuideOpen});

  @override
  Widget build(BuildContext context) {
    final buttonColor = Theme.of(context).colorScheme.primary;
    final iconColor = Theme.of(context).colorScheme.onPrimary;

    return Positioned(
      bottom: 120,
      right: 20,
      child: Tooltip(
        message: isGuideOpen ? 'Close Map Guide' : 'Open Map Guide',
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
          child: Icon(
            isGuideOpen ? Icons.close : Icons.map,
            size: 24.0,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}
