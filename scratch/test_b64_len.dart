import 'dart:convert';

void main() {
  final hexStr = '3c2160816ef8013e3ebdb04242ee2a3e44c390beb4dc27c4208b55d7a6fc3859';
  final bytes = base64Decode(hexStr);
  print('String length: ${hexStr.length}');
  print('Bytes length: ${bytes.length}');
}
