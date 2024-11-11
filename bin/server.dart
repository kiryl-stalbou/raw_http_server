import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:raw_http_server/utils.dart';

void main() async {
  final ServerSocket serverSocket = await ServerSocket.bind(InternetAddress.anyIPv6, 80);

  serverSocket.listen(_onClientConnection);

  print('Listening on ${serverSocket.address.address}:${serverSocket.port}\n\n');
}

Future<void> _onClientConnection(Socket socket) async {
  print('Connection from ${socket.remoteAddress.address}:${socket.remotePort}\n\n');

  try {
    await for (final Uint8List bytes in socket) {
      final String request = String.fromCharCodes(bytes);
      final String response = await _handleHttpRequest(request);
      return socket.add(utf8.encode(response));
    }
  } finally {
    await socket.flush();
    await socket.close();
  }
}

Future<String> _handleHttpRequest(String request) async {
  print('Request:\n$request\n\n');

  final String method = request.split(' ')[0];

  String response = await switch (method) {
    'GET' => _handleHttpGetRequest(request),
    _ => _handleHttpUnknownRequest(request),
  };

  print('Response:\n$response\n\n');

  return response;
}

Future<String> _handleHttpGetRequest(String request) async {
  final String path = Uri.decodeFull(request.split(' ')[1].substring(1));
  final File file = File(path);

  if (!(await file.exists())) {
    return createHttpResponse(
      statusCode: 404,
      statusMessage: 'Not Found',
      headers: {'Content-Type': 'text/plain'},
      body: utf8.encode('404 Not Found'),
    );
  }

  final Uint8List bytes = await file.readAsBytes();

  return createHttpResponse(
    statusCode: 200,
    statusMessage: 'OK',
    headers: <String, String>{
      'Content-Type': contentTypeOf(file.path),
      'Content-Length': bytes.length.toString(),
      'Content-Disposition': 'attachment; filename="${file.uri.pathSegments.last}"',
      'Connection': 'close',
    },
    body: bytes,
  );
}

Future<String> _handleHttpUnknownRequest(String request) async {
  return createHttpResponse(
    statusCode: 405,
    statusMessage: 'Method Not Allowed',
    headers: {'Content-Type': 'text/plain'},
    body: utf8.encode('405 Method Not Allowed'),
  );
}
