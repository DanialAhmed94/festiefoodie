import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../constants/appConstants.dart';
import '../../utilities/dilalogBoxes.dart';
import '../../utilities/sharedPrefs.dart';

String _truncateForLog(String s, [int max = 1500]) {
  if (s.length <= max) return s;
  return '${s.substring(0, max)}… (${s.length} chars total)';
}

/// Turns API-relative paths into an absolute URL for [http.get].
String _absoluteStallImageUrl(String raw) {
  final t = raw.trim();
  if (t.isEmpty) return t;
  final lower = t.toLowerCase();
  if (lower.startsWith('http://') || lower.startsWith('https://')) {
    return t;
  }
  final base = Uri.parse(AppConstants.baseUrl);
  final port = base.hasPort ? ':${base.port}' : '';
  if (t.startsWith('/')) {
    return '${base.scheme}://${base.host}$port$t';
  }
  return '${base.scheme}://${base.host}$port/$t';
}

/// Backend requires `image` on update; re-encode picked file or fetch [existingImageUrl].
Future<void> _populateStallImageField({
  required Map<String, dynamic> stallData,
  required XFile? pickedImage,
  String? existingImageUrl,
  required String bearerToken,
}) async {
  if (pickedImage != null) {
    try {
      final bytes = await pickedImage.readAsBytes();
      stallData['image'] = base64Encode(bytes);
      debugPrint(
        '[updateStallApi] image from new pick, ${bytes.length} bytes',
      );
    } catch (e) {
      debugPrint('[updateStallApi] Error reading picked image: $e');
    }
    return;
  }

  final urlStr = existingImageUrl?.trim() ?? '';
  if (urlStr.isEmpty) {
    debugPrint(
      '[updateStallApi] no new image and existingImageUrl empty — API may reject',
    );
    return;
  }

  final resolved = _absoluteStallImageUrl(urlStr);
  final getUri = Uri.tryParse(resolved);
  if (getUri == null || !getUri.hasScheme) {
    debugPrint('[updateStallApi] invalid image URL after resolve: $resolved');
    return;
  }

  try {
    final headers = <String, String>{
      if (bearerToken.isNotEmpty) 'Authorization': 'Bearer $bearerToken',
    };
    final resp = await http
        .get(getUri, headers: headers)
        .timeout(const Duration(seconds: 30));
    if (resp.statusCode == 200 && resp.bodyBytes.isNotEmpty) {
      stallData['image'] = base64Encode(resp.bodyBytes);
      debugPrint(
        '[updateStallApi] image from existing URL (${resp.bodyBytes.length} bytes)',
      );
    } else {
      debugPrint(
        '[updateStallApi] GET existing image failed status=${resp.statusCode} uri=$getUri',
      );
    }
  } catch (e) {
    debugPrint('[updateStallApi] GET existing image error: $e');
  }
}

/// Updates an existing stall at `POST baseUrl/update_stall/{stallId}` with the
/// same JSON body shape as [store_stall] (stall id is only in the path).
Future<bool> updateStallApi(
  BuildContext context, {
  required String stallId,
  required String festivalId,
  required String eventId,
  required String stallName,
  required String latitude,
  required String longitude,
  required String fromDate,
  required String toDate,
  required String openingTime,
  required String closingTime,
  XFile? image,
  /// When [image] is null, fetched and sent as base64 so servers that require `image` succeed.
  String? existingImageUrl,
}) async {
  final url = Uri.parse('${AppConstants.baseUrl}/update_stall/$stallId');
  final bearerToken = await getToken();

  final Map<String, dynamic> stallData = {
    'festival_id': festivalId,
    'event_id': eventId,
    'stall_name': stallName,
    'latitude': latitude,
    'longitude': longitude,
    'from_date': fromDate,
    'to_date': toDate,
    'opening_time': openingTime,
    'closing_time': closingTime,
  };

  await _populateStallImageField(
    stallData: stallData,
    pickedImage: image,
    existingImageUrl: existingImageUrl,
    bearerToken: bearerToken ?? '',
  );

  try {
    final logPayload = Map<String, dynamic>.from(stallData);
    if (logPayload.containsKey('image')) {
      final im = logPayload['image'];
      logPayload['image'] =
          '<base64 omitted, length=${im is String ? im.length : '?'}>';
    }
    debugPrint('[updateStallApi] POST $url');
    debugPrint('[updateStallApi] JSON body: ${jsonEncode(logPayload)}');

    final response = await http
        .post(
          url,
          headers: {
            'Authorization': 'Bearer $bearerToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(stallData),
        )
        .timeout(const Duration(seconds: 30));

    debugPrint(
      '[updateStallApi] HTTP ${response.statusCode} response: ${_truncateForLog(response.body)}',
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (responseData['status'] == 200) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      responseData['message']?.toString() ??
                          'Stall updated successfully',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFFF96222),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ),
          );
        }
        return true;
      }
      debugPrint(
        '[updateStallApi] Logical failure: JSON status=${responseData['status']} '
        'message=${responseData['message']} data=${responseData['data']}',
      );
      if (context.mounted) {
        showErrorDialog(
          context,
          responseData['message']?.toString() ?? 'Update failed',
          responseData['data'] is List
              ? List<dynamic>.from(responseData['data'] as List)
              : [],
        );
      }
      return false;
    }

    if (response.statusCode == 400) {
      final Map<String, dynamic> responseData =
          jsonDecode(response.body) as Map<String, dynamic>;
      if (context.mounted) {
        showErrorDialog(
          context,
          responseData['message']?.toString() ?? 'Bad request',
          responseData['errors'] is List
              ? List<dynamic>.from(responseData['errors'] as List)
              : [],
        );
      }
      return false;
    }

    if (response.statusCode == 403) {
      final Map<String, dynamic> responseData =
          jsonDecode(response.body) as Map<String, dynamic>;
      if (context.mounted) {
        showErrorDialog(
          context,
          responseData['message']?.toString() ?? 'Access denied',
          responseData['errors'] is List
              ? List<dynamic>.from(responseData['errors'] as List)
              : [],
        );
      }
      return false;
    }

    if (context.mounted) {
      showErrorDialog(
        context,
        'Stall update failed with status code: ${response.statusCode}',
        [],
      );
    }
    return false;
  } on TimeoutException catch (_) {
    debugPrint('[updateStallApi] TimeoutException');
    if (context.mounted) {
      showErrorDialog(
        context,
        'Request timed out. Please try again later.',
        [],
      );
    }
    return false;
  } on http.ClientException catch (e) {
    debugPrint('[updateStallApi] ClientException: $e');
    final errorString = e.toString();
    if (context.mounted) {
      if (errorString.contains('SocketException')) {
        showErrorDialog(
          context,
          'Network error: failed to reach server. Please check your connection.',
          [],
        );
      } else {
        showErrorDialog(
          context,
          'A client error occurred: ${e.message}',
          [],
        );
      }
    }
    return false;
  } catch (error, stack) {
    debugPrint('[updateStallApi] catch: $error');
    debugPrint('[updateStallApi] stack: $stack');
    if (context.mounted) {
      showErrorDialog(
        context,
        'Stall update failed with error: $error',
        [],
      );
    }
    return false;
  }
}
