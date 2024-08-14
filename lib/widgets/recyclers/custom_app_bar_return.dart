import 'package:flutter/material.dart';

PreferredSizeWidget customAppBarReturn(BuildContext context, String title) {
  return AppBar(
    backgroundColor: const Color(0xFF1B571D),
    centerTitle: true,
    title: Text(
      title,
      style: TextStyle(color: Colors.white),
    ),
    leading: IconButton(
      icon: Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () => Navigator.of(context).pop(),
    ),
    iconTheme: IconThemeData(color: Colors.white),
  );
}