import 'package:flutter/material.dart';
import 'package:flutter_application_1/home_page.dart';

class AppWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.red,
        brightness: Brightness.light,
        ),
      home: HomePage(),
    );
  }
}
