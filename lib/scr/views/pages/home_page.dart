import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cadastrar_despesa.dart';
import 'cadastrar_receita.dart';
import 'calculadora_juros_compostos.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _transactions = [];
  List<Map<String, dynamic>> _incomes = [];
  String _selectedType = 'Todos';
  DateTime? _selectedDate;
  DateTimeRange? _selectedDateRange;
  double _totalBalance = 0.00;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _calculateTotalBalance() {
    setState(() {
      double incomeSum = _incomes.fold(0.0, (sum, item) => sum + item['valor']);
      double expenseSum = _transactions.fold(0.0, (sum, item) => sum + item['valor']);
      _totalBalance = _totalBalance + incomeSum - expenseSum;
    });
  }

  void _saveTransactions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> transactionList = _transactions.map((transaction) => jsonEncode(transaction)).toList();
    List<String> incomeList = _incomes.map((income) => jsonEncode(income)).toList();
    await prefs.setStringList('transactions', transactionList);
    await prefs.setStringList('incomes', incomeList);
    _calculateTotalBalance();
  }

  void _loadTransactions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? transactionList = prefs.getStringList('transactions');
    List<String>? incomeList = prefs.getStringList('incomes');
    if (transactionList != null) {
      setState(() {
        _transactions = transactionList.map((transaction) => jsonDecode(transaction) as Map<String, dynamic>).toList();
      });
    }
    if (incomeList != null) {
      setState(() {
        _incomes = incomeList.map((income) => jsonDecode(income) as Map<String, dynamic>).toList();
        _calculateTotalBalance();
      });
    }
  }

  void _deleteTransaction(int index, bool isIncome) {
    setState(() {
      if (isIncome) {
        _incomes.removeAt(index);
      } else {
        _transactions.removeAt(index);
      }
      _saveTransactions();
    });
  }

  String _formatDate(String date) {
    DateTime parsedDate = DateFormat('dd/MM/yyyy').parse(date);
    return DateFormat('yyyy-MM-dd').format(parsedDate);
  }

  List<Map<String, dynamic>> _getHomeTransactions() {
    DateTime now = DateTime.now();
    return _transactions.where((transaction) {
      DateTime transactionDate = DateFormat('dd/MM/yyyy').parse(transaction['data']);
      return transactionDate.isBefore(now) || transactionDate.isAtSameMomentAs(now);
    }).toList();
  }

  List<Map<String, dynamic>> _getFutureTransactions() {
    DateTime now = DateTime.now();
    return _transactions.where((transaction) {
      DateTime transactionDate = DateFormat('dd/MM/yyyy').parse(transaction['data']);
      return transactionDate.isAfter(now);
    }).toList();
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
                  _buildTransactionList(_getHomeTransactions(), false),
                  _buildTransactionList(_getFutureTransactions(), false),
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
                    _incomes.add(newIncome);
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

  Widget _buildTransactionList(List<Map<String, dynamic>> transactions, bool isIncome) {
    List<Map<String, dynamic>> filteredTransactions = transactions.where((transaction) {
      bool matchesType = _selectedType == 'Todos' || transaction['tipo'] == _selectedType;
      bool matchesDate = true;
      if (_selectedDate != null) {
        matchesDate = transaction['data'] == DateFormat('dd/MM/yyyy').format(_selectedDate!);
      }
      if (_selectedDateRange != null) {
        DateTime transactionDate = DateFormat('dd/MM/yyyy').parse(transaction['data']);
        matchesDate = transactionDate.isAfter(_selectedDateRange!.start) && transactionDate.isBefore(_selectedDateRange!.end);
      }
      return matchesType && matchesDate;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedType,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedType = newValue!;
                    });
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Tipo',
                  ),
                  items: <String>[
                    'Todos',
                    'Saúde e Bem-Estar',
                    'Streamings',
                    'Lazer',
                    'Gasolina',
                    'Comida',
                    'Roupa',
                    'Transporte',
                    'Salário',
                    'Freelance',
                    'Presente',
                    'Outros'
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: IconButton(
                  icon: const Icon(Icons.date_range),
                  onPressed: () async {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return SizedBox(
                          height: 200.0,
                          child: Column(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.date_range),
                                title: const Text("Desde o início até agora"),
                                onTap: () {
                                  setState(() {
                                    _selectedDateRange = DateTimeRange(
                                      start: DateTime(2000),
                                      end: DateTime.now(),
                                    );
                                    _selectedDate = null;
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.today),
                                title: const Text("Selecionar data"),
                                onTap: () async {
                                  Navigator.pop(context);
                                  final DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: _selectedDate ?? DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2101),
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      _selectedDate = picked;
                                      _selectedDateRange = null;
                                    });
                                  }
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.calendar_today),
                                title: const Text("Selecionar intervalo de datas"),
                                onTap: () async {
                                  Navigator.pop(context);
                                  final DateTimeRange? picked = await showDateRangePicker(
                                    context: context,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2101),
                                    initialDateRange: _selectedDateRange ??
                                        DateTimeRange(
                                          start: DateTime.now().subtract(const Duration(days: 7)),
                                          end: DateTime.now(),
                                        ),
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      _selectedDateRange = picked;
                                      _selectedDate = null;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredTransactions.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> transaction = filteredTransactions[index];
              return Dismissible(
                key: Key(transaction['id'].toString()),
                onDismissed: (direction) {
                  _deleteTransaction(index, isIncome);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${transaction['nome']} deletado')),
                  );
                },
                background: Container(color: Colors.red),
                child: Card(
                  child: ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(transaction['nome']),
                        Text(
                          transaction['data'],
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    subtitle: Text('R\$ ${transaction['valor']}'),
                    textColor: isIncome ? Colors.green : Colors.red,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
