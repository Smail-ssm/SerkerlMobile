import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../model/client.dart';



class SupportPage extends StatefulWidget {
  final Client? client;

  SupportPage({required this.client});

  @override
  _SupportPageState createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final _formKey = GlobalKey<FormState>();
  String _message = '';
  String _selectedIssue = 'General Inquiry';

  // Function to send message to backend
  Future<bool> _sendMessage() async {
    final response = await http.post(
      Uri.parse('https://your-backend-api.com/support'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': widget.client?.userId,
        'userName': widget.client?.fullName,
        'userEmail': widget.client?.email,
        'issueType': _selectedIssue,
        'message': _message,
      }),
    );

    return response.statusCode == 200;
  }

  // Function to send email using mailto
  void _sendEmail() async {
    final Uri params = Uri(
      scheme: 'mailto',
      path: 'support@yourapp.com',
      query: 'subject=Support Request from ${widget.client?.fullName}&body=Issue Type: $_selectedIssue\n\nMessage:\n$_message',
    );
    var url = params.toString();
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      // Handle the error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch email client')),
      );
    }
  }

  // Function to make a phone call
  void _makePhoneCall() async {
    var url = 'tel:+1234567890'; // Replace with your support phone number
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      // Handle the error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch phone dialer')),
      );
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Show a loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Send message to backend
      _sendMessage().then((success) {
        Navigator.pop(context); // Close the loading indicator
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Message sent successfully!')),
          );
          _formKey.currentState!.reset();
          setState(() {
            _selectedIssue = 'General Inquiry';
            _message = '';
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to send message. Please try again.')),
          );
        }
      }).catchError((error) {
        Navigator.pop(context); // Close the loading indicator
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred. Please try again later.')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Personalized Greeting
            Text(
              'Hello, ${widget.client?.fullName}!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text('How can we assist you today?'),
            const SizedBox(height: 20),
            // Contact Options
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Email: support@yourapp.com'),
              onTap: _sendEmail,
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Phone: +1 234 567 890'),
              onTap: _makePhoneCall,
            ),
            const SizedBox(height: 20),
            // Support Form
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Issue Type Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedIssue,
                    items: [
                      'General Inquiry',
                      'Billing Issue',
                      'Technical Support',
                      'Other',
                    ].map((issue) {
                      return DropdownMenuItem<String>(
                        value: issue,
                        child: Text(issue),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedIssue = value!;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Issue Type',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Email Field (Pre-filled)
                  TextFormField(
                    initialValue: widget.client?.email,
                    decoration: const InputDecoration(
                      labelText: 'Your Email',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true, // Make it read-only if you don't want users to change it
                  ),
                  const SizedBox(height: 10),
                  // Message Field
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Your Message',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your message';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _message = value ?? '';
                    },
                  ),
                  const SizedBox(height: 20),
                  // Submit Button
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text('Send Message'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Optional: FAQ Section
            ExpansionPanelList(
              expansionCallback: (int index, bool isExpanded) {
                setState(() {
                  _faqItems[index].isExpanded = !isExpanded;
                });
              },
              children: _faqItems.map<ExpansionPanel>((FAQItem item) {
                return ExpansionPanel(
                  headerBuilder: (BuildContext context, bool isExpanded) {
                    return ListTile(
                      title: Text(item.question),
                    );
                  },
                  body: ListTile(
                    title: Text(item.answer),
                  ),
                  isExpanded: item.isExpanded,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // Sample FAQ Items
  final List<FAQItem> _faqItems = [
    FAQItem(
      question: 'How do I rent an e-bike?',
      answer: 'To rent an e-bike, navigate to the "Rent" section and select an available bike.',
    ),
    FAQItem(
      question: 'What payment methods are accepted?',
      answer: 'We accept credit cards, debit cards, and popular mobile payment options.',
    ),
    // Add more FAQs as needed
  ];
}

// Helper class for FAQ items
class FAQItem {
  String question;
  String answer;
  bool isExpanded;

  FAQItem({
    required this.question,
    required this.answer,
    this.isExpanded = false,
  });
}
