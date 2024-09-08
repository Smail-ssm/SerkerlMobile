import 'package:flutter/material.dart';

class ScanCodeButton extends StatelessWidget {
  final Function() onPressed;

  ScanCodeButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final buttonColor = Theme.of(context).colorScheme.primary;
    final iconColor = Theme.of(context).colorScheme.onPrimary;

    return Positioned(
      bottom: 60,
      left: 20,
      child: Tooltip(
        message: 'Scan QR Code',
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
          child: Icon(Icons.qr_code, size: 20.0, color: iconColor),
        ),
      ),
    );
  }
}
