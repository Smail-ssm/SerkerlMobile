import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../model/client.dart';

class BalancePage extends StatefulWidget {
  final Client? client;

  BalancePage({required this.client});

  @override
  _BalancePageState createState() => _BalancePageState();
}

class _BalancePageState extends State<BalancePage> {
  late double _balance;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _balance = widget.client!.balance  ;
    // Optionally fetch the latest balance from backend
    _fetchBalance();
  }

  // Function to fetch the latest balance from the backend
  Future<void> _fetchBalance() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('https://your-backend-api.com/balance/${widget.client!.userId}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _balance = jsonDecode(response.body)['balance'];
          widget.client!.balance = _balance; // Update client's balance
        });
      } else {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch balance')),
        );
      }
    } catch (e) {
      // Handle exception
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred while fetching balance')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to add funds
  Future<void> _addFunds(double amount) async {
    // Implement payment processing here
    // For this example, we'll simulate adding funds

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://your-backend-api.com/addFunds'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': widget.client?.userId,
          'amount': amount,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _balance += amount  ;
          widget.client?.balance = _balance; // Update client's balance
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Funds added successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add funds')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred while adding funds')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to show add funds dialog
  void _showAddFundsDialog() {
    final _amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Funds"),
          content: TextField(
            controller: _amountController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Amount',
              hintText: 'Enter amount to add',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(_amountController.text);
                if (amount != null && amount > 0) {
                  Navigator.of(context).pop(); // Close dialog
                  _addFunds(amount);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter a valid amount')),
                  );
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // Function to fetch transaction history
  // Future<List<Transaction>> _fetchTransactionHistory() async {
  //   try {
  //     final response = await http.get(
  //       Uri.parse('https://your-backend-api.com/transactions/${widget.client.id}'),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       List transactionsJson = jsonDecode(response.body);
  //       return transactionsJson.map((json) => Transaction.fromJson(json)).toList();
  //     } else {
  //       // Handle error
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Failed to fetch transaction history')),
  //       );
  //       return [];
  //     }
  //   } catch (e) {
  //     // Handle exception
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('An error occurred while fetching transactions')),
  //     );
  //     return [];
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Balance'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _fetchBalance,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            // Display Balance
            Card(
              elevation: 4,
              child: ListTile(
                leading: Icon(Icons.account_balance_wallet, size: 50),
                title: Text(
                  'Current Balance',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '\$${_balance.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 24, color: Colors.green),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.add_circle, color: Colors.blue, size: 30),
                  onPressed: _showAddFundsDialog,
                  tooltip: 'Add Funds',
                ),
              ),
            ),
            SizedBox(height: 20),
            // Transaction History
            Text(
              'Transaction History',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            // FutureBuilder<List<Transaction>>(
            //   future: _fetchTransactionHistory(),
            //   builder: (context, snapshot) {
            //     if (snapshot.connectionState == ConnectionState.waiting) {
            //       return Center(child: CircularProgressIndicator());
            //     } else if (snapshot.hasError || !snapshot.hasData) {
            //       return Center(child: Text('No transactions found.'));
            //     } else {
            //       List<Transaction> transactions = snapshot.data!;
            //       return ListView.builder(
            //         shrinkWrap: true,
            //         physics: NeverScrollableScrollPhysics(),
            //         itemCount: transactions.length,
            //         itemBuilder: (context, index) {
            //           Transaction transaction = transactions[index];
            //           return ListTile(
            //             leading: Icon(
            //               transaction.type == 'credit' ? Icons.arrow_downward : Icons.arrow_upward,
            //               color: transaction.type == 'credit' ? Colors.green : Colors.red,
            //             ),
            //             title: Text(transaction.description),
            //             subtitle: Text(transaction.date),
            //             trailing: Text(
            //               (transaction.type == 'credit' ? '+' : '-') +
            //                   '\$${transaction.amount.toStringAsFixed(2)}',
            //               style: TextStyle(
            //                 color: transaction.type == 'credit' ? Colors.green : Colors.red,
            //                 fontWeight: FontWeight.bold,
            //               ),
            //             ),
            //           );
            //         },
            //       );
            //     }
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}

// Helper class for Transactions
class Transaction {
  final String id;
  final String description;
  final String date;
  final double amount;
  final String type; // 'credit' or 'debit'

  Transaction({
    required this.id,
    required this.description,
    required this.date,
    required this.amount,
    required this.type,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      description: json['description'],
      date: json['date'],
      amount: json['amount'].toDouble(),
      type: json['type'],
    );
  }
}
