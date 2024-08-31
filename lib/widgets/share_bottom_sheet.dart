// lib/share_bottom_sheet.dart
import 'package:flutter/material.dart';

import '../util/theme.dart';

class ShareBottomSheet extends StatefulWidget {
  final String promoCode;

  const ShareBottomSheet({required this.promoCode});

  @override
  _ShareBottomSheetState createState() => _ShareBottomSheetState();
}

class _ShareBottomSheetState extends State<ShareBottomSheet> {
  bool _isExpanded = false; // Track the dropdown state

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: colors['Light Grey'],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                'Get free rides',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: colors['Charcoal']!.withOpacity(0.7)),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.center,
              child: Text(
                'Spread the love',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: colors['Charcoal']!.withOpacity(0.7)),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.center,
              child: Text(
                'Share your personal code with friends — after they take their first ride, you both get 1 free!',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: colors['Charcoal']!.withOpacity(0.7)),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Handle 'Get 1x free 20 min ride!' button press
                },
                child: const Text('Get 1x free 20 min ride!'),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded; // Toggle dropdown state
                  });
                },
                child: Text(
                  _isExpanded ? 'Hide how it works' : 'Show how it works',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: colors['Steel Blue'], fontWeight: FontWeight.bold),
                ),
              ),
            ),
            if (_isExpanded) ...[
              const SizedBox(height: 16),
              _buildStep(context, '1', 'Invite friends by sharing your code',
                  'They sign up with your shared link, or by pasting the promo code below into the app'),
              _buildStep(context, '2', 'They hit the road with Dott',
                  'They enjoy 1x free 20 min ride, unlock included'),
              _buildStep(context, '3', 'You earn free rides!',
                  'You get 1x free 20 min ride, just like your friend'),
            ],
            const SizedBox(height: 16),
            Center(
              child: Container(
                padding: const EdgeInsets.all(8),
                child: ElevatedButton(
                  onPressed: () {
                    // Placeholder for share functionality
                  },
                  child: Text(
                    widget.promoCode,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Placeholder for share functionality
                },
                child: const Text('Share with friends'),
                style: ElevatedButton.styleFrom(
                  minimumSize:
                      const Size(double.infinity, 48), // Button width to match parent
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context, String stepNumber, String title,
      String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: colors['Light Grey'],
            child: Text(
              stepNumber,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: colors['Charcoal']!.withOpacity(0.7)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Method to build the bottom sheet with dropdown
void showShareBottomSheet(BuildContext context, String promoCode) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return ShareBottomSheet(promoCode: promoCode);
    },
  );
}
