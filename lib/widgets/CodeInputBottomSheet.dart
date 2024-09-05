import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class CodeInputBottomSheet extends StatefulWidget {
  const CodeInputBottomSheet({Key? key}) : super(key: key);

  @override
  _CodeInputBottomSheetState createState() => _CodeInputBottomSheetState();
}

class _CodeInputBottomSheetState extends State<CodeInputBottomSheet> {
  TextEditingController _textEditingController = TextEditingController();
  late QRViewController _qrViewController;
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
  String _scannedCode = '';
  bool _isFlashOn = false; // Flash state variable

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
                  Row(
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
                            TextField(
                              controller: _textEditingController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
                                filled: true,
                                fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                              ),
                              style: TextStyle(color: theme.textTheme.bodyLarge!.color),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                else
                  Column(
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
                      TextField(
                        controller: _textEditingController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
                          filled: true,
                          fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                        ),
                        style: TextStyle(color: theme.textTheme.bodyLarge!.color),
                      ),
                    ],
                  ),
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

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      _qrViewController = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        _textEditingController.text = scanData.code!;
        _scannedCode = scanData.code!;
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
}
