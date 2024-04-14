import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  int counter = 0;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Switch(
          value: isDarkTheme,
          onChanged: (value) {
            setState(() {
              isDarkTheme = value;
            });
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
        onPressed: () => {
          setState(() {
            counter++;
          }),
        },
      ),
    );
  }
}
