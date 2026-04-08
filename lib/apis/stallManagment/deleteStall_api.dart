import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../constants/appConstants.dart';
import '../../utilities/dilalogBoxes.dart';
import '../../utilities/sharedPrefs.dart';

/// Deletes a stall via `GET baseUrl/delete_stall/{stallId}`.
Future<bool> deleteStallApi(BuildContext context, int stallId) async {
  final url = Uri.parse('${AppConstants.baseUrl}/delete_stall/$stallId');
  final token = await getToken() ?? '';

  try {
    final response = await http
        .get(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;
      if (data['status'] == 200) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                data['message']?.toString() ?? 'Stall deleted successfully',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              backgroundColor: const Color(0xFFF96222),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return true;
      }
      if (context.mounted) {
        showErrorDialog(
          context,
          data['message']?.toString() ?? 'Delete failed',
          data['errors'] is List
              ? List<dynamic>.from(data['errors'] as List)
              : data['data'] is List
                  ? List<dynamic>.from(data['data'] as List)
                  : [],
        );
      }
      return false;
    }

    Map<String, dynamic> responseData;
    try {
      responseData = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      responseData = {};
    }
    if (context.mounted) {
      showErrorDialog(
        context,
        responseData['message']?.toString() ??
            'Delete failed (${response.statusCode})',
        responseData['errors'] is List
            ? List<dynamic>.from(responseData['errors'] as List)
            : [],
      );
    }
    return false;
  } on TimeoutException catch (_) {
    if (context.mounted) {
      showErrorDialog(
        context,
        'Request timed out. Please try again later.',
        [],
      );
    }
    return false;
  } on http.ClientException catch (e) {
    if (context.mounted) {
      final msg = e.toString();
      showErrorDialog(
        context,
        msg.contains('SocketException')
            ? 'Network error: check your connection.'
            : 'A client error occurred: ${e.message}',
        [],
      );
    }
    return false;
  } catch (e) {
    if (context.mounted) {
      showErrorDialog(context, 'Delete failed: $e', []);
    }
    return false;
  }
}
