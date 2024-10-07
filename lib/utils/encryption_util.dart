import 'package:encrypt/encrypt.dart';

class EncryptionUtil {
  static final _key =
      Key.fromUtf8('32charlongaeskeythatushldchange!'); // 32 chars
  static final _iv = IV.fromUtf8('16charlongivkey!'); // 16 chars
  static final _encrypter = Encrypter(AES(_key, mode: AESMode.cbc));

  // AES encryption method
  static String encryptAES(String plainText) {
    // Encrypt the plain text and return as a base64-encoded string
    final encrypted = _encrypter.encrypt(plainText, iv: _iv);
    return encrypted.base64; // Convert to base64 string
  }

  // AES decryption method
  static String decryptAES(String encryptedData) {
    // Decrypt the base64-encoded string
    return _encrypter.decrypt64(encryptedData, iv: _iv);
  }
}
