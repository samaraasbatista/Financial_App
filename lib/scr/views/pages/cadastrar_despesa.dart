import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastrarDispesa();
}

class _CadastrarDispesa extends State<CadastroPage> {
  static final List _items = [];
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _valorController = TextEditingController();
  final TextEditingController _dataController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dataController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
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
                  decoration: const InputDecoration(labelText: 'Nome'),
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'[ ,\-]')), // Bloqueia espaços, traços e vírgulas
                  ],
                  controller: _valorController,
                  decoration: const InputDecoration(labelText: 'Valor'),
                ),
                TextFormField(
                  controller: _dataController,
                  decoration: const InputDecoration(labelText: 'Data'),
                  readOnly: true,
                  onTap: () {
                    _selectDate(context);
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    DateTime now = DateTime.now();
                    DateTime selectedDate = DateFormat('dd/MM/yyyy').parse(_dataController.text);
                    
                    
                    if (selectedDate.isAfter(now)) {
                      
                      Map<String, dynamic> newFutureExpense = {
                        "id": _items.length + 1,
                        "nome": _nomeController.text,
                        "valor": double.parse(_valorController.text),
                        "data": _dataController.text,
                      };
                      
                      Navigator.pop(context, {"data": newFutureExpense, "status": 1});
                    } else {
                      
                      Map<String, dynamic> newExpense = {
                        "id": _items.length + 1,
                        "nome": _nomeController.text,
                        "valor": double.parse(_valorController.text),
                        "data": _dataController.text,
                      };
                      _items.add(newExpense);
                      
                      Navigator.pop(context, {"data": newExpense, "status": 0});
                    }
                  },
                  child: const Text('Add Item'),
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
