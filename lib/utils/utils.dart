import 'package:flutter/material.dart';

class WidgetsCatalog{

  /// Dialog
  static void androidDialog({
    required String title,
    required String content,
    required GestureTapCallback onTapNo,
    required GestureTapCallback onTapYes,
    required BuildContext context,
  }) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                  onPressed: onTapNo,
                  child: const Text("Cancel")),
              TextButton(
                  onPressed: onTapYes,
                  child: const Text("Confirm"))
            ],
          );
        });
  }

  /// drawer Item
  static  Widget createDrawerItem(
      {required IconData icon,
        required String text,
        required GestureTapCallback onTap}) {
    return ListTile(
      title: Row(
        children: <Widget>[
          Icon(icon),
          Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Text(text),
          )
        ],
      ),
      onTap: onTap,
    );
  }}