import 'dart:convert';
import 'dart:io';
import 'dart:async'; // For TimeoutException

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../annim/transiton.dart';
import '../constants/appConstants.dart';
import '../utilities/dilalogBoxes.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../views/foodieReview/foodieReviewHome.dart';

Future<void> submitReview(
    BuildContext context,
    String name,
    String date,
    Map<String, int> scores,
    File? image1,
    File? image2,
    String menuId,
    ) async {
  final url = Uri.parse("${AppConstants.baseUrl}/dish-feedback/$menuId");

  // Convert images to Base64 if available
  String? base64Image1 = await compressAndConvertToBase64(image1, quality: 70);
  String? base64Image2 = await compressAndConvertToBase64(image2, quality: 70);

  var body = {
    "customer_name": name,
    "review_date": date,
    "cleanliness_score": scores["Cleanliness"],
    "taste_and_flavour": scores["Tate & Flavour"],
    "presentation_score": scores["Presentation & Plating"],
    "quality_score": scores["Quality & Freshness Of Ingredients"],
    "authenticity_score": scores["Authenticity & Creativity"],
    "cooking_score": scores["Cooking Techniques & Temperature"],
    "freshness_score": scores["Freshness"],
    "dinning_score": scores["Dining Experience"],
    "value_score": scores["Value For Money"],
    "hygiene_score": scores["Hygiene"],
    "picture_1": base64Image1,
    "picture_2": base64Image2
  };

  try {
    // Add a timeout duration to handle slower network responses
    final response = await http
        .post(
      url,
      headers: {
        'Content-Type': 'application/json',

      },
      body: jsonEncode(body),
    )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseData['message'] ?? 'Review submitted')),
      );

      Navigator.pushAndRemoveUntil(
          context,
          FadePageRouteBuilder(
            widget:FoodieReviewHomeMap(),
          ),
              (route) => false);
    } else if (response.statusCode == 400) {
      // If backend sends an error array or message for 400
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      showErrorDialog(context, responseData['message'], responseData['errors']);
    } else {
      // Catch-all for other status codes (e.g. 500, 404, etc.)
      showErrorDialog(
        context,
        "Failed to submit review with status code: ${response.statusCode}",
        [],
      );
      debugPrint("Failed to submit review: ${response.statusCode}");
      debugPrint(response.body);
    }
  } on TimeoutException catch (_) {
    // Specifically handle request timeout
    showErrorDialog(
      context,
      "Request timed out. Please try again later.",
      [],
    );
  } on http.ClientException catch (e) {
    // Specifically check if it’s a network error (SocketException)
    final errorString = e.toString();
    if (errorString.contains('SocketException')) {
      showErrorDialog(
        context,
        "Network error: failed to reach server. Please check your connection.",
        [],
      );
    } else {
      showErrorDialog(
        context,
        "A client error occurred: ${e.message}",
        [],
      );
    }
  } catch (error) {
    // Catch any other errors
    showErrorDialog(
      context,
      "Review submission failed with error: $error",
      [],
    );
  }
}

/// Compress the provided [imageFile] to the specified [quality], then convert it to Base64.
/// If [imageFile] is null, returns null.
Future<String?> compressAndConvertToBase64(File? imageFile, {int quality = 70}) async {
  if (imageFile == null) return null;

  // Read original bytes
  final originalBytes = await imageFile.readAsBytes();

  // Compress in-memory to desired quality (0-100)
  final compressedBytes = await FlutterImageCompress.compressWithList(
    originalBytes,
    quality: quality,
  );

  // Convert compressed bytes to Base64
  return base64Encode(compressedBytes);
}

