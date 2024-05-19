import 'package:financial_app/scr/controllers/app_controller.dart';
import 'package:financial_app/scr/views/pages/cadastrar_despesa.dart';
import 'package:financial_app/scr/views/pages/home_page.dart';
import 'package:financial_app/scr/views/pages/login_page.dart';
import 'package:flutter/material.dart';

class AppWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppController.instance,
      builder: (context, child) {
        return MaterialApp(
          theme: ThemeData(
            primarySwatch: Colors.red,
            brightness: AppController.instance.isDarkTheme
                ? Brightness.dark
                : Brightness.light,
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => LoginPage(),
            '/home': (context) => HomePage(),
            '/cadastro' : (context) => CadastroPage(),
          },
        );
      },
    );
  }
}
