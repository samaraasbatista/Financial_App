import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CadastroTipoDespesaPage extends StatefulWidget {
  const CadastroTipoDespesaPage({super.key});

  @override
  _CadastroTipoDespesaPageState createState() => _CadastroTipoDespesaPageState();
}

class _CadastroTipoDespesaPageState extends State<CadastroTipoDespesaPage> {
  final TextEditingController _tipoController = TextEditingController();
  List<String> _tiposDespesas = [];
  List<Map<String, dynamic>> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTiposDespesas();
    _loadTransactions();
  }

  void _loadTiposDespesas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _tiposDespesas = prefs.getStringList('tiposDespesas') ?? [];
    });
  }

  void _loadTransactions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? transactionList = prefs.getStringList('transactions');
    if (transactionList != null) {
      setState(() {
        _transactions = transactionList.map((transaction) => jsonDecode(transaction) as Map<String, dynamic>).toList();
      });
    }
  }

  void _saveTiposDespesas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('tiposDespesas', _tiposDespesas);
  }

  void _addTipoDespesa() {
    setState(() {
      _tiposDespesas.add(_tipoController.text);
      _tipoController.clear();
      _saveTiposDespesas();
    });
  }

  void _removeTipoDespesa(int index) {
    String tipoToRemove = _tiposDespesas[index];
    bool isBeingUsed = _transactions.any((transaction) => transaction['tipo'] == tipoToRemove);

    if (!isBeingUsed) {
      setState(() {
        _tiposDespesas.removeAt(index);
        _saveTiposDespesas();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('O tipo "$tipoToRemove" está sendo usado e não pode ser removido.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Tipo de Despesa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _tipoController,
              decoration: const InputDecoration(labelText: 'Tipo de Despesa'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addTipoDespesa,
              child: const Text('Adicionar Tipo'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _tiposDespesas.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_tiposDespesas[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _removeTipoDespesa(index),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}