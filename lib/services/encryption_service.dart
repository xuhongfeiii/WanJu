import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionService {
  static const _keyAlias = 'wanju_aes_key';
  static const _devKeyAlias = 'wanju_dev_key';
  static const _storage = FlutterSecureStorage();
  static encrypt.Key? _cachedKey;
  static String? _cachedDevKey;

  static Future<void> init() async {
    _cachedKey = await _getOrCreateKey();
    _cachedDevKey = await _getOrCreateDevKey();
  }

  static Future<encrypt.Key> _getOrCreateKey() async {
    final existing = await _storage.read(key: _keyAlias);
    if (existing != null) {
      return encrypt.Key.fromBase64(existing);
    }
    final key = encrypt.Key(secureRandom(32));
    await _storage.write(key: _keyAlias, value: key.base64);
    return key;
  }

  static Future<String> _getOrCreateDevKey() async {
    final existing = await _storage.read(key: _devKeyAlias);
    if (existing != null) return existing;
    final code = List.generate(6, (_) => Random.secure().nextInt(10)).join();
    await _storage.write(key: _devKeyAlias, value: code);
    return code;
  }

  static Uint8List secureRandom(int length) {
    final rng = Random.secure();
    return Uint8List.fromList(List<int>.generate(length, (_) => rng.nextInt(256)));
  }

  static String encryptText(String plainText) {
    if (_cachedKey == null) return plainText;
    final iv = encrypt.IV(secureRandom(16));
    final encrypter = encrypt.Encrypter(encrypt.AES(_cachedKey!, mode: encrypt.AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return '${iv.base64}:${encrypted.base64}';
  }

  static String decryptText(String encoded) {
    if (_cachedKey == null) return encoded;
    try {
      final parts = encoded.split(':');
      if (parts.length != 2) return '';
      final iv = encrypt.IV.fromBase64(parts[0]);
      final encrypted = encrypt.Encrypted.fromBase64(parts[1]);
      final encrypter = encrypt.Encrypter(encrypt.AES(_cachedKey!, mode: encrypt.AESMode.cbc));
      return encrypter.decrypt(encrypted, iv: iv);
    } catch (_) {
      return '';
    }
  }

  static String get developerKey => _cachedDevKey ?? '';
}
