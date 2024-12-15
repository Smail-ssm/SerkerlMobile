import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../model/Rental.dart';
import '../services/RentalService.dart';
import '../services/Vehicleservice.dart';

class CodeInputBottomSheet extends StatefulWidget {
  const CodeInputBottomSheet({Key? key}) : super(key: key);

  @override
  _CodeInputBottomSheetState createState() => _CodeInputBottomSheetState();
}

class _CodeInputBottomSheetState extends State<CodeInputBottomSheet> {
  final Vehicleservice _vehicleService = Vehicleservice();
  final RentalService _rentalService = RentalService();
  final TextEditingController _textEditingController = TextEditingController();
  late QRViewController _qrViewController;
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
  String _scannedCode = '';
  bool _isFlashOn = false; // Flash state variable
  bool _isUnlocking = false; // Unlock state variable
  String userId = FirebaseAuth.instance.currentUser!.uid;
  @override
  void dispose() {
    _textEditingController.dispose();
    _qrViewController
        .dispose(); // Dispose of the QRViewController to prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the theme data to determine the current mode
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return SizedBox(
      height:
          MediaQuery.of(context).size.height * 0.7, // Adjust height as needed
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPortraitLayout(theme, isDarkMode),
                const SizedBox(height: 16.0),
                Align(
                  alignment: Alignment.centerRight,
                  child: RawMaterialButton(
                    onPressed: _toggleFlash,
                    fillColor: isDarkMode ? Colors.blueGrey : Colors.blue,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(12.0),
                    child: Icon(
                      _isFlashOn ? Icons.flash_on : Icons.flash_off,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Build layout for landscape mode
  Widget _buildLandscapeLayout(ThemeData theme, bool isDarkMode) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Scan QR Code',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyLarge!.color,
                ),
              ),
              const SizedBox(height: 8.0),
              SizedBox(
                height: 200, // Explicit height for QRView
                child: QRView(
                  key: _qrKey,
                  onQRViewCreated: _onQRViewCreated,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16.0),
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter Code Manually',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyLarge!.color,
                ),
              ),
              const SizedBox(height: 8.0),
              _buildManualCodeInput(isDarkMode),
            ],
          ),
        ),
      ],
    );
  }

  // Build layout for portrait mode
  Widget _buildPortraitLayout(ThemeData theme, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Scan QR Code',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyLarge!.color,
          ),
        ),
        const SizedBox(height: 8.0),
        SizedBox(
          height: 250,
          // Explicit height for QRView
          width: 250,
          child: QRView(
            key: _qrKey,
            onQRViewCreated: _onQRViewCreated,
          ),
        ),
        const SizedBox(height: 16.0),
        Text(
          'Enter Code Manually',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyLarge!.color,
          ),
        ),
        const SizedBox(height: 8.0),
        _buildManualCodeInput(isDarkMode),
      ],
    );
  }

  // Build manual code input field
  Widget _buildManualCodeInput(bool isDarkMode) {
    return TextField(
      controller: _textEditingController,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
        filled: true,
        fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
      ),
      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      _qrViewController = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        _scannedCode = scanData.code!;
        _showUnlockDialog(_scannedCode);
      });
    });
  }

  void _toggleFlash() async {
    await _qrViewController.toggleFlash();
    bool? flashStatus = await _qrViewController.getFlashStatus();
    setState(() {
      _isFlashOn = flashStatus ?? false;
    });
  }

  // Show unlock dialog with a loading spinner while checking
  void _showUnlockDialog(String vehicleCode) {
    showDialog(
      context: context,
      barrierDismissible: false,
      // Prevent closing the dialog while processing
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return const AlertDialog(
              title: Text('Unlocking Vehicle'),
              content: Row(
                children: [
                  CircularProgressIndicator(),
                  // Loading spinner
                  SizedBox(width: 16),
                  // Add some space between the spinner and text
                  Expanded(
                    // Expanded forces the text to take up the remaining space
                    child: Text('Please wait while we unlock the vehicle...'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    // Perform the checks and unlock process after showing the dialog
    _performChecksAndUnlock(vehicleCode);
  }

  // Perform balance and vehicle availability checks before unlocking
  void _performChecksAndUnlock(String vehicleCode) async {
    // Simulate balance check and other validations
    bool balanceCheckPassed = await _checkBalance();

    if (balanceCheckPassed) {
      _unlockVehicle(vehicleCode); // If all checks pass, unlock the vehicle
    } else {
      // Handle case where checks fail
      if (mounted) {
        _showError(
            'Failed to unlock. Please ensure balance and vehicle availability.');
      }
    }
  }

  // Simulated balance check
  Future<bool> _checkBalance() async {
    // Simulate an API call to check user balance
    await Future.delayed(const Duration(seconds: 1)); // Simulating delay
    return true; // Assuming balance check passes
  }

  // Unlock vehicle using either scanned or manually entered code
// Unlock vehicle using either scanned or manually entered code



// Show error message
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

// Show success message
  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _unlockVehicle(String vehicleCode) async {
    print('Vehicle code fetched: ${vehicleCode}');
    try {
      final String rentalId =
          "R-${DateTime.now().millisecondsSinceEpoch}-${vehicleCode}";

      // If reserving, create a new Rental object
      Rental? rental;
      bool isReserving = true;
      rental = Rental(
        id: rentalId,
        vId: vehicleCode,
        startTime: isReserving ? DateTime.now().toString() : null,
        expectedReturnTime: isReserving
            ? DateTime.now().add(const Duration(hours: 1)).toString()
            : null,
        baseRate: 5.0,
        unlockPrice: 1.0,
        pausePrice: 0.5,
        user: userId,
        notes: isReserving
            ? 'Reserved by user ${userId} at ${DateTime.now()}'
            : 'Reservation created but not active.',
      ); // Simulate delay
      bool isUnlocked =
      await _vehicleService.unlockVh(vehicleCode, userId, rental);

      if (isUnlocked) {
        if (mounted) {
          Navigator.of(context).pop(); // Close the bottom sheet
        }

        _showSuccess('Vehicle unlocked successfully! Starting ride...');
      } else {
        if (mounted) {
          Future.delayed(Duration.zero, () {
            if (mounted) {
              Navigator.of(context).pop(); // Close the dialog on failure
            }
          });

          // Show error if unlocking fails
          _showError('Failed to unlock vehicle. Please try again.');
        }
      }
    } catch (e) {
      if (mounted) {
        Future.delayed(Duration.zero, () {
          if (mounted) Navigator.of(context).pop(); // Close the dialog on error
        });

        // Show error if an exception occurs
        _showError('An error occurred while trying to unlock the vehicle.');
      }
    }
  }
//todo when cancling implment this
//   Future<void> _handleReservation(String selectedVH) async {

// try {
//   if (isReserving) {
//
//     // Reserve the vehicle and save the rental
//
//   } else {
//     // Update the rental notes with the cancellation message
//     rental.notes += ' Reservation canceled by user ${ userId} at ${DateTime.now()}';
//
//     // Cancel the reservation and update the rental notes
//     await _vehicleService.cancelReservation(selectedVH,  userId);
//     await _rentalService.updateRentalNotes(rental.id, rental.notes);
//
//      selectedVH  = null;
//
//
//     Fluttertoast.showToast(
//       msg: 'Reservation canceled successfully!',
//       toastLength: Toast.LENGTH_SHORT,
//       gravity: ToastGravity.BOTTOM,
//       backgroundColor: Colors.green,
//       textColor: Colors.white,
//       fontSize: 16.0,
//     );
//   }
// } catch (e) {
//   Fluttertoast.showToast(
//     msg: isReserving
//         ? 'Failed to reserve vehicle. Please try again.'
//         : 'Failed to cancel reservation. Please try again.',
//     toastLength: Toast.LENGTH_SHORT,
//     gravity: ToastGravity.BOTTOM,
//     backgroundColor: Colors.red,
//     textColor: Colors.white,
//     fontSize: 16.0,
//   );
// }
// }
}
