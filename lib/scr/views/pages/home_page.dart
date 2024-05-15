import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/scr/views/pages/cadastrar_despesa.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _expenses = [];
  List<Map<String, dynamic>> _futureExpenses = [];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Image.asset('assets/images/perfil.png', width: 70, height: 70),
              Text(
                'Samara Alves',
                style: TextStyle(fontSize: 18, color: Colors.white),
              )
            ],
          ),
          backgroundColor: Colors.black,
          actions: [
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: 'Home'),
              Tab(text: 'Futuros'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildExpenseList(_expenses),
            _buildExpenseList(_futureExpenses),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          backgroundColor: Colors.red,
          onPressed: () async {
            final Map<String, dynamic>? newExpense = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CadastroPage()),
            );

            if (newExpense != null) {
              if (newExpense['status'] == 1) {
                setState(() {
                  _futureExpenses.add(newExpense['data']);
                  _saveExpenses(_futureExpenses, 'futureExpenses');
                });
              } else {
                setState(() {
                  _expenses.add(newExpense['data']);
                  _saveExpenses(_expenses, 'expenses');
                });
              }
            }
          },
        ),
      ),
    );
  }

  Widget _buildExpenseList(List<Map<String, dynamic>> expenses) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: expenses.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: Key(expenses[index]["id"].toString()),
            onDismissed: (direction) {
              _deleteExpense(index, expenses);
            },
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
            ),
            child: Card(
              margin: const EdgeInsets.all(10),
              color: Color.fromARGB(255, 238, 238, 238),
              child: ListTile(
                leading: Text(expenses[index]["id"].toString()),
                title: Text(expenses[index]["nome"]),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Valor:R ${expenses[index]["valor"]}"),
                    Text("Data: ${expenses[index]["data"]}"),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _deleteExpense(int index, List<Map<String, dynamic>> expenses) async {
    setState(() {
      var deletedExpense = expenses.removeAt(index);
      // Salva a lista atualizada no SharedPreferences após remover a despesa
      if (_expenses.contains(deletedExpense)) {
        _saveExpenses(_expenses, 'expenses');
      } else if (_futureExpenses.contains(deletedExpense)) {
        _saveExpenses(_futureExpenses, 'futureExpenses');
      }
    });
    // Remover a despesa também do SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('expenses', jsonEncode(_expenses));
    await prefs.setString('futureExpenses', jsonEncode(_futureExpenses));
  }

  Future<void> _saveExpenses(List<Map<String, dynamic>> expenses, String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(expenses));
  }

  Future<void> _loadExpenses(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? expensesString = prefs.getString(key);
    print("expensesString ${expensesString}");
    if (expensesString != null) {
      List<Map<String, dynamic>> expenses = jsonDecode(expensesString).cast<Map<String, dynamic>>();
      print("expenses: ${expenses}");
      setState(() {
        if (key == 'expenses') {
          _expenses = expenses;
        } else {
          _futureExpenses = expenses;
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadExpenses('expenses');
    _loadExpenses('futureExpenses');
  }
}