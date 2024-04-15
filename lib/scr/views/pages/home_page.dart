import 'package:flutter/material.dart';
import 'package:flutter_application_1/scr/controllers/app_controller.dart';
import 'package:flutter_application_1/scr/views/pages/cadastrar_despesa.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int counter = 0;
  List _expenses = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          CustomSwitcher(),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Conteúdo removido para simplificar

            // Lista de despesas
            Expanded(
              child: ListView.builder(
                itemCount: _expenses.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.all(10),
                    color: Colors.amber.shade100,
                    child: ListTile(
                      leading: Text(_expenses[index]["id"].toString()),
                      title: Text(_expenses[index]["nome"]),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Valor: ${_expenses[index]["valor"]}"),
                          Text("Data: ${_expenses[index]["data"]}"),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
        onPressed: () async {
          // Abrindo a tela de cadastro e aguardando os dados retornados
          final Map<String, dynamic>? newExpense = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CadastroPage()),
          );

          // Se novos dados foram retornados, adicioná-los à lista de despesas
          if (newExpense != null) {
            setState(() {
              _expenses.add(newExpense);
            });
          }
        },
      ),
    );
  }
}

class CustomSwitcher extends StatelessWidget {
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
