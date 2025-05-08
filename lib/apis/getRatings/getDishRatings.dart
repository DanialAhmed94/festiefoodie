import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../constants/appConstants.dart';
import '../../models/raringsModel.dart';
import '../../utilities/dilalogBoxes.dart';
import '../../utilities/sharedPrefs.dart';
import '../authentication/login.dart';

Future<DishReviewResponse?> getDishRatings(
    BuildContext context, String dishId, {int page = 1}) async {
  final url = Uri.parse(
    "${AppConstants.baseUrl}/dish-feedback/$dishId?page=$page",
  );

  Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${await getToken()}',
  };

  try {
    final response = await http.get(url, headers: headers).timeout(
      const Duration(seconds: 30),
    );

    final jsonResponse = jsonDecode(response.body);
    debugPrint("Dish Ratings Response: $jsonResponse");

    if (response.statusCode == 200) {
      // Case 1: With paginated reviews
      if (jsonResponse.containsKey('reviews') && jsonResponse['reviews'] != null) {
        return DishReviewResponse.fromJson(jsonResponse);
      }

      // Case 2: Flat list in 'data' (no pagination)
      if (jsonResponse.containsKey('data')) {
        return DishReviewResponse.fromJson({
          "status": jsonResponse['status'],
          "message": jsonResponse['message'],
          "reviews": null, // explicitly null to indicate flatData is used
          "flat_data": jsonResponse['data'], // custom key in model
        });
      }

      // Fallback
      return null;
    } else {
      final message = jsonResponse['message'] ?? "Something went wrong";
      final errors = jsonResponse['errors'] ?? [];

      if (response.statusCode == 400) {
        showErrorDialog(context, message, errors);
      }
      else if (response.statusCode == 403) {
        showExpiredAccountErrorDialog(context, message, errors);
      }
      else {
        showErrorDialog(
          context,
          "Dish ratings fetching failed with status code: ${response.statusCode}",
          [],
        );
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
    debugPrint("Exception: $error");
    showErrorDialog(context, "Dish ratings fetch failed: $error", []);
    return null;
  }
}
