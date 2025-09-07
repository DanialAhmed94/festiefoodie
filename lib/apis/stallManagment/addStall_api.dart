import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../annim/transiton.dart';
import '../../constants/appConstants.dart';
import '../../models/menuItemModel.dart';
import '../../utilities/dilalogBoxes.dart';
import '../../utilities/sharedPrefs.dart';
import '../../views/foodieStall/foofieStallHome.dart';

// Assuming MenuItem is defined as in your UI code:

Future<void> addStallApi(
  BuildContext context, {
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
  List<MenuItem>? menuItems,
}) async {
  // Update the endpoint URL as per your backend
  final url = Uri.parse("${AppConstants.baseUrl}/store_stall");
  final bearerToken = await getToken(); // Fetch the bearer token

  // Prepare the data to be sent
  Map<String, dynamic> stallData = {
    "festival_id": festivalId,
    "event_id": eventId,
    "stall_name": stallName,
    "latitude": latitude,
    "longitude": longitude,
    "from_date": fromDate,
    "to_date": toDate,
    "opening_time": openingTime,
    "closing_time": closingTime,
  };

  // If an image is provided, convert it to Base64 and add to the payload
  if (image != null) {
    try {
      final bytes = await image.readAsBytes();
      stallData["image"] = base64Encode(bytes);
    } catch (error) {
      print("Error processing image: $error");
    }
  }

  // Include menu items if they have been added
  // Include menu items if they have been added
  if (menuItems != null && menuItems.isNotEmpty) {
    List<Map<String, dynamic>> menuData = [];

    for (var item in menuItems) {
      // Combine currency symbol with price
      String priceWithCurrency =
          "${item.currencySymbol}${item.priceController.text}";

      Map<String, dynamic> menuItemData = {
        "dish_name": item.dishNameController.text,
        "price": priceWithCurrency,
      };

      // Add dish image only if provided
      if (item.selectedImage != null && item.isImageSelected) {
        try {
          final bytes = await item.selectedImage!.readAsBytes();
          menuItemData["dish_image"] = base64Encode(bytes);
        } catch (error) {
          print("Error processing menu item image: $error");
          // Optional: remove error dialog since image is not required
        }
      }

      menuData.add(menuItemData);
    }

    stallData["menu"] = menuData;
  }

  try {
    debugPrint("stall data $stallData");
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

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData['status'] == 200) {
        // Show success message with brand styling
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    responseData['message'] ?? "Stall created successfully",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFF96222), // Brand orange color
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
        // Navigate to the FoodieStallHome (or any other desired screen)
        Navigator.pushAndRemoveUntil(
            context,
            FadePageRouteBuilder(
              widget: FoodieStallHome(),
            ),
            (route) => false);
      } else {
        // Show error dialog if the API indicates failure
        showErrorDialog(context, responseData['message'], responseData['data']);
      }
    } else if (response.statusCode == 400) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      showErrorDialog(context, responseData['message'], responseData['errors']);
    } else if (response.statusCode == 403) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      showExpiredAccountErrorDialog(
          context, responseData['message'], responseData['errors']);
    } else {
      showErrorDialog(context,
          "Stall creation failed with status code: ${response.statusCode}", []);
    }
  } on TimeoutException catch (_) {
    showErrorDialog(context, "Request timed out. Please try again later.", []);
  } on http.ClientException catch (e) {
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
    showErrorDialog(context, "Stall creation failed with error: $error", []);
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
          // Optionally add action buttons if needed
        ],
      );
    },
  );
}
