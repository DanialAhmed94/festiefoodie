import 'dart:async';

import 'package:http/http.dart' as http;

/// User-facing copy for festival search failures (no raw SocketException text).
String messageForFestivalSearchFailure(Object error) {
  if (error is TimeoutException) {
    return 'Request timed out. Check your connection and try again.';
  }
  if (error is http.ClientException) {
    final msg = error.message;
    if (msg.contains('SocketException') ||
        msg.contains('Failed host lookup') ||
        msg.contains('Network is unreachable')) {
      return 'No internet connection. Check your network and try again.';
    }
    return 'Could not reach the server. Please try again.';
  }

  final s = error.toString();
  final lower = s.toLowerCase();
  final type = error.runtimeType.toString().toLowerCase();

  if (type.contains('socket') ||
      lower.contains('socketexception') ||
      lower.contains('clientexception') ||
      lower.contains('failed host lookup') ||
      lower.contains('network is unreachable') ||
      lower.contains('connection refused') ||
      lower.contains('connection reset')) {
    return 'No internet connection. Check your network and try again.';
  }
  if (type.contains('handshake') ||
      type.contains('tlsexception') ||
      lower.contains('handshake') ||
      lower.contains('certificate')) {
    return 'Secure connection failed. Check your network and try again.';
  }
  if (lower.contains('timeoutexception') ||
      lower.contains('timed out') ||
      lower.contains('time out')) {
    return 'Request timed out. Check your connection and try again.';
  }
  if (s.contains('Failed to load festivals')) {
    return 'Could not load search results. Please try again.';
  }

  return 'Something went wrong. Please try again.';
}
