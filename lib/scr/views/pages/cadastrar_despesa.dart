import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({Key? key}) : super(key: key);

  @override
  State<CadastroPage> createState() => _CadastrarDispesa();
}

class _CadastrarDispesa extends State<CadastroPage> {
  List _items = [];

  TextEditingController _nomeController = TextEditingController();
  TextEditingController _valorController = TextEditingController();
  TextEditingController _dataController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Cadastrar Despesas',
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                TextFormField(
                  controller: _nomeController,
                  decoration: InputDecoration(labelText: 'Nome'),
                ),
                TextFormField(
                  controller: _valorController,
                  decoration: InputDecoration(labelText: 'Valor'),
                ),
                TextFormField(
                  controller: _dataController,
                  decoration: InputDecoration(labelText: 'Data'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Criando um mapa com os dados da despesa cadastrada
                    Map<String, dynamic> newExpense = {
                      "id": _items.length + 1,
                      "nome": _nomeController.text,
                      "valor": _valorController.text,
                      "data": _dataController.text,
                    };

                    // Retornando os dados da despesa para a tela anterior
                    Navigator.pop(context, newExpense);
                  },
                  child: Text('Add Item'),
                ),
              ],
            ),
          ),
          // Conteúdo da lista removido para simplificar
        ],
      ),
    );
  }
}
