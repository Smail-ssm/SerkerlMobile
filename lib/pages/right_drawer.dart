import 'package:flutter/material.dart';

class RightDrawer extends StatelessWidget {
  final bool isExpanded;
  final Function() onRefresh;
  final Function() onFilter;

  RightDrawer({
    required this.isExpanded,
    required this.onRefresh,
    required this.onFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          ExpansionTile(
            title: const Text('Options'),
            leading: const Icon(Icons.settings),
            initiallyExpanded: isExpanded,
            onExpansionChanged: (expanding) {
              // Handle expansion change
            },
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: FloatingActionButton.extended(
                      onPressed: onRefresh,
                      icon: Icon(Icons.refresh),
                      label: Text('Refresh'),
                    )),
                    SizedBox(width: 16.0),
                    Expanded(child: FloatingActionButton.extended(
                      onPressed: onFilter,
                      icon: Icon(Icons.filter_list),
                      label: Text('Filter'),
                    )),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
