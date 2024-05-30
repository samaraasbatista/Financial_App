import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CadastroIncomePage extends StatefulWidget {
  const CadastroIncomePage({Key? key}) : super(key: key);

  @override
  State<CadastroIncomePage> createState() => _CadastrarReceita();
}

class _CadastrarReceita extends State<CadastroIncomePage> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _valorController = TextEditingController();
  final TextEditingController _dataController = TextEditingController();
  String _tipoReceita = ""; // Valor padrão
  List<String> _tiposReceitas = [];

  @override
  void initState() {
    super.initState();
    _loadTiposReceitas();
  }

  void _loadTiposReceitas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _tiposReceitas = prefs.getStringList('tiposReceitas') ?? [];
      if (_tiposReceitas.isNotEmpty) {
        _tipoReceita = _tiposReceitas[0];
      }
    });
  }

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
        title: const Text('Cadastrar Receita'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
              const SizedBox(height: 20),
              TextFormField(
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r'[ ,\-]')), // Bloqueia espaços, traços e vírgulas
                ],
                controller: _valorController,
                decoration: const InputDecoration(labelText: 'Valor'),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _dataController,
                decoration: const InputDecoration(labelText: 'Data'),
                readOnly: true,
                onTap: () {
                  _selectDate(context);
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Tipo',
                style: TextStyle(fontSize: 16),
              ),
              DropdownButton<String>(
                value: _tipoReceita,
                onChanged: (String? newValue) {
                  setState(() {
                    _tipoReceita = newValue!;
                  });
                },
                items: _tiposReceitas.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Map<String, dynamic> newIncome = {
                    "id": DateTime.now().millisecondsSinceEpoch,
                    "nome": _nomeController.text,
                    "valor": double.parse(_valorController.text),
                    "data": _dataController.text,
                    "tipo": _tipoReceita,
                  };

                  Navigator.pop(context, newIncome);
                },
                child: const Text('Adicionar Receita'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
