import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';


class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastrarDespesa();
}

class _CadastrarDespesa extends State<CadastroPage> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _valorController = TextEditingController();
  final TextEditingController _dataController = TextEditingController();
  String _tipoDespesa = ""; // Valor padrão
  List<String> _tiposDespesas = [];

  @override
  void initState() {
    super.initState();
    _loadTiposDespesas();
  }

  void _loadTiposDespesas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _tiposDespesas = prefs.getStringList('tiposDespesas') ?? [];
      if (_tiposDespesas.isNotEmpty) {
        _tipoDespesa = _tiposDespesas[0];
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
                value: _tipoDespesa,
                onChanged: (String? newValue) {
                  setState(() {
                    _tipoDespesa = newValue!;
                  });
                },
                items: _tiposDespesas.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
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
                child: const Text('Adicionar Despesa'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
