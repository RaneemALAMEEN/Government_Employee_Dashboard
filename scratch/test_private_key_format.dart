import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

// Simple hex decoder since we don't have hex package
Uint8List hexDecode(String hex) {
  final bytes = Uint8List(hex.length ~/ 2);
  for (var i = 0; i < bytes.length; i++) {
    final slice = hex.substring(i * 2, i * 2 + 2);
    bytes[i] = int.parse(slice, radix: 16);
  }
  return bytes;
}

void main() async {
  final hexString = '3c2160816ef8013e3ebdb04242ee2a3e44c390beb4dc27c4208b55d7a6fc3859';
  
  final algorithm = Ed25519();

  // Test hex decoding
  try {
    final privateKeyBytesHex = hexDecode(hexString);
    final keyPairHex = await algorithm.newKeyPairFromSeed(privateKeyBytesHex);
    final pubKeyHex = await keyPairHex.extractPublicKey();
    print('Hex decoded public key base64: ${base64Encode(pubKeyHex.bytes)}');
    // Expected PEM public key raw bytes base64 is: 6dCIpX6BrmT8IzG85cIziBnFc2tY/8aBbvmJuTKc9/g=
  } catch (e) {
    print('Hex error: $e');
  }

  // Test base64 decoding
  try {
    final privateKeyBytesB64 = base64Decode(hexString);
    final keyPairB64 = await algorithm.newKeyPairFromSeed(privateKeyBytesB64);
    final pubKeyB64 = await keyPairB64.extractPublicKey();
    print('Base64 decoded public key base64: ${base64Encode(pubKeyB64.bytes)}');
  } catch (e) {
    print('Base64 error: $e');
  }
}
