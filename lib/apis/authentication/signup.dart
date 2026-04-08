import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/appConstants.dart';
import '../../services/firestore_user_service.dart';
import '../../utilities/dilalogBoxes.dart';
import '../../views/foodieStall/authViews/loginView.dart';

/// True only when the signup API reports success with a payload we can trust.
/// Avoids writing to Firestore on HTTP 200 with error bodies or incomplete data.
bool _isSignupApiSuccess(Map<String, dynamic> responseData) {
  final code = responseData['code'];
  if (code != 200 && code != '200') return false;

  final data = responseData['data'];
  if (data is! Map) return false;

  final user = data['user'];
  if (user is! Map) return false;
  if (user['id'] == null) return false;

  final nested = data['response'];
  if (nested is! Map) return false;
  final token = nested['token'];
  if (token == null) return false;
  if (token is String && token.isEmpty) return false;

  return true;
}

/// Writes the chat `users/{id}` doc **only** when the REST signup call is a confirmed success.
/// Call this from nowhere else; guards are duplicated so refactors cannot skip checks by mistake.
Future<void> _syncFirestoreChatUserAfterSignupApiSuccess({
  required int httpStatus,
  required Map<String, dynamic> responseData,
}) async {
  if (httpStatus != 200 && httpStatus != 201) {
    debugPrint(
        'Firestore: skipped chat user sync (HTTP $httpStatus, not success)');
    return;
  }
  if (!_isSignupApiSuccess(responseData)) {
    debugPrint(
        'Firestore: skipped chat user sync (response is not confirmed signup success)');
    return;
  }

  try {
    final userData = responseData['data']['user'] as Map;
    final userId = userData['id'].toString();
    final userName = userData['name'];
    final phoneNumber = userData['phone'];

    await FirestoreUserService.createOrUpdateUser(
      userId: userId,
      phoneNumber: phoneNumber,
      userName: userName,
      registeredFromApp: AppConstants.firebaseRegistrationAppId,
    );

    print('✅ User created in Firestore for chat functionality');
  } catch (e) {
    print('⚠️ Warning: Failed to create user in Firestore: $e');
  }
}

/// Returns `true` only when the backend signup succeeded and the success UI was shown.
/// Returns `false` for any HTTP error, validation failure, timeout, or network error.
Future<bool> signUp(
    BuildContext context,
    String fullName,
    String email,
    String phone,
    Future<List<String>> images,
    String organization,
    String organization_address,
    String password) async {
  final url = Uri.parse("${AppConstants.baseUrl}/authup");

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String? deviceId= await prefs.getString("fcm_token");

  List<String> uploadedImages = await images;
  final Map<String, dynamic> signUpData = {
    'name': fullName,
    'email': email,
    'phone': phone,
    'password': password,
    'organization_name': organization,
    'organization_address': organization_address,
    'image': uploadedImages.isNotEmpty ? uploadedImages[0] : null,
    'image2': uploadedImages.length > 1 ? uploadedImages[1] : null,
    'image3': uploadedImages.length > 2 ? uploadedImages[2] : null,
    'app_type':"festiefoodie",
    'device_token': deviceId,
  };

  try {
    // Send the POST request with a timeout
    final response = await http
        .post(
      url,
      headers: {
        'Content-Type': 'application/json', // Set the content type to JSON
      },
      body: jsonEncode(signUpData), // Encode the data to JSON format
    )
        .timeout(const Duration(seconds: 30)); // Set a timeout duration

    debugPrint('Signup API: statusCode=${response.statusCode}');
    debugPrint('Signup API: body=${response.body}');

    // Handle the response — Firestore only after full success (HTTP 200/201 + body shape).
    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (_isSignupApiSuccess(responseData)) {
        // Signup successful — Firestore only via guarded helper (HTTP 200 + full success body).
        print('Signup successful: ${responseData['message']}');
        print('Token: ${responseData['data']['response']['token']}');
        print('User: ${responseData['data']['user']}');

        await _syncFirestoreChatUserAfterSignupApiSuccess(
          httpStatus: response.statusCode,
          responseData: responseData,
        );

        showSuccessDialog(context,"Your account has been created successfully!",null,LoginView());
        return true;
      } else {
        // HTTP 200 but business error, wrong code, or incomplete payload — no Firestore.
        final msg = responseData['message']?.toString() ?? 'Signup failed';
        final errors = responseData['errors'];
        showErrorDialog(
          context,
          msg,
          errors is List ? errors : [],
        );
        return false;
      }
    } else if (response.statusCode == 400) {
      // Handle client-side errors (e.g., validation failed)
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      showErrorDialog(context, responseData['message'], responseData['errors']);
      return false;
    } else {
      // Handle other HTTP errors
      showErrorDialog(context,
          "Signup failed with status code: ${response.statusCode}", []);
      return false;
    }
  } on TimeoutException catch (_) {
    showErrorDialog(context, "Request timed out. Please try again later.", []);
    return false;
  }on ClientException catch (e) {
    final errorString = e.toString(); // or e.message

    // Check if it contains "SocketException"
    if (errorString.contains('SocketException')) {
      // Handle the wrapped SocketException here
      showErrorDialog(
        context,
        "Network error: failed to reach server. Please check your connection.",
        [],
      );
      return false;
    } else {
      // Otherwise handle any other client exception
      showErrorDialog(
        context,
        "A client error occurred: ${e.message}",
        [],
      );
      return false;
    }
  } catch (error) {
    showErrorDialog(context, "Signup failed with error: $error", []);
    return false;
  }
}




