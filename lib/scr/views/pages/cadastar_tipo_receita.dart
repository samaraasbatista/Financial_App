import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CadastroTipoReceitaPage extends StatefulWidget {
  const CadastroTipoReceitaPage({Key? key}) : super(key: key);

  @override
  _CadastroTipoReceitaPageState createState() => _CadastroTipoReceitaPageState();
}

class _CadastroTipoReceitaPageState extends State<CadastroTipoReceitaPage> {
  final TextEditingController _tipoController = TextEditingController();
  List<String> _tiposReceitas = [];
  List<Map<String, dynamic>> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTiposReceitas();
    _loadTransactions();
  }

  void _loadTiposReceitas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _tiposReceitas = prefs.getStringList('tiposReceitas') ?? [];
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

  void _saveTiposReceitas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('tiposReceitas', _tiposReceitas);
  }

  void _addTipoReceita() {
    setState(() {
      _tiposReceitas.add(_tipoController.text);
      _tipoController.clear();
      _saveTiposReceitas();
    });
  }

  void _removeTipoReceita(int index) {
    String tipoToRemove = _tiposReceitas[index];
    bool isBeingUsed = _transactions.any((transaction) => transaction['tipo'] == tipoToRemove);

    if (!isBeingUsed) {
      setState(() {
        _tiposReceitas.removeAt(index);
        _saveTiposReceitas();
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
        title: const Text('Cadastrar Tipo de Receita'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _tipoController,
              decoration: const InputDecoration(labelText: 'Tipo de Receita'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addTipoReceita,
              child: const Text('Adicionar Tipo'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _tiposReceitas.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_tiposReceitas[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _removeTipoReceita(index),
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
