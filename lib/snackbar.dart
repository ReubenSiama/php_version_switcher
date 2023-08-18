import 'package:flutter/material.dart';

SnackBar mySnackbar(String text) {
  return SnackBar(
    backgroundColor: const Color(0XFF3C2A21),
    content: Text(
      text,
      style: const TextStyle(
        color: Color(0XFFD5CEA3),
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
