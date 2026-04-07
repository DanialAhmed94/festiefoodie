import 'dart:async';
import 'dart:convert';
import 'dart:io'; // Import for SocketException

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import '../../constants/appConstants.dart';
import '../../models/festivalModel.dart';
import '../../utilities/sharedPrefs.dart';

Uri _buildFestivalListUri({int page = 1, String? search}) {
  var urlStr = '${AppConstants.baseUrl}/getfestival?page=$page';
  if (search != null && search.trim().isNotEmpty) {
    urlStr += '&search=${Uri.encodeComponent(search.trim())}';
  }
  return Uri.parse(urlStr);
}

Future<FestivalResponse?> getFestivalCollection(
  BuildContext context, {
  int page = 1,
  String? search,
}) async {
  final url = _buildFestivalListUri(page: page, search: search);
  const timeoutDuration = Duration(seconds: 30); // Define a timeout duration

  try {
    final bearerToken = await getToken();
    final headers = {
      'Authorization': 'Bearer $bearerToken',
      'Content-Type': 'application/json',
    };

    // Debug: log full request
    debugPrint('');
    debugPrint('📤 ═══════════════ FESTIVALS API REQUEST ═══════════════');
    debugPrint('📤 method: GET');
    debugPrint('📤 url: $url');
    debugPrint('📤 headers: Authorization=Bearer $bearerToken, Content-Type=${headers['Content-Type']}');
    debugPrint('📤 ═══════════════════════════════════════════════════════');
    debugPrint('');

    final response = await http.get(
      url,
      headers: headers,
    ).timeout(timeoutDuration);

    // Debug: log complete response
    final isSuccess = response.statusCode == 200;
    debugPrint('');
    debugPrint('📥 ═══════════════ FESTIVALS API RESPONSE ═══════════════');
    debugPrint('📥 statusCode: ${response.statusCode} ${isSuccess ? "✓" : "✗"}');
    debugPrint('📥 headers: ${response.headers}');
    debugPrint('📥 body: ${response.body}');
    debugPrint('📥 ═══════════════════════════════════════════════════════');
    debugPrint('');

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final festivalResponse = FestivalResponse.fromJson(data);
      debugPrint('✅ FESTIVALS API parsed: message=${festivalResponse.message}, data.length=${festivalResponse.data.length}');
      return festivalResponse;
    } else if (response.statusCode == 403) {
      _tryParseAndShowExpiredError(context, response.body);
    } else {
      _tryParseAndShowError(context, response.statusCode, response.body);
    }
  } on TimeoutException catch (_) {
    final connectivity = await Connectivity().checkConnectivity();
    final hasConnection = connectivity != ConnectivityResult.none;

    if (hasConnection) {
      final isInternetSlow = !(await _hasGoodConnection());
      if (isInternetSlow) {
        showErrorDialog(context, "Slow internet connection detected.", []);
      } else {
        showErrorDialog(context, "Server is taking too long to respond.", []);
      }
    } else {
      showErrorDialog(context, "No internet connection.", []);
    }
  } on SocketException catch (_) {
    // Handle internet connectivity issues
    showErrorDialog(context,
        "No Internet connection. Please check your network and try again.", []);
  } on ClientException catch (e) {
    final errorString = e.toString(); // or e.message

    // Check if it contains "SocketException"
    if (errorString.contains('SocketException')) {
      // Handle the wrapped SocketException here
      showErrorDialog(
        context,
        "Network error: failed to reach server. Please check your connection.",
        [],
      );
    } else {
      // Otherwise handle any other client exception
      showErrorDialog(
        context,
        "A client error occurred: ${e.message}",
        [],
      );
    }
  }catch (error) {
    // Handle any other exceptions
    showErrorDialog(context,
        "An unexpected error occurred while fetching festivals: $error", []);
    print("Error fetching festivals: $error");
  }
}

/// Same `/getfestival` endpoint with optional server-side [search] and [page].
/// Does not show dialogs; throws so map/search UIs can handle errors locally.
Future<FestivalResponse> fetchFestivalsWithQuery({
  int page = 1,
  String? search,
}) async {
  final url = _buildFestivalListUri(page: page, search: search);
  const timeoutDuration = Duration(seconds: 30);

  final bearerToken = await getToken();
  final headers = {
    'Authorization': 'Bearer $bearerToken',
    'Content-Type': 'application/json',
  };

  final response =
      await http.get(url, headers: headers).timeout(timeoutDuration);

  if (response.statusCode == 200) {
    final data = json.decode(response.body) as Map<String, dynamic>;
    return FestivalResponse.fromJson(data);
  }
  throw Exception('Failed to load festivals (${response.statusCode})');
}

void _tryParseAndShowExpiredError(BuildContext context, String body) {
  try {
    final trimmed = body.trim();
    if (trimmed.startsWith('{')) {
      final data = jsonDecode(body) as Map<String, dynamic>;
      final message = data['message']?.toString() ?? 'Access denied';
      final errors = data['errors'];
      showExpiredAccountErrorDialog(
        context,
        message,
        errors is List ? List<dynamic>.from(errors as List) : [],
      );
      return;
    }
  } catch (_) {}
  showExpiredAccountErrorDialog(context, 'Access denied.', []);
}

void _tryParseAndShowError(BuildContext context, int statusCode, String body) {
  try {
    final trimmed = body.trim();
    if (trimmed.startsWith('{')) {
      final data = json.decode(body) as Map<String, dynamic>;
      final message = data['message']?.toString() ?? 'Request failed';
      final errors = data['errors'];
      showErrorDialog(
        context,
        message,
        errors is List ? List<dynamic>.from(errors as List) : [],
      );
      return;
    }
  } catch (_) {}
  final message = statusCode >= 500
      ? 'Server error ($statusCode). Please try again later.'
      : 'Request failed ($statusCode).';
  showErrorDialog(context, message, []);
}

Future<bool> _hasGoodConnection() async {
  try {
    final response = await http
        .get(
      Uri.parse('https://www.google.com'),
    )
        .timeout(Duration(seconds: 2));
    return true;
  } catch (_) {
    return false;
  }
}

void showExpiredAccountErrorDialog(
    BuildContext context, String message, List<dynamic> errors) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Error'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message),
            if (errors.isNotEmpty)
              Column(
                children: errors
                    .map((error) => Text(error.toString(),
                    style: TextStyle(color: Colors.red)))
                    .toList(),
              ),
          ],
        ),
        actions: <Widget>[
          // TextButton(
          //   child: Text('Cancel'),
          //   onPressed: () {
          //     Navigator.of(context).pop();
          //   },
          // ),
          // TextButton(
          //   child: Text('Upgrade'),
          //   onPressed: () {
          //     Navigator.pushAndRemoveUntil(
          //       context,
          //       FadePageRouteBuilder(
          //         widget: BotomPremiumView(),
          //       ),
          //           (Route<dynamic> route) => false,
          //     );
          //   },
          // ),
        ],
      );
    },
  );
}

void showErrorDialog(
    BuildContext context, String message, List<dynamic> errors) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Error'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message),
            if (errors.isNotEmpty)
              Column(
                children: errors
                    .map((error) => Text(error.toString(),
                    style: TextStyle(color: Colors.red)))
                    .toList(),
              ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
