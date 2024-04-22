import 'dart:developer';

import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionService {
  static final key = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1');

  static String encryptMessage(String message) {
    final iv = encrypt.IV.fromLength(16); // Generate IV
    final encrypter = encrypt.Encrypter(encrypt.AES(key,padding: null));

    final encrypted = encrypter.encrypt(message, iv: iv); // Include IV during encryption
    return '${encrypted.base64}:${iv.base64}'; // Combine ciphertext and IV
  }

  static String decryptMessage(String encryptedText) {
    final parts = encryptedText.split(':');

    // Check if parts contains at least two elements
    if (parts.length < 2) {
      throw const FormatException('Invalid encrypted text format');
    }

    final encryptedBase64 = parts[0];
    final ivBase64 = parts[1];

    final encrypter = encrypt.Encrypter(encrypt.AES(key,padding: null));
    final decrypted = encrypter.decrypt64(encryptedBase64, iv: encrypt.IV.fromBase64(ivBase64)); // Provide IV during decryption
    return decrypted;
  }

}
