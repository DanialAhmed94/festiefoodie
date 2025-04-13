import 'package:flutter/material.dart';

import '../annim/transiton.dart';

void showSuccessDialog<T>(
    BuildContext context,
    String message,
    String? choice,
    T navigateTo,
    ) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: choice != null
            ? Text(
          'Failure',
          style: TextStyle(fontWeight: FontWeight.bold),
        )
            : Text(
          'Success',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.left,  // Set text alignment here
              style: TextStyle(
                  fontSize: 12
                // You can define your text style properties here, like fontSize, fontFamily, etc.
              ),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                FadePageRouteBuilder(widget: navigateTo as Widget),
                    (route) => route.isFirst,
              );
            },
          ),
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
        title: Text('Error',style: TextStyle(color: Colors.red),),
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