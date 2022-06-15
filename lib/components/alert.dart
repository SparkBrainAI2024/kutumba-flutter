import 'package:flutter/material.dart';

class Alert {
  static successSnackbar(BuildContext context, String message,
      {Duration duration = const Duration(seconds: 3)}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Color.fromARGB(255, 21, 87, 36)),
      ),
      backgroundColor: const Color.fromARGB(255, 212, 237, 218),
      duration: duration,
    ));
  }

  static errorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Color.fromARGB(255, 114, 28, 36)),
      ),
      backgroundColor: const Color.fromARGB(255, 248, 215, 218),
      duration: const Duration(seconds: 3),
    ));
  }
}
