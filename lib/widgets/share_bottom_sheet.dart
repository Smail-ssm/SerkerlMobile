import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import '../util/theme.dart';
import '../util/util.dart';

class ShareBottomSheet extends StatefulWidget {
  final String userId;

  const ShareBottomSheet({Key? key, required this.userId}) : super(key: key);

  @override
  _ShareBottomSheetState createState() => _ShareBottomSheetState();
}

class _ShareBottomSheetState extends State<ShareBottomSheet> {
  bool _isExpanded = false;
  String? _referralCode;
  String _deepLink = ''; // Variable to store the deep link

  @override
  void initState() {
    super.initState();
    _loadReferralCode(widget.userId);
  }

  Future<void> _loadReferralCode(String userId) async {
    String? code = await fetchOrGenerateReferralCode(userId);
    if (code != null) {
      setState(() {
        _referralCode = code.trimLeft().trimRight();
        // Generate the deep link using the referral code and your server's URL
        _deepLink = 'www.serkellinks.000.pe/index.php?code=$code';
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Referral code could not be generated')),
      );
    }
  }

  Future<String?> fetchOrGenerateReferralCode(String userId) async {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final String env = getFirestoreDocument(); // Get environment (e.g., 'preprod')
    try {
      DocumentSnapshot userDoc = await _firestore
          .collection(env)
          .doc('users')
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        String? existingReferralCode = userDoc['referralCode'];

        if (existingReferralCode != null && existingReferralCode.isNotEmpty) {
          return existingReferralCode;
        } else {
          String newReferralCode = userId.substring(0, 6).toUpperCase(); // Example code generation
          await _firestore
              .collection(env)
              .doc('users')
              .collection('users')
              .doc(userId)
              .update({'referralCode': newReferralCode});

          return newReferralCode;
        }
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching or generating referral code: $e');
      return null;
    }
  }

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
                  _loadReferralCode(widget.userId);
                },
                child: const Text('Get 1x free 20 min ride!'),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
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
                    if (_deepLink.isNotEmpty) {
                      FlutterClipboard.copy(_deepLink).then(
                              (value) => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Referral link copied to clipboard!')),
                          ));
                    }
                  },
                  child: Text(
                    _referralCode != null
                        ? '$_referralCode'
                        : 'Loading...', // Show the referral code or loading text
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (_deepLink.isNotEmpty) {
                    Share.share(
                        'Join this awesome app! Use my referral link: $_deepLink and get 20 minutes of free rides!');
                  }
                },
                child: const Text('Share with friends'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
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
void showShareBottomSheet(BuildContext context, String userId) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return ShareBottomSheet(userId: userId);
    },
  );
}
