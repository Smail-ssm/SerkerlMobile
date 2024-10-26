import 'package:flutter/material.dart';

class ReferralDialog extends StatefulWidget {
  final String? referralCode;

  const ReferralDialog({Key? key, this.referralCode}) : super(key: key);

  @override
  _ReferralDialogState createState() => _ReferralDialogState();
}

class _ReferralDialogState extends State<ReferralDialog> {
  final TextEditingController _codeController = TextEditingController();
  String? _errorText;

  @override
  void initState() {
    super.initState();
    if (widget.referralCode != null) {
      _codeController.text = widget.referralCode!;
    }
  }

  void _submitCode() {
    String enteredCode = _codeController.text.trim();

    if (enteredCode.isEmpty) {
      setState(() {
        _errorText = 'Please enter a referral code';
      });
    } else {
      // Handle the submission of the referral code
      // For example, validate the code and award benefits
      print('Referral Code Submitted: $enteredCode');
      // Close the dialog
      Navigator.of(context).pop();
      // Optionally, navigate to another page or display a success message
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Enter Referral Code'),
      content: TextField(
        controller: _codeController,
        decoration: InputDecoration(
          labelText: 'Referral Code',
          errorText: _errorText,
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitCode,
          child: Text('Submit'),
        ),
      ],
    );
  }
}
