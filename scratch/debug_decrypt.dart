import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:pointycastle/pointycastle.dart' as pc;

void main() async {
  print('=== DEBUG DECRYPT TEST ===');
  
  // 1. Read files
  final encFile = File('D:\\keys\\employee-key.enc');
  final metaFile = File('D:\\keys\\employee-key.meta.json');
  
  final encContent = (await encFile.readAsString()).trim();
  print('Enc file content (base64): $encContent');
  print('Enc file base64 length: ${encContent.length}');
  
  final encBytes = base64Decode(encContent);
  print('Enc file decoded byte length: ${encBytes.length}');
  
  final meta = jsonDecode(await metaFile.readAsString()) as Map<String, dynamic>;
  print('Metadata: $meta');
  
  // 2. Parse metadata
  final salt = base64Decode(meta['salt'].toString());
  print('Salt length: ${salt.length}');
  
  final ivStr = meta['iv']?.toString() ?? '';
  print('IV string: "$ivStr"');
  
  // Try base64 decode for IV
  Uint8List nonce;
  try {
    nonce = base64Decode(ivStr);
    print('IV decoded as base64, length: ${nonce.length}');
  } catch (e) {
    // Maybe it's hex?
    print('IV base64 decode failed: $e');
    nonce = Uint8List.fromList(utf8.encode(ivStr));
    print('IV as UTF-8 bytes, length: ${nonce.length}');
  }
  
  final authTagStr = meta['auth_tag']?.toString() ?? '';
  final authTagBytes = base64Decode(authTagStr);
  print('Auth tag length: ${authTagBytes.length}');
  
  // 3. Derive key using scrypt
  final kdfParams = meta['kdf_params'] as Map<String, dynamic>;
  final n = kdfParams['N'] as int;
  final r = kdfParams['r'] as int;
  final p = kdfParams['p'] as int;
  final keyLen = kdfParams['keyLen'] as int;
  
  print('Scrypt params: N=$n, r=$r, p=$p, keyLen=$keyLen');
  
  // Use a test PIN - replace with actual PIN
  const pin = '123456'; // placeholder
  
  final derivator = pc.KeyDerivator('scrypt');
  final params = pc.ScryptParameters(n, r, p, keyLen, salt);
  derivator.init(params);
  final derivedKeyBytes = derivator.process(Uint8List.fromList(utf8.encode(pin)));
  
  print('Derived key length: ${derivedKeyBytes.length}');
  print('Derived key (hex): ${derivedKeyBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}');
  
  // 4. Try decrypt
  final aes = AesGcm.with256bits();
  
  // The .enc file might have ciphertext only (auth_tag is separate in metadata)
  // OR the .enc file might have ciphertext + auth_tag appended
  
  // Option A: cipherText = entire enc content, mac from metadata
  print('\n--- Option A: enc = ciphertext only, auth_tag from metadata ---');
  try {
    final secretBox = SecretBox(
      encBytes,
      nonce: nonce,
      mac: Mac(authTagBytes),
    );
    
    final decrypted = await aes.decrypt(
      secretBox,
      secretKey: SecretKey(derivedKeyBytes),
    );
    
    final decryptedStr = utf8.decode(decrypted);
    print('SUCCESS! Decrypted string length: ${decryptedStr.length}');
    print('Decrypted (first 20 chars): ${decryptedStr.substring(0, decryptedStr.length > 20 ? 20 : decryptedStr.length)}...');
  } catch (e) {
    print('Option A FAILED: $e');
  }
  
  // Option B: last 16 bytes of enc are auth_tag, rest is ciphertext
  if (encBytes.length > 16) {
    print('\n--- Option B: enc = ciphertext + auth_tag (last 16 bytes) ---');
    try {
      final cipherOnly = encBytes.sublist(0, encBytes.length - 16);
      final embeddedMac = encBytes.sublist(encBytes.length - 16);
      
      print('CipherText length: ${cipherOnly.length}');
      print('Embedded MAC length: ${embeddedMac.length}');
      print('Embedded MAC matches metadata auth_tag: ${_bytesEqual(embeddedMac, authTagBytes)}');
      
      final secretBox = SecretBox(
        cipherOnly,
        nonce: nonce,
        mac: Mac(embeddedMac),
      );
      
      final decrypted = await aes.decrypt(
        secretBox,
        secretKey: SecretKey(derivedKeyBytes),
      );
      
      final decryptedStr = utf8.decode(decrypted);
      print('SUCCESS! Decrypted string length: ${decryptedStr.length}');
      print('Decrypted (first 20 chars): ${decryptedStr.substring(0, decryptedStr.length > 20 ? 20 : decryptedStr.length)}...');
    } catch (e) {
      print('Option B FAILED: $e');
    }
  }
  
  // Option C: IV might be raw bytes string, not base64
  print('\n--- Option C: IV as raw UTF-8 bytes (not base64) ---');
  try {
    final rawNonce = Uint8List.fromList(utf8.encode(ivStr));
    print('Raw IV byte length: ${rawNonce.length}');
    
    final secretBox = SecretBox(
      encBytes,
      nonce: rawNonce,
      mac: Mac(authTagBytes),
    );
    
    final decrypted = await aes.decrypt(
      secretBox,
      secretKey: SecretKey(derivedKeyBytes),
    );
    
    final decryptedStr = utf8.decode(decrypted);
    print('SUCCESS! Decrypted string: $decryptedStr');
  } catch (e) {
    print('Option C FAILED: $e');
  }
  
  print('\n=== DEBUG COMPLETE ===');
}

bool _bytesEqual(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
