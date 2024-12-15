import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../model/client.dart';
import '../pages/Pricing.dart';
import 'CodeInputBottomSheet.dart';

class ScanCodeButton extends StatelessWidget {
  final Client? client;
  final BuildContext context;
  final List<String> Function(Client) getMissingFields;
  final void Function(List<String>) showMissingInfoDialog;
  final Widget Function() buildJuicerOperationsBottomSheet;
  final LatLng? destination; // Ensure this can be null

  const ScanCodeButton({
    Key? key,
    required this.client,
    required this.context,
    required this.getMissingFields,
    required this.showMissingInfoDialog,
    this.destination, // Allow destination to be null
    required this.buildJuicerOperationsBottomSheet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine button properties based on client conditions
    late LatLng? nullDestination = LatLng(0.0, 0.0); // Track loading state
    final bool isBalanceZero = client != null && client!.balance == 0;
    final bool isButtonEnabled = client != null &&
        (client!.balance > 0 || client!.role.toLowerCase() == 'juicer') &&
        destination != nullDestination;

    final buttonColor = isBalanceZero
        ? Colors.blue
        : (isButtonEnabled ? Colors.red : Colors.grey);

    final String buttonText;
    if (isBalanceZero) {
      buttonText = 'Fill your balance to start 💳';
    } else if (destination == nullDestination) {
      buttonText = 'Choose destination 😉';
    } else {
      buttonText = 'Scan and Serkl 😁';
    }
    final String message;
    if (isBalanceZero) {
      message = 'Fill your balance to start';
    } else if (destination == nullDestination) {
      message = 'Choose destination ';
    } else {
      message = 'Scan code';
    }

    return Positioned(
      bottom: 20,
      left: 80,
      right: 80,
      child: Tooltip(
        message: message,
        child: RawMaterialButton(
          onPressed: isBalanceZero
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          BalanceAndPricingPage(client: client),
                    ),
                  );
                }
              : (isButtonEnabled
                  ? () {
                      if (client != null) {
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
                    }
                  : null),
          fillColor: buttonColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          constraints: const BoxConstraints.tightFor(
            width: double.infinity,
            height: 60.0,
          ),
          child: Text(
            buttonText,
            style: const TextStyle(
              fontSize: 18.0,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  void _showDestinationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Destination'),
          content: const Text('Please select a destination on the map.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Navigate to map to choose destination
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('Choose Destination'),
            ),
          ],
        );
      },
    );
  }
}
