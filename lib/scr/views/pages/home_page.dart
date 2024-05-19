import 'package:financial_app/scr/controllers/app_controller.dart';
import 'package:financial_app/scr/views/pages/cadastrar_despesa.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> _expenses = [];
  final List<Map<String, dynamic>> _futureExpenses = [];

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
          actions: const [
            CustomSwitcher(),
          ],
          bottom: const TabBar(
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
          backgroundColor: Colors.red,
          onPressed: () async {
            
            final Map<String, dynamic>? newExpense = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CadastroPage()),
            );

            if (newExpense != null) {
              if (newExpense['status'] == 1) {
                setState(() {
                  _futureExpenses.add(newExpense['data']);
                  print(_futureExpenses);
                });
              } else {
                setState(() {
                  _expenses.add(newExpense['data']);
                  print(newExpense);
                });
              }
            }
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildExpenseList(List<Map<String, dynamic>> expenses) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(16.0),
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
                leading: Text(expenses[index]["id"].toString()),
                title: Text(expenses[index]["nome"]),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Valor: ${expenses[index]["valor"]}"),
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

  void _deleteExpense(int index, List<Map<String, dynamic>> expenses) {
    setState(() {
      expenses.removeAt(index);
    });
  }
}

class CustomSwitcher extends StatelessWidget {
  const CustomSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: AppController.instance.isDarkTheme,
      onChanged: (value) {
        AppController.instance.changeTheme();
      },
    );
  }
}
