import 'package:flutter/material.dart';

class RightDrawer extends StatelessWidget {
  final bool isExpanded;
  final Function() onRefresh;
  final Function() onFilter;

  const RightDrawer({Key? key, 
    required this.isExpanded,
    required this.onRefresh,
    required this.onFilter,
  }) : super(key: key);

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
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                    )),
                    const SizedBox(width: 16.0),
                    Expanded(child: FloatingActionButton.extended(
                      onPressed: onFilter,
                      icon: const Icon(Icons.filter_list),
                      label: const Text('Filter'),
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
