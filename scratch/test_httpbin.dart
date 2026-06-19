import 'dart:io';
import 'dart:convert';

void main() async {
  final client = HttpClient();
  client.badCertificateCallback = (cert, host, port) => true;

  client.connectionFactory = (Uri uri, String? proxyHost, int? proxyPort) async {
    final host = proxyHost ?? uri.host;
    final port = proxyPort ?? uri.port;
    print("[DNS Bypass] Resolving $host...");
    final List<InternetAddress> addresses;
    try {
      addresses = await InternetAddress.lookup(host, type: InternetAddressType.IPv4);
    } catch (e) {
      print("[DNS Bypass] Lookup failed: $e");
      final socketFuture = Socket.connect(host, port);
      return ConnectionTask.fromSocket(
        uri.scheme == 'https'
            ? socketFuture.then((socket) => SecureSocket.secure(socket, host: host, onBadCertificate: (cert) => true))
            : socketFuture,
        () {},
      );
    }
    
    if (addresses.isEmpty) {
      print("[DNS Bypass] No addresses");
      final socketFuture = Socket.connect(host, port);
      return ConnectionTask.fromSocket(
        uri.scheme == 'https'
            ? socketFuture.then((socket) => SecureSocket.secure(socket, host: host, onBadCertificate: (cert) => true))
            : socketFuture,
        () {},
      );
    }
    
    print("[DNS Bypass] Connecting to ${addresses.first.address}:$port...");
    final socketFuture = Socket.connect(addresses.first, port);
    
    if (uri.scheme == 'https') {
      final secureSocketFuture = socketFuture.then((socket) {
        print("[DNS Bypass] Upgrading to SecureSocket with SNI host: $host...");
        return SecureSocket.secure(socket, host: host, onBadCertificate: (cert) => true);
      });
      return ConnectionTask.fromSocket(secureSocketFuture, () {});
    }
    
    return ConnectionTask.fromSocket(socketFuture, () {});
  };
  
  try {
    print("Making request to https://httpbin.org/get...");
    final request = await client.getUrl(Uri.parse("https://httpbin.org/get"));
    final response = await request.close();
    print("Response status: ${response.statusCode}");
    final body = await response.transform(utf8.decoder).join();
    print("Response body length: ${body.length}");
    print("Success!");
  } catch (e) {
    print("Request failed: $e");
  }
}
