// scan_code_button.dart

import 'package:flutter/material.dart';
import '../model/client.dart';
import 'CodeInputBottomSheet.dart';

class ScanCodeButton extends StatelessWidget {
  final Client? client;
  final BuildContext context;
  final List<String> Function(Client) getMissingFields;
  final void Function(List<String>) showMissingInfoDialog;
  final Widget Function() buildJuicerOperationsBottomSheet;

  const ScanCodeButton({
    Key? key,
    required this.client,
    required this.context,
    required this.getMissingFields,
    required this.showMissingInfoDialog,
    required this.buildJuicerOperationsBottomSheet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final buttonColor =
    (client!.balance > 0 || client!.role.toLowerCase() == 'juicer')
        ? Colors.red
        : Colors.grey; // Red if balance > 0 or role is juicer, grey if not
    const iconColor = Colors.white; // White text color for the Scan button

    return Positioned(
      bottom: 20,
      left: 80,
      right: 80,
      child: Tooltip(
        message: 'Scan QR Code',
        child: RawMaterialButton(
          onPressed:
          (client!.balance > 0 || client!.role.toLowerCase() == 'juicer')
              ? () {
            List<String> missingFields = getMissingFields(client!);

            if (missingFields.isNotEmpty) {
              showMissingInfoDialog(missingFields);
            } else {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  if (client!.role.toLowerCase() == 'juicer') {
                    return buildJuicerOperationsBottomSheet();
                  } else {
                    return const CodeInputBottomSheet();
                  }
                },
              );
            }
          }
              : null,
          fillColor: buttonColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          constraints: const BoxConstraints.tightFor(
            width: double.infinity,
            height: 60.0,
          ),
          child: const Text(
            'Scan',
            style: TextStyle(
              fontSize: 18.0,
              color: iconColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
