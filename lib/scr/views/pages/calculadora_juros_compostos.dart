import 'dart:math';

import 'package:flutter/material.dart';

class CalculadoraJurosCompostosPage extends StatefulWidget {
  @override
  _CalculadoraJurosCompostosPageState createState() => _CalculadoraJurosCompostosPageState();
}

class _CalculadoraJurosCompostosPageState extends State<CalculadoraJurosCompostosPage> {
  final TextEditingController _valorInicialController = TextEditingController();
  final TextEditingController _aporteMensalController = TextEditingController();
  final TextEditingController _taxaAnualController = TextEditingController();
  final TextEditingController _periodoMesesController = TextEditingController();
  double? _valorTotalFinal;
  double? _valorTotalInvestido;
  double? _totalJuros;

  void _calcular() {
    final double valorInicial = double.tryParse(_valorInicialController.text) ?? 0.0;
    final double aporteMensal = double.tryParse(_aporteMensalController.text) ?? 0.0;
    final double taxaAnual = double.tryParse(_taxaAnualController.text) ?? 0.0;
    final int periodoMeses = int.tryParse(_periodoMesesController.text) ?? 0;

    final double taxaMensal = taxaAnual / 12 / 100;
    final double valorComposto = valorInicial * pow(1 + taxaMensal, periodoMeses);
    double valorFuturoSerie = 0.0;

    if (aporteMensal > 0 && taxaMensal > 0) {
      valorFuturoSerie = aporteMensal * (pow(1 + taxaMensal, periodoMeses) - 1) / taxaMensal;
    }

    setState(() {
      _valorTotalFinal = double.parse((valorComposto + valorFuturoSerie).toStringAsFixed(2));
      _valorTotalInvestido = double.parse((valorInicial + (aporteMensal * periodoMeses)).toStringAsFixed(2));
      _totalJuros = double.parse((_valorTotalFinal! - _valorTotalInvestido!).toStringAsFixed(2));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculadora Juros Compostos'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _valorInicialController,
              decoration: InputDecoration(labelText: 'Valor Inicial do Investimento (P)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _aporteMensalController,
              decoration: InputDecoration(labelText: 'Valor Mensal a ser Aportado'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _taxaAnualController,
              decoration: InputDecoration(labelText: 'Taxa de Juros Anual (%)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _periodoMesesController,
              decoration: InputDecoration(labelText: 'Período em Meses'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _calcular,
              child: Text('Calcular'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, // Cor de fundo do botão
              ),
            ),
            SizedBox(height: 20.0),
            if (_valorTotalFinal != null)
              Column(
                children: [
                  Text(
                    'Valor Total Final: R\$${_valorTotalFinal!.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 20),
                  ),
                  Text(
                    'Valor Total Investido: R\$${_valorTotalInvestido!.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 20),
                  ),
                  Text(
                    'Total de Juros: R\$${_totalJuros!.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
