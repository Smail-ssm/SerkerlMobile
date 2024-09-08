import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;

class CodeInputBottomSheet extends StatefulWidget {
  const CodeInputBottomSheet({Key? key}) : super(key: key);

  @override
  _CodeInputBottomSheetState createState() => _CodeInputBottomSheetState();
}

class _CodeInputBottomSheetState extends State<CodeInputBottomSheet> {
  final TextEditingController _textEditingController = TextEditingController();
  late QRViewController _qrViewController;
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
  String _scannedCode = '';
  bool _isFlashOn = false; // Flash state variable
  bool _isUnlocking = false; // Unlock state variable

  @override
  void dispose() {
    _textEditingController.dispose();
    _qrViewController.dispose(); // Dispose of the QRViewController to prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the theme data to determine the current mode
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7, // Adjust height as needed
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isLandscape = constraints.maxWidth > constraints.maxHeight;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isLandscape)
                  _buildLandscapeLayout(theme, isDarkMode)
                else
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
          width: double.infinity,
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
        _hideBottomSheetAndShowDialog(scanData.code!); // Hide the bottom sheet and show unlock dialog
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

  // Hide the bottom sheet and show unlock dialog after scanning the QR code
  void _hideBottomSheetAndShowDialog(String vehicleCode) {
    Navigator.of(context).pop(); // Hide the bottom sheet
    _showUnlockDialog(vehicleCode); // Show the unlock confirmation dialog
  }

  // Show unlock dialog with a loading spinner while checking
  void _showUnlockDialog(String vehicleCode) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing the dialog while processing
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Unlocking Vehicle'),
              content: Row(
                children: [
                  const CircularProgressIndicator(), // Loading spinner
                  const SizedBox(width: 16), // Add some space between the spinner and text
                  Expanded( // Expanded forces the text to take up the remaining space
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
    setState(() {
      _isUnlocking = true;
    });

    // Simulate balance check and other validations
    bool balanceCheckPassed = await _checkBalance();
    bool vehicleAvailable = await _checkVehicleAvailability(vehicleCode);

    if (balanceCheckPassed && vehicleAvailable) {
      _unlockVehicle(vehicleCode); // If all checks pass, unlock the vehicle
    } else {
      // Handle case where checks fail
      if (mounted) {
        _showError('Failed to unlock. Please ensure balance and vehicle availability.');
      }
    }

    if (mounted) {
      setState(() {
        _isUnlocking = false;
      });
    }
  }

  // Simulated balance check
  Future<bool> _checkBalance() async {
    // Simulate an API call to check user balance
    await Future.delayed(const Duration(seconds: 1)); // Simulating delay
    return true; // Assuming balance check passes
  }

  // Simulated vehicle availability check
  Future<bool> _checkVehicleAvailability(String vehicleCode) async {
    // Simulate an API call to check if the vehicle is available
    await Future.delayed(const Duration(seconds: 1)); // Simulating delay
    return true; // Assuming vehicle is available
  }

  // Unlock vehicle using either scanned or manually entered code
// Unlock vehicle using either scanned or manually entered code
  void _unlockVehicle(String vehicleCode) async {
    try {
      await Future.delayed(const Duration(seconds: 5)); // Simulating delay

      // Simulate sending code to the backend to unlock the vehicle
      http.Response response = http.Response("body", 200); // Simulated response

      if (response.statusCode == 200) {
        if (mounted) {
          // Ensure we are using a valid context and call pop in the UI thread
          Future.delayed(Duration.zero, () {
            if (mounted) Navigator.of(context).pop(); // Close the unlock dialog
          });

          // Show success message and start the ride
          _showSuccess('Vehicle unlocked successfully! Starting ride...');
          _startRide(vehicleCode); // Start the ride after successful unlock
        }
      } else {
        if (mounted) {
          Future.delayed(Duration.zero, () {
            if (mounted) Navigator.of(context).pop(); // Close the dialog on failure
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

// Start the ride after unlocking the vehicle
  void _startRide(String vehicleCode) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ride started with vehicle code: $vehicleCode'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

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


}
