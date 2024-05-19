import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({Key? key}) : super(key: key);

  @override
  State<CadastroPage> createState() => _CadastrarDespesa();
}

class _CadastrarDespesa extends State<CadastroPage> {
  TextEditingController _nomeController = TextEditingController();
  TextEditingController _valorController = TextEditingController();
  TextEditingController _dataController = TextEditingController();
  String _tipoDespesa = "Saúde e Bem-Estar"; // Valor padrão

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Cadastrar Despesas'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(labelText: 'Nome'),
              ),
              SizedBox(height: 20),
              TextFormField(
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r'[ ,\-]')), // Bloqueia espaços, traços e vírgulas
                ],
                controller: _valorController,
                decoration: InputDecoration(labelText: 'Valor'),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _dataController,
                decoration: InputDecoration(labelText: 'Data'),
                readOnly: true,
                onTap: () {
                  _selectDate(context);
                },
              ),
              SizedBox(height: 20),
              Text(
                'Tipo',
                style: TextStyle(fontSize: 16),
              ),
              DropdownButton<String>(
                value: _tipoDespesa,
                onChanged: (String? newValue) {
                  setState(() {
                    _tipoDespesa = newValue!;
                  });
                },
                items: <String>[
                  'Saúde e Bem-Estar',
                  'Streamings',
                  'Lazer',
                  'Gasolina',
                  'Comida',
                  'Roupa',
                  'Transporte'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Map<String, dynamic> newExpense = {
                    "id": DateTime.now().millisecondsSinceEpoch,
                    "nome": _nomeController.text,
                    "valor": double.parse(_valorController.text),
                    "data": _dataController.text,
                    "tipo": _tipoDespesa,
                  };

                  Navigator.pop(context, newExpense);
                },
                child: Text('Add Item'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
