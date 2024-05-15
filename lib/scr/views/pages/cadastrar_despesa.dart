import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({Key? key}) : super(key: key);

  @override
  State<CadastroPage> createState() => _CadastrarDispesa();
}

class _CadastrarDispesa extends State<CadastroPage> {
  static List _items = [];
  TextEditingController _nomeController = TextEditingController();
  TextEditingController _valorController = TextEditingController();
  TextEditingController _dataController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null)
      setState(() {
        _dataController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
  }

  Future<void> _salvarDespesa(Map<String, dynamic> despesa) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _items.add(despesa);
    await prefs.setString('despesas', jsonEncode(_items));
  }

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
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'[ ,\-]')), // Bloqueia espaços, traços e vírgulas
                  ],
                  controller: _valorController,
                  decoration: InputDecoration(labelText: 'Valor'),
                ),
                TextFormField(
                  controller: _dataController,
                  decoration: InputDecoration(labelText: 'Data'),
                  readOnly: true,
                  onTap: () {
                    _selectDate(context);
                  },
                ),
                ElevatedButton(
                  onPressed: () async {
                    DateTime now = DateTime.now();
                    DateTime selectedDate = DateFormat('dd/MM/yyyy').parse(_dataController.text);

                    Map<String, dynamic> newExpense = {
                      "id": _items.length + 1,
                      "nome": _nomeController.text,
                      "valor": double.parse(_valorController.text),
                      "data": _dataController.text,
                    };

                    if (selectedDate.isAfter(now)) {
                      Navigator.pop(context, {"data": newExpense, "status": 1});
                    } else {
                      await _salvarDespesa(newExpense);
                      Navigator.pop(context, {"data": newExpense, "status": 0});
                    }
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
