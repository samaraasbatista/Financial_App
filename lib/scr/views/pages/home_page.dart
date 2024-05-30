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
      double incomeSum = _transactions
          .where((item) => item['tipo'] == 'Salário' || item['tipo'] == 'Freelance' || item['tipo'] == 'Presente' || item['tipo'] == 'Outros')
          .fold(0.0, (sum, item) => sum + (item['valor'] ?? 0.0));
      double expenseSum = _transactions
          .where((item) => !(item['tipo'] == 'Salário' || item['tipo'] == 'Freelance' || item['tipo'] == 'Presente' || item['tipo'] == 'Outros'))
          .fold(0.0, (sum, item) => sum + (item['valor'] ?? 0.0));
      _totalBalance = incomeSum - expenseSum;
    });
  }

  void _saveTransactions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> transactionList = _transactions.map((transaction) => jsonEncode(transaction)).toList();
    await prefs.setStringList('transactions', transactionList);
    _calculateTotalBalance();
  }

  void _loadTransactions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? transactionList = prefs.getStringList('transactions');
    if (transactionList != null) {
      setState(() {
        _transactions = transactionList.map((transaction) => jsonDecode(transaction) as Map<String, dynamic>).toList();
        _calculateTotalBalance();
      });
    }
  }

  void _deleteTransaction(int index) {
    setState(() {
      _transactions.removeAt(index);
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
      DateTime transactionDate = DateFormat('dd/MM/yyyy').parse(transaction['data'] ?? '');
      return transactionDate.isBefore(now) || transactionDate.isAtSameMomentAs(now);
    }).toList();
  }

  List<Map<String, dynamic>> _getFutureTransactions() {
    DateTime now = DateTime.now();
    return _transactions.where((transaction) {
      DateTime transactionDate = DateFormat('dd/MM/yyyy').parse(transaction['data'] ?? '');
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
                  _buildTransactionList(_getHomeTransactions()),
                  _buildTransactionList(_getFutureTransactions()),
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

  Widget _buildTransactionList(List<Map<String, dynamic>> transactions) {
    List<Map<String, dynamic>> filteredTransactions = transactions.where((transaction) {
      bool matchesType = _selectedType == 'Todos' || transaction['tipo'] == _selectedType;
      bool matchesDate = true;
      if (_selectedDate != null) {
        matchesDate = transaction['data'] == DateFormat('dd/MM/yyyy').format(_selectedDate!);
      }
      if (_selectedDateRange != null) {
        DateTime transactionDate = DateFormat('dd/MM/yyyy').parse(transaction['data'] ?? '');
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
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () {
                        showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        ).then((pickedDate) {
                          if (pickedDate != null) {
                            setState(() {
                              _selectedDate = pickedDate;
                              _selectedDateRange = null;
                            });
                          }
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_view_day),
                      onPressed: () {
                        showDateRangePicker(
                          context: context,
                          initialDateRange: _selectedDateRange,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        ).then((pickedRange) {
                          if (pickedRange != null) {
                            setState(() {
                              _selectedDateRange = pickedRange;
                              _selectedDate = null;
                            });
                          }
                        });
                      },
                    ),
                    if (_selectedDate != null)
                      Text(DateFormat('dd/MM/yyyy').format(_selectedDate!))
                    else if (_selectedDateRange != null)
                      Text(
                        'De ${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.start)} '
                        'até ${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.end)}',
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredTransactions.length,
            itemBuilder: (context, index) {
              bool isIncome = filteredTransactions[index]['tipo'] == 'Salário' ||
                  filteredTransactions[index]['tipo'] == 'Freelance' ||
                  filteredTransactions[index]['tipo'] == 'Presente' ||
                  filteredTransactions[index]['tipo'] == 'Outros';

              return Dismissible(
                key: Key(filteredTransactions[index].toString()),
                onDismissed: (direction) {
                  _deleteTransaction(index);
                },
                background: Container(color: Colors.red),
                child: Card(
                  color: isIncome ? Colors.green[50] : Colors.red[50],
                  child: ListTile(
                    title: Text(
                      filteredTransactions[index]['nome']?.isNotEmpty == true
                          ? filteredTransactions[index]['nome']
                          : 'Sem descrição',
                    ),
                    subtitle: Text(filteredTransactions[index]['data'] ?? 'Sem data'),
                    trailing: Text(
                      'R\$ ${(filteredTransactions[index]['valor'] ?? 0.0).toStringAsFixed(2)}',
                      style: TextStyle(color: isIncome ? Colors.green : Colors.red),
                    ),
                    onLongPress: () {
                      _deleteTransaction(index);
                    },
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
