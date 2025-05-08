import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../constants/appConstants.dart';
import '../../models/menuModel.dart';
import '../../utilities/dilalogBoxes.dart';
import '../../utilities/sharedPrefs.dart';

Future<Menu?> getMenuByStall(
    BuildContext context,
    String stallId, {
      required bool isfromReviewSection,
    }) async {
  final url = isfromReviewSection
      ? Uri.parse("${AppConstants.baseUrl}/dishes-by-stall-all?stall_id=$stallId")
      : Uri.parse("${AppConstants.baseUrl}/dishes-by-stall-all?stall_id=$stallId");

  Map<String, String> headers = {
    'Content-Type': 'application/json',
  };

  if (!isfromReviewSection) {
    final bearerToken = await getToken();
    debugPrint("auth token $bearerToken");
    headers['Authorization'] = 'Bearer $bearerToken';
  }

  try {
    final response = await http.get(url, headers: headers).timeout(
      const Duration(seconds: 30),
    );

    if (response.statusCode == 200) {
      final bearerToken = await getToken();

      final jsonResponse = jsonDecode(response.body);
      debugPrint("Full JSON: $jsonResponse");
      debugPrint("auth token: $bearerToken");
      return Menu.fromJson(jsonResponse);
    } else {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      if (response.statusCode == 400) {
        showErrorDialog(context, responseData['message'], responseData['errors']);
      } else if (response.statusCode == 403) {
        showExpiredAccountErrorDialog(
            context, responseData['message'], responseData['errors']);
      } else {
        showErrorDialog(context,
            "Menu fetching failed with status code: ${response.statusCode}", []);
      }
      return null;
    }
  } on TimeoutException catch (_) {
    showErrorDialog(context, "Request timed out. Please try again later.", []);
    return null;
  } on http.ClientException catch (e) {
    final errorString = e.toString();
    if (errorString.contains('SocketException')) {
      showErrorDialog(
        context,
        "Network error: failed to reach server. Please check your connection.",
        [],
      );
    } else {
      showErrorDialog(context, "A client error occurred: ${e.message}", []);
    }
    return null;
  } catch (error) {
    debugPrint("exception: $error");
    showErrorDialog(context, "Menu fetching failed with error: $error", []);
    return null;
  }
}

void showExpiredAccountErrorDialog(
    BuildContext context, String message, List<dynamic> errors) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Error'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message),
            if (errors.isNotEmpty)
              Column(
                children: errors
                    .map((error) => Text(
                  error.toString(),
                  style: const TextStyle(color: Colors.red),
                ))
                    .toList(),
              ),
          ],
        ),
      );
    },
  );
}
