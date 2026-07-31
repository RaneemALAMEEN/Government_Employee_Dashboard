import 'package:flutter_dotenv/flutter_dotenv.dart';

String buildAbsoluteFileUrl(String pathOrUrl) {
  final trimmed = pathOrUrl.trim();
  if (trimmed.isEmpty) return '';
  if (trimmed.startsWith(RegExp(r'https?://'))) return trimmed;

  var baseUrl = dotenv.env['BASE_URL']?.trim() ?? '';
  if (baseUrl.isEmpty) {
    baseUrl = const String.fromEnvironment(
      'BASE_URL',
      defaultValue: 'http://10.0.2.2:5000',
    );
  }
  baseUrl = baseUrl.replaceFirst(RegExp(r'/+$'), '');
  final path = trimmed.replaceAll('\\', '/');
  return '$baseUrl${path.startsWith('/') ? path : '/$path'}';
}
