import 'package:flutter/material.dart';

showSnackBar(String content, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(content),
    ),
  );
}

void showAlertDialog(String title, String content, BuildContext context) async {
  String result = await showDialog(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.pop(context, "OK");
            },
          ),
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.pop(context, "Cancel");
            },
          ),
        ],
      );
    },
  );
}
