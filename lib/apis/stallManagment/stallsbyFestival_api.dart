import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../constants/appConstants.dart';
import '../../models/allStallsCollectionModel.dart';
import '../../utilities/dilalogBoxes.dart';
import '../../utilities/sharedPrefs.dart';

Future<StallCollectionResponse?> getStallsByFestival(
    BuildContext context,
    String festivalId, {
      required bool isfromReviewSection,
    }) async {
  final url = isfromReviewSection
      ? Uri.parse("${AppConstants.baseUrl}/stalls-all?festival_id=$festivalId")
      : Uri.parse("${AppConstants.baseUrl}/stalls-by-festival?festival_id=$festivalId");

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
      final jsonResponse = jsonDecode(response.body);
      debugPrint("Full JSON: $jsonResponse");
      return StallCollectionResponse.fromJson(jsonResponse);
    } else {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      if (response.statusCode == 400) {
        showErrorDialog(context, responseData['message'], responseData['errors']);
      } else if (response.statusCode == 403) {
        showExpiredAccountErrorDialog(
            context, responseData['message'], responseData['errors']);
      } else {
        showErrorDialog(context,
            "Stall fetching failed with status code: ${response.statusCode}", []);
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
    showErrorDialog(context, "Stall fetching failed with error: $error", []);
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

// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import '../../constants/appConstants.dart';
// import '../../models/allStallsCollectionModel.dart';
// import '../../utilities/dilalogBoxes.dart';
// import '../../utilities/sharedPrefs.dart';
//
// Future<StallCollectionResponse?> getStallsByFestival(
//     BuildContext context, String festivalId,
//     {required bool isfromReviewSection}) async {
//   // Update the endpoint URL as per your backend.
//   // For example, if your API accepts a query parameter:
//   final url = Uri.parse(
//       "${AppConstants.baseUrl}/stalls-by-festival?festival_id=$festivalId");
//   final bearerToken = await getToken(); // Fetch the bearer token
//   debugPrint(" auth token ${bearerToken} ");
//
//   try {
//     final response = await http.get(
//       url,
//       headers: {
//         'Authorization': 'Bearer $bearerToken',
//         'Content-Type': 'application/json',
//       },
//     ).timeout(const Duration(seconds: 30));
//
//     if (response.statusCode == 200) {
//       final jsonResponse = jsonDecode(response.body);
//       final stallResponse = StallCollectionResponse.fromJson(jsonResponse);
//       debugPrint("Full JSON: $jsonResponse");
//       return stallResponse;
//     } else if (response.statusCode == 400) {
//       final Map<String, dynamic> responseData = jsonDecode(response.body);
//       showErrorDialog(context, responseData['message'], responseData['errors']);
//       return null;
//     } else if (response.statusCode == 403) {
//       final Map<String, dynamic> responseData = jsonDecode(response.body);
//       showExpiredAccountErrorDialog(
//           context, responseData['message'], responseData['errors']);
//       return null;
//     } else {
//       showErrorDialog(context,
//           "Stall fetching failed with status code: ${response.statusCode}", []);
//       return null;
//     }
//   } on TimeoutException catch (_) {
//     showErrorDialog(context, "Request timed out. Please try again later.", []);
//     return null;
//   } on http.ClientException catch (e) {
//     final errorString = e.toString();
//     if (errorString.contains('SocketException')) {
//       showErrorDialog(
//         context,
//         "Network error: failed to reach server. Please check your connection.",
//         [],
//       );
//     } else {
//       showErrorDialog(context, "A client error occurred: ${e.message}", []);
//     }
//     return null;
//   } catch (error) {
//     debugPrint("exception: $error, auth token ${bearerToken} ");
//     showErrorDialog(context, "Stall fetching failed with error: $error", []);
//     return null;
//   }
// }
//
// void showExpiredAccountErrorDialog(
//     BuildContext context, String message, List<dynamic> errors) {
//   showDialog(
//     barrierDismissible: false,
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: Text('Error'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(message),
//             if (errors.isNotEmpty)
//               Column(
//                 children: errors
//                     .map((error) => Text(
//                           error.toString(),
//                           style: TextStyle(color: Colors.red),
//                         ))
//                     .toList(),
//               ),
//           ],
//         ),
//         actions: <Widget>[
//           // Optionally add action buttons if needed.
//         ],
//       );
//     },
//   );
// }
