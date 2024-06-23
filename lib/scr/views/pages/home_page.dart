import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cadastar_tipo_receita.dart';
import 'cadastrar_despesa.dart';
import 'cadastrar_receita.dart';
import 'cadastrar_tipo_despesa.dart';
import 'calculadora_juros_compostos.dart';


import 'components/transaction_list.dart';
import 'components/future_transaction_list.dart';
import 'relatorio_grafico.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _transactions = [];
  String _selectedType = 'Todos';
  DateTime? _selectedDate;
  DateTimeRange? _selectedDateRange;
  double _totalBalance = 0.00;
  List<String> _tiposDespesas = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _calculateTotalBalance() {
    setState(() {
      DateTime now = DateTime.now();
      double incomeSum = _transactions
          .where((item) {
            DateTime transactionDate = DateFormat('dd/MM/yyyy').parse(item['data']);
            return (item['tipo'] == 'Salário' || item['tipo'] == 'Freelance' || item['tipo'] == 'Presente' || item['tipo'] == 'Outros') &&
                   (transactionDate.isBefore(now) || transactionDate.isAtSameMomentAs(now));
          })
          .fold(0.0, (sum, item) => sum + (item['valor'] ?? 0.0));
      double expenseSum = _transactions
          .where((item) {
            DateTime transactionDate = DateFormat('dd/MM/yyyy').parse(item['data']);
            return !(item['tipo'] == 'Salário' || item['tipo'] == 'Freelance' || item['tipo'] == 'Presente' || item['tipo'] == 'Outros') &&
                   (transactionDate.isBefore(now) || transactionDate.isAtSameMomentAs(now));
          })
          .fold(0.0, (sum, item) => sum + (item['valor'] ?? 0.0));
      _totalBalance = incomeSum - expenseSum;
    });
  }

  void _saveTransactions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> transactionList = _transactions.map((transaction) => jsonEncode(transaction)).toList();
    await prefs.setStringList('transactions', transactionList);
    _calculateTotalBalance();
    _updateTiposDespesas();
  }

  void _loadTransactions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? transactionList = prefs.getStringList('transactions');
    if (transactionList != null) {
      setState(() {
        _transactions = transactionList.map((transaction) => jsonDecode(transaction) as Map<String, dynamic>).toList();
        _calculateTotalBalance();
        _updateTiposDespesas();
      });
    }
  }

  void _deleteTransaction(int index) {
    setState(() {
      Map<String, dynamic> removedTransaction = _transactions.removeAt(index);
      _saveTransactions();
    });
  }

  void _updateTiposDespesas() {
    setState(() {
      _tiposDespesas = _transactions.map((transaction) => transaction['tipo'] as String).toSet().toList();
      _tiposDespesas.insert(0, 'Todos'); // Adiciona a opção 'Todos' no início
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Image.asset('assets/images/perfil.png', width: 70, height: 70),
              const Text(
                'Samara Alves',
                style: TextStyle(fontSize: 18, color: Colors.white),
              )
            ],
          ),
          backgroundColor: Colors.black,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Home'),
              Tab(text: 'Futuros'),
            ],
          ),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.black,
                ),
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.calculate),
                title: const Text('Calculadora Juros Compostos'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CalculadoraJurosCompostosPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.category),
                title: const Text('Cadastrar Tipo de Despesa'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CadastroTipoDespesaPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.category),
                title: const Text('Cadastrar Tipo de Receita'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CadastroTipoReceitaPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.bar_chart),
                title: const Text('Gráfico de Transações'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GraficoPage(transactions: _transactions)),
                  );
                },
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.black,
              width: double.infinity,
              child: Text(
                'R\$ $_totalBalance',
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  TransactionList(
                    transactions: _transactions,
                    selectedType: _selectedType,
                    selectedDateRange: _selectedDateRange,
                    tiposDespesas: _tiposDespesas,
                    onDeleteTransaction: _deleteTransaction,
                    onSelectedTypeChanged: (String newValue) {
                      setState(() {
                        _selectedType = newValue;
                      });
                    },
                    onSelectedDateRangeChanged: (DateTimeRange? pickedDateRange) {
                      setState(() {
                        _selectedDateRange = pickedDateRange;
                        _selectedDate = null;
                      });
                    },
                    onClearDateSelection: () {
                      setState(() {
                        _selectedDate = null;
                        _selectedDateRange = null;
                      });
                    },
                    onClearFilters: () {
                      setState(() {
                        _selectedType = 'Todos';
                        _selectedDate = null;
                        _selectedDateRange = null;
                      });
                    },
                  ),
                  FutureTransactionList(transactions: _transactions, totalBalance: _totalBalance),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              backgroundColor: Colors.green,
              onPressed: () async {
                final Map<String, dynamic>? newIncome = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CadastroIncomePage()),
                );

                if (newIncome != null) {
                  setState(() {
                    _transactions.add(newIncome);
                    _saveTransactions();
                  });
                }
              },
              heroTag: 'incomeButton',
              child: const Icon(Icons.add), // Unique heroTag
            ),
            const SizedBox(height: 10),
            FloatingActionButton(
              backgroundColor: Colors.red,
              onPressed: () async {
                final Map<String, dynamic>? newTransaction = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CadastroPage()),
                );

                if (newTransaction != null) {
                  setState(() {
                    _transactions.add(newTransaction);
                    _saveTransactions();
                  });
                }
              },
              heroTag: 'expenseButton',
              child: const Icon(Icons.remove), // Unique heroTag
            ),
          ],
        ),
      ),
    );
  }
}