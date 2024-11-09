import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../../model/battery.dart';
import '../../services/BatteryService.dart';
import '../../util/util.dart';

class BatteryManagementPage extends StatefulWidget {
  const BatteryManagementPage({Key? key}) : super(key: key);

  @override
  _BatteryManagementPageState createState() => _BatteryManagementPageState();
}

class _BatteryManagementPageState extends State<BatteryManagementPage> {
  late BatteryService _batteryService;
  List<Battery> _batteryList = [];
  bool _isLoading = true;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? _qrController;

  @override
  void initState() {
    super.initState();
    _batteryService = BatteryService();
    fetchBatteries();
  }

  Future<void> fetchBatteries() async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      List<Battery> batteries = await getAllBatteries(auth.currentUser!.uid);
      setState(() {
        _batteryList = batteries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackbar('Failed to fetch batteries.');
    }
  }

  Future<void> updateStatus(Battery battery, String newStatus) async {
    try {
      await _batteryService.updateBatteryStatus(battery.id, newStatus);
      setState(() {
        int index = _batteryList.indexWhere((b) => b.id == battery.id);
        if (index != -1) {
          _batteryList[index].status = newStatus;
        }
      });
      _showSuccessSnackbar('Battery status updated to $newStatus.');
    } catch (e) {
      _showErrorSnackbar('Failed to update battery status.');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildBatteryCard(Battery battery) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      child: ListTile(
        title: Text('Battery ID: ${battery.id}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${battery.type}'),
            Text('Capacity: ${battery.capacity} Ah'),
            Text('Manufacturer: ${battery.manufacturer}'),
            Text('Level: ${battery.level}%'),
            Text('Status: ${battery.status}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (String newStatus) {
            updateStatus(battery, newStatus);
          },
          itemBuilder: (BuildContext context) {
            return <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'In Use',
                child: Text('In Use'),
              ),
              const PopupMenuItem<String>(
                value: 'Charging',
                child: Text('Charging'),
              ),
              const PopupMenuItem<String>(
                value: 'Pending Charge',
                child: Text('Pending Charge'),
              ),
              const PopupMenuItem<String>(
                value: 'Charged',
                child: Text('Charged'),
              ),
            ];
          },
          icon: const Icon(Icons.more_vert),
        ),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    _qrController = controller;
    controller.scannedDataStream.listen((scanData) {
      _qrController?.pauseCamera(); // Pause the camera to avoid multiple scans
      _handleQRCode(scanData.code); // Handle scanned QR code
    });
  }

  void _handleQRCode(String? code) {
    if (code == null) {
      _showErrorSnackbar('Failed to scan the QR code.');
      return;
    }

    Battery? scannedBattery =
        _batteryList.firstWhere((battery) => battery.id == code);

    Navigator.pop(context); // Close the scanner and return to the main screen
    _showBatteryDetails(scannedBattery);
    }

  void _showBatteryDetails(Battery battery) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Battery Details'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('ID: ${battery.id}'),
              Text('Type: ${battery.type}'),
              Text('Capacity: ${battery.capacity} Ah'),
              Text('Manufacturer: ${battery.manufacturer}'),
              Text('Level: ${battery.level}%'),
              Text('Status: ${battery.status}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _editBatteryStatus(
                    battery); // Allow user to edit battery status
              },
              child: const Text('Edit Status'),
            ),
          ],
        );
      },
    );
  }

  void _editBatteryStatus(Battery battery) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Edit Battery Status'),
          children: [
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                updateStatus(battery, 'In Use');
              },
              child: const Text('In Use'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                updateStatus(battery, 'Charging');
              },
              child: const Text('Charging'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                updateStatus(battery, 'Pending Charge');
              },
              child: const Text('Pending Charge'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                updateStatus(battery, 'Charged');
              },
              child: const Text('Charged'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Battery Management'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchBatteries,
              child: _batteryList.isEmpty
                  ? const Center(child: Text('No batteries found.'))
                  : ListView.builder(
                      itemCount: _batteryList.length,
                      itemBuilder: (context, index) {
                        return _buildBatteryCard(_batteryList[index]);
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Open QR scanner to verify or edit battery info
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
              ),
            ),
          );
        },
        child: const Icon(Icons.qr_code_scanner),
      ),
    );
  }

  @override
  void dispose() {
    _qrController?.dispose();
    super.dispose();
  }

  Future<List<Battery>> getAllBatteries(String uid) async {
    try {
      final FirebaseFirestore _firestore = FirebaseFirestore.instance;
      final String env = getFirestoreDocument();
      QuerySnapshot querySnapshot = await _firestore
          .collection(env)
          .doc('Batterys')
          .collection('Batterys')
          .where('responsibleJuicerId', isEqualTo: uid) // Filter by juicer ID

          .get();

      return querySnapshot.docs.map((doc) {
        return Battery.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      debugPrint('Error fetching batteries: $e');
      rethrow;
    }
  }
}
