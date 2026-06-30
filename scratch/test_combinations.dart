import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

void main() async {
  final aes = AesGcm.with256bits();
  final keyBytes = base64Decode('WB8fPZ8PNOJvqOd6IYC7Z5+r242wIqmuvpvU9FsBmio=');
  final secretKey = SecretKey(keyBytes);

  final iv = base64Decode('5UX2wY3BUE0pkYUG');
  final metaTag = base64Decode('YNvgfDUSrM83dS3RfH/ztA==');
  final fullCipherText = base64Decode(
    '1H4/+KEUfqIPqnRPHAUrh1/emQeXI1RERxvehdAZkxwAziYIbEoqBWcRzP3TaDtRgmZ+4b/5gwAvSPBa2dTEfkJhFcKsFdsYYMQITIH5MI+Ufh3MgrO0sS/t922OGECbs4+aGNEZsFy0B6wMFha8VML/TvOSuyT32E4='
  );

  print('Full cipherText length: ${fullCipherText.length} bytes');

  // Combo 1: Full cipherText, tag from metadata
  try {
    print('Combo 1: Full cipherText, metadata tag');
    final secretBox = SecretBox(fullCipherText, nonce: iv, mac: Mac(metaTag));
    final decrypted = await aes.decrypt(secretBox, secretKey: secretKey);
    print('SUCCESS Combo 1! Decrypted: ${utf8.decode(decrypted)}');
    return;
  } catch (e) {
    print('Combo 1 failed: $e');
  }

  // Combo 2: Sliced cipherText (exclude last 16 bytes), last 16 bytes as tag
  if (fullCipherText.length > 16) {
    final slicedCipher = fullCipherText.sublist(0, fullCipherText.length - 16);
    final slicedTag = fullCipherText.sublist(fullCipherText.length - 16);
    try {
      print('Combo 2: Sliced cipherText (excluding last 16 bytes), sliced tag');
      final secretBox = SecretBox(slicedCipher, nonce: iv, mac: Mac(slicedTag));
      final decrypted = await aes.decrypt(secretBox, secretKey: secretKey);
      print('SUCCESS Combo 2! Decrypted: ${utf8.decode(decrypted)}');
      return;
    } catch (e) {
      print('Combo 2 failed: $e');
    }

    // Combo 3: Sliced cipherText, metadata tag
    try {
      print('Combo 3: Sliced cipherText (excluding last 16 bytes), metadata tag');
      final secretBox = SecretBox(slicedCipher, nonce: iv, mac: Mac(metaTag));
      final decrypted = await aes.decrypt(secretBox, secretKey: secretKey);
      print('SUCCESS Combo 3! Decrypted: ${utf8.decode(decrypted)}');
      return;
    } catch (e) {
      print('Combo 3 failed: $e');
    }
  }
}
