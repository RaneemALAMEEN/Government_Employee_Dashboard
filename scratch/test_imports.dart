import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:pointycastle/pointycastle.dart' as pc;

void main() {
  final scrypt = pc.KeyDerivator('scrypt');
  final params = pc.ScryptParameters(16384, 8, 1, 32, Uint8List(16));
  scrypt.init(params);
  print('Success! Pointycastle Scrypt initialized with prefix.');
}
