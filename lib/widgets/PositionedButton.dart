import 'package:flutter/material.dart';

class PositionedButton extends StatelessWidget {
  final IconData icon;
  final double? bottom;
  final double? left;
  final double? top;
  final double? right;
  final String tooltipMessage;
  final VoidCallback onPressed;

  const PositionedButton({
    Key? key,
    required this.icon,
    this.bottom,
    this.left,
    this.top,
    this.right,
    required this.tooltipMessage,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: bottom,
      left: left,
      top: top,
      right: right,
      child: Tooltip(
        message: tooltipMessage,
        child: RawMaterialButton(
          onPressed: onPressed,
          fillColor: Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0), // Rounded corners
          ),
          constraints: const BoxConstraints.tightFor(
            width: 40.0,
            height: 40.0,
          ),
          child: Icon(
            icon,
            size: 24.0,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }
}
