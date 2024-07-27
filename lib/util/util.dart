import 'dart:convert';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void showMessageDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Message'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

String getFirestoreDocument() {
  return kDebugMode ? 'preprod' : 'prod';
}

Future<void> saveSP(String variable, String value) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(variable, value);
}

// Method to check if an email address is valid
bool isValidEmail(String email) {
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  return emailRegex.hasMatch(email);
}

enum EncryptionMode { encrypt, decrypt }

Future<String> encryptDecryptText(
  String text,
  EncryptionMode mode,
) async {
  final remoteConfig = FirebaseRemoteConfig.instance;
  await remoteConfig.setConfigSettings(RemoteConfigSettings(
    fetchTimeout: const Duration(minutes: 1),
    minimumFetchInterval: const Duration(hours: 1),
  ));
  await remoteConfig.fetchAndActivate(); // Fetch and activate latest values

  final key = remoteConfig.getString('encryption_key');

  if (key == null || key.isEmpty) {
    return Future.error('Encryption key not found in Remote Config');
  }

  try {
    final keyObject = encrypt.Key.fromUtf8('RAGGADAsmailssm50+');
    final randomBytes = keyObject.bytes.sublist(0, 16); // 128-bit random value

    final crypter = encrypt.Encrypter(
        encrypt.AES(encrypt.Key(randomBytes), mode: encrypt.AESMode.cbc));

    return mode == EncryptionMode.encrypt
        ? base64.encode(
            crypter.encrypt(text, iv: encrypt.IV.fromSecureRandom(16)).bytes)
        : crypter.decrypt64(text, iv: encrypt.IV.fromLength(16));
  } catch (e) {
    return Future.error(
        'Error during ${mode == EncryptionMode.encrypt ? 'encryption' : 'decryption'}: $e');
  }
}
