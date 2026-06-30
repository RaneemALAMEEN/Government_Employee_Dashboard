import 'dart:convert';
import 'package:crypto/crypto.dart';

void main() {
  final pubKeyBytes = base64Decode('5JMXuKkfC5kMMPmxxN72i/iRmnqjexz+bcPN1PF9J6A=');
  final sha256Val = sha256.convert(pubKeyBytes).toString();
  print('SHA256 of derived public key: $sha256Val');
  // Expected in JSON is: efd763f4c064f8f76bee13ab3a672ba936d88483762c156d58ffd5ea407c77b3
}
