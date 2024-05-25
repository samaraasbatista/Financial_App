import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/scr/views/pages/cadastrar_despesa.dart';
import 'package:flutter_application_1/scr/views/pages/calculadora_juros_compostos.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _expenses = [];
  String _selectedType = 'Todos'; // Variável para armazenar o tipo selecionado
  DateTime? _selectedDate; // Variável para armazenar a data selecionada
  DateTimeRange? _selectedDateRange; // Variável para armazenar o intervalo de datas selecionado
  double _totalBalance = 0.00; // Variável para armazenar o saldo total

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  void _calculateTotalBalance() {
    setState(() {
      _totalBalance = _expenses.fold(0.0, (sum, item) => sum + item['valor']);
    });
  }

  void _saveExpenses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> expenseList = _expenses.map((expense) => jsonEncode(expense)).toList();
    await prefs.setStringList('expenses', expenseList);
    _calculateTotalBalance();
  }

  void _loadExpenses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? expenseList = prefs.getStringList('expenses');
    if (expenseList != null) {
      setState(() {
        _expenses = expenseList.map((expense) => jsonDecode(expense) as Map<String, dynamic>).toList();
        _calculateTotalBalance();
      });
    }
  }

  void _deleteExpense(int index) {
    setState(() {
      _expenses.removeAt(index);
      _saveExpenses();
    });
  }

  String _formatDate(String date) {
    DateTime parsedDate = DateFormat('dd/MM/yyyy').parse(date);
    return DateFormat('yyyy-MM-dd').format(parsedDate);
  }

  List<Map<String, dynamic>> _getHomeExpenses() {
    DateTime now = DateTime.now();
    return _expenses.where((expense) {
      DateTime expenseDate = DateFormat('dd/MM/yyyy').parse(expense['data']);
      return expenseDate.isBefore(now) || expenseDate.isAtSameMomentAs(now);
    }).toList();
  }

  List<Map<String, dynamic>> _getFutureExpenses() {
    DateTime now = DateTime.now();
    return _expenses.where((expense) {
      DateTime expenseDate = DateFormat('dd/MM/yyyy').parse(expense['data']);
      return expenseDate.isAfter(now);
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
                  _buildExpenseList(_getHomeExpenses()),
                  _buildExpenseList(_getFutureExpenses()),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.red,
          onPressed: () async {
            final Map<String, dynamic>? newExpense = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CadastroPage()),
            );

            if (newExpense != null) {
              setState(() {
                _expenses.add(newExpense);
                _saveExpenses();
              });
            }
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildExpenseList(List<Map<String, dynamic>> expenses) {
    List<Map<String, dynamic>> filteredExpenses = _selectedType == 'Todos'
        ? expenses
        : expenses.where((expense) => expense['tipo'] == _selectedType).toList();

    if (_selectedDate != null) {
      filteredExpenses = filteredExpenses
          .where((expense) => _formatDate(expense['data']) == DateFormat('yyyy-MM-dd').format(_selectedDate!))
          .toList();
    } else if (_selectedDateRange != null) {
      filteredExpenses = filteredExpenses
          .where((expense) {
            DateTime expenseDate = DateFormat('yyyy-MM-dd').parse(_formatDate(expense['data']));
            return expenseDate.isAfter(_selectedDateRange!.start.subtract(const Duration(days: 1))) &&
                expenseDate.isBefore(_selectedDateRange!.end.add(const Duration(days: 1)));
          })
          .toList();
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedType,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedType = newValue!;
                      });
                    },
                    items: <String>[
                      'Todos', 'Saúde e Bem-Estar', 'Streamings', 'Lazer',
                      'Gasolina', 'Comida', 'Roupa', 'Transporte'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
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
                                      start: DateTime(2000), // ou outra data que você considere apropriada
                                      end: DateTime.now(),
                                    );
                                    _selectedDate = null; // Limpa a seleção de data única
                                  });
                                  Navigator.pop(context); // Fecha o modal
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.date_range),
                                title: const Text("Selecionar intervalo de datas"),
                                onTap: () async {
                                  DateTimeRange? picked = await showDateRangePicker(
                                    context: context,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2101),
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      _selectedDateRange = picked;
                                      _selectedDate = null; // Limpa a seleção de data única
                                    });
                                  }
                                  Navigator.pop(context); // Fecha o modal
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
              const SizedBox(width: 10),
              PopupMenuButton<String>(
                icon: const Icon(Icons.sort),
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem<String>(
                    value: 'Valor (Maior para Menor)',
                    child: ListTile(
                      title: const Text('Valor (Maior para Menor)'),
                      onTap: () {
                        setState(() {
                          _expenses.sort((a, b) => b['valor'].compareTo(a['valor']));
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'Valor (Menor para Maior)',
                    child: ListTile(
                      title: const Text('Valor (Menor para Maior)'),
                      onTap: () {
                        setState(() {
                          _expenses.sort((a, b) => a['valor'].compareTo(b['valor']));
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'Data (Mais recente para Mais antiga)',
                    child: ListTile(
                      title: const Text('Data (Mais recente para Mais antiga)'),
                      onTap: () {
                        setState(() {
                          _expenses.sort((a, b) => b['data'].compareTo(a['data']));
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'Data (Mais antiga para Mais recente)',
                    child: ListTile(
                      title: const Text('Data (Mais antiga para Mais recente)'),
                      onTap: () {
                        setState(() {
                          _expenses.sort((a, b) => a['data'].compareTo(b['data']));
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16.0), // Espaçamento entre os filtros e a lista
          Expanded(
            child: ListView.builder(
              itemCount: filteredExpenses.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: Key(filteredExpenses[index]["id"].toString()),
                  onDismissed: (direction) {
                    _deleteExpense(index);
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    child: const Padding(
                      padding: EdgeInsets.only(right: 20.0),
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  child: Card(
                    margin: const EdgeInsets.all(10),
                    color: const Color.fromARGB(255, 238, 238, 238),
                    child: ListTile(
                      title: Text(filteredExpenses[index]["nome"]),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Valor: R\$ ${filteredExpenses[index]["valor"]}"),
                          Text("Data: ${filteredExpenses[index]["data"]}"),
                          Text("Tipo: ${filteredExpenses[index]["tipo"]}"),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
