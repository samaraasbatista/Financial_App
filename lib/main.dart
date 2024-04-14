import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePageApp(),
    );
  }
}

class HomePageApp extends StatefulWidget {
  const HomePageApp({super.key});

  @override
  State<HomePageApp> createState() => _BottomNavigationBarExampleState();
}

class _BottomNavigationBarExampleState extends State<HomePageApp> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle = TextStyle(fontSize: 35, fontWeight: FontWeight.bold);
  static final List<Widget> _widgetOptions = <Widget>[
    HomeWidget(

    ),
    UpdateBalance(
      
    ),
    RegisterExpenses(

    )
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial App DEMO'),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.autorenew),
            label: 'Alterar Saldo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Cadastrar Despesa',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeWidget extends StatelessWidget { 
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text(
          "Tela principal, saldo total da pessoa e ordens dos gastos",
          textDirection: TextDirection.ltr,
        ),),
    );
    throw UnimplementedError();
  }
  
}

class RegisterExpenses extends StatelessWidget { 
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text(
          "Tela para cadastrar as despesas do usuario",
          textDirection: TextDirection.ltr,
        ),),
    );
    throw UnimplementedError();
  }
  
}

class UpdateBalance extends StatelessWidget { 
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text(
          "Tela para alterar o saldo",
          textDirection: TextDirection.ltr,
        ),),
    );
    throw UnimplementedError();
  }
  
}
