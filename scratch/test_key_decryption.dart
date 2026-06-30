import 'dart:convert';
import 'package:cryptography/cryptography.dart';

void main() async {
  final aes = AesGcm.with256bits();
  final iv = base64Decode('5UX2wY3BUE0pkYUG');
  final authTag = base64Decode('YNvgfDUSrM83dS3RfH/ztA==');
  final cipherText = base64Decode(
    '1H4/+KEUfqIPqnRPHAUrh1/emQeXI1RERxvehdAZkxwAziYIbEoqBWcRzP3TaDtRgmZ+4b/5gwAvSPBa2dTEfkJhFcKsFdsYYMQITIH5MI+Ufh3MgrO0sS/t922OGECbs4+aGNEZsFy0B6wMFha8VML/TvOSuyT32E4='
  );

  final keys = [
    'Zt5oNisH9xsn4aN4jU7k7B9r+P881mB0z9DqW25l1yE=',
    'WB8fPZ8PNOJvqOd6IYC7Z5+r242wIqmuvpvU9FsBmio='
  ];

  for (final k in keys) {
    try {
      print('Trying decryption with key: $k');
      final secretKey = SecretKey(base64Decode(k));
      final secretBox = SecretBox(
        cipherText,
        nonce: iv,
        mac: Mac(authTag),
      );
      final decrypted = await aes.decrypt(secretBox, secretKey: secretKey);
      print('Decrypted bytes: $decrypted');
      print('Decrypted string: ${utf8.decode(decrypted)}');
      print('SUCCESS with key: $k');
      return;
    } catch (e) {
      print('Failed with key $k: $e');
    }
  }
}
