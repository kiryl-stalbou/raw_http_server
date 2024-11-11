import 'dart:typed_data';

String createHttpResponse({
  required int statusCode,
  required String statusMessage,
  required Map<String, String> headers,
  required Uint8List body,
}) {
  final String headerString = headers.entries
      .map((entry) => '${entry.key}: ${entry.value}')
      .join('\r\n');

  final String bodyString = String.fromCharCodes(body);

  return 'HTTP/1.1 $statusCode $statusMessage\r\n$headerString\r\n\r\n$bodyString';
}

String contentTypeOf(String filePath) {
  final String fileType = filePath.split('.').last.toLowerCase();

  switch (fileType) {
    case 'txt':
      return 'text/plain';
    case 'html':
      return 'text/html';
    case 'css':
      return 'text/css';
    case 'js':
      return 'application/javascript';
    case 'json':
      return 'application/json';
    case 'png':
      return 'image/png';
    case 'jpg':
    case 'jpeg':
      return 'image/jpeg';
    case 'gif':
      return 'image/gif';
    case 'pdf':
      return 'application/pdf';
    default:
      return 'application/octet-stream';
  }
}
