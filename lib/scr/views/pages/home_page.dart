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
  String _selectedType = 'Todos'; // Variável para armazenar o tipo selecionado
  DateTime? _selectedDate; // Variável para armazenar a data selecionada
  DateTimeRange? _selectedDateRange; // Variável para armazenar o intervalo de datas selecionado
  double _balance = 1000.0; // Variável para armazenar o saldo inicial

  @override
  void initState() {
    super.initState();
    _loadExpenses('expenses');
    _loadExpenses('futureExpenses');
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
              Text(
                'Samara Alves',
                style: TextStyle(fontSize: 18, color: Colors.white),
              )
            ],
          ),
          backgroundColor: Colors.black,
          actions: [],
          bottom: TabBar(
            tabs: [
              Tab(text: 'Home'),
              Tab(text: 'Futuros'),
            ],
          ),
        ),
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16.0),
              color: Colors.black,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Saldo:',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  Text(
                    'R\$ ${_balance.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildExpenseList(_expenses),
                  _buildExpenseList(_futureExpenses),
                ],
              ),
            ),
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
                  _updateBalance();
                });
              }
            }
          },
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
            return expenseDate.isAfter(_selectedDateRange!.start.subtract(Duration(days: 1))) &&
                expenseDate.isBefore(_selectedDateRange!.end.add(Duration(days: 1)));
          })
          .toList();
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
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
            SizedBox(width: 10),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: IconButton(
                icon: Icon(Icons.date_range),
                onPressed: () async {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return Container(
                        height: 200.0,
                        child: Column(
                          children: [
                            ListTile(
                              leading: Icon(Icons.date_range),
                              title: Text("Desde o início até agora"),
                              onTap: () async {
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
                              leading: Icon(Icons.date_range),
                              title: Text("Selecionar intervalo de datas"),
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
            SizedBox(width: 10),
            PopupMenuButton<String>(
              icon: Icon(Icons.sort),
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'Valor (Maior para Menor)',
                  child: ListTile(
                    title: Text('Valor (Maior para Menor)'),
                    onTap: () {
                      setState(() {
                        _expenses.sort((a, b) => b['valor'].compareTo(a['valor']));
                        _futureExpenses.sort((a, b) => b['valor'].compareTo(a['valor']));
                      });
                      Navigator.pop(context);
                    },
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'Valor (Menor para Maior)',
                  child: ListTile(
                    title: Text('Valor (Menor para Maior)'),
                    onTap: () {
                      setState(() {
                        _expenses.sort((a, b) => a['valor'].compareTo(b['valor']));
                        _futureExpenses.sort((a, b) => a['valor'].compareTo(b['valor']));
                      });
                      Navigator.pop(context);
                    },
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'Data (Mais recente para Mais antiga)',
                  child: ListTile(
                    title: Text('Data (Mais recente para Mais antiga)'),
                    onTap: () {
                      setState(() {
                        _expenses.sort((a, b) => b['data'].compareTo(a['data']));
                        _futureExpenses.sort((a, b) => b['data'].compareTo(a['data']));
                      });
                      Navigator.pop(context);
                    },
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'Data (Mais antiga para Mais recente)',
                  child: ListTile(
                    title: Text('Data (Mais antiga para Mais recente)'),
                    onTap: () {
                      setState(() {
                        _expenses.sort((a, b) => a['data'].compareTo(b['data']));
                        _futureExpenses.sort((a, b) => a['data'].compareTo(b['data']));
                      });
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),


          SizedBox(height: 16.0), // Espaçamento entre os filtros e a lista
          Expanded(
            child: ListView.builder(
              itemCount: filteredExpenses.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: Key(filteredExpenses[index]["id"].toString()),
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
                      leading: Text(filteredExpenses[index]["id"].toString()),
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

  String _formatDate(String date) {
    // Converte a data de 'dd/MM/yyyy' para o formato 'yyyy-MM-dd'
    DateTime parsedDate = DateFormat('dd/MM/yyyy').parse(date);
    return DateFormat('yyyy-MM-dd').format(parsedDate);
  }

  void _deleteExpense(int index, List<Map<String, dynamic>> expenses) async {
    setState(() {
      _balance += expenses[index]['valor']; // Atualiza o saldo ao apagar a despesa
      expenses.removeAt(index);
    });
    // Remover a despesa também do SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('expenses', jsonEncode(_expenses));
    await prefs.setString('futureExpenses', jsonEncode(_futureExpenses));
  }

  Future<void> _saveExpenses(List<Map<String, dynamic>> expenses, String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(expenses));
    _updateBalance();
  }

  Future<void> _loadExpenses(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? expensesString = prefs.getString(key);
    if (expensesString != null) {
      List<Map<String, dynamic>> expenses = jsonDecode(expensesString).cast<Map<String, dynamic>>();
      setState(() {
        if (key == 'expenses') {
          _expenses = expenses;
        } else {
          _futureExpenses = expenses;
        }
      });
      _updateBalance();
    }
  }

  void _updateBalance() {
    double totalExpenses = _expenses.fold(0, (sum, item) => sum + item['valor']);
    setState(() {
      _balance = _balance - totalExpenses; // Saldo inicial menos as despesas
    });
  }
}
