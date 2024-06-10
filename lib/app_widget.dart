import 'package:flutter/material.dart';
import 'package:flutter_application_1/scr/controllers/app_controller.dart';
import 'package:flutter_application_1/scr/views/pages/cadastrar_despesa.dart';
import 'package:flutter_application_1/scr/views/pages/home_page.dart';
import 'package:flutter_application_1/scr/views/pages/login_page.dart';

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
          initialRoute: '/home',  // Alterar a rota inicial para '/home'
          routes: {
            '/home': (context) => HomePage(),
            '/cadastro' : (context) => CadastroPage(),
          },
        );
      },
    );
  }
}
