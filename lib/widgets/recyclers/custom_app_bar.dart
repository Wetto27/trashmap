import 'package:flutter/material.dart';

PreferredSizeWidget customAppBar(BuildContext context, String title) {
  return AppBar(
    backgroundColor: const Color(0xFF1B571D),
    centerTitle: true,
    title: Text(
      title,
      style: TextStyle(color: Colors.white),
    ),
  );
}