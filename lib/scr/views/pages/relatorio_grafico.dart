import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';

class GraficoPage extends StatefulWidget {
  final List<Map<String, dynamic>> transactions;

  GraficoPage({required this.transactions});

  @override
  _GraficoPageState createState() => _GraficoPageState();
}

class _GraficoPageState extends State<GraficoPage> {
  String _selectedType = 'Todos';
  List<String> _tiposReceitas = [];
  List<String> _tiposDespesas = [];

  @override
  void initState() {
    super.initState();
    _loadTiposReceitas();
    _loadTiposDespesas();
  }

  void _loadTiposReceitas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _tiposReceitas = prefs.getStringList('tiposReceitas') ?? [];
    });
  }

  void _loadTiposDespesas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _tiposDespesas = prefs.getStringList('tiposDespesas') ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gráfico de Transações'),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButton<String>(
              value: _selectedType,
              items: _getDropdownItems(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: PieChart(
                PieChartData(
                  sections: _buildPieChartSections(),
                  centerSpaceRadius: 50,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<DropdownMenuItem<String>> _getDropdownItems() {
    List<String> filterItems = ['Todos', 'Entradas', 'Despesas'];
    List<String> types = widget.transactions.map((transaction) => transaction['tipo'] as String).toSet().toList();
    List<String> combinedItems = filterItems + types;

    return combinedItems.map((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList();
  }

  List<PieChartSectionData> _buildPieChartSections() {
    Map<String, double> typeTotals = {};

    widget.transactions.forEach((transaction) {
      String type = transaction['tipo'];
      double value = transaction['valor'] ?? 0.0;
      bool isReceita = _tiposReceitas.contains(type);
      bool isDespesa = _tiposDespesas.contains(type);

      if ((_selectedType == 'Todos') ||
          (_selectedType == 'Entradas' && isReceita) ||
          (_selectedType == 'Despesas' && isDespesa) ||
          (_selectedType == type)) {
        if (typeTotals.containsKey(type)) {
          typeTotals[type] = typeTotals[type]! + value;
        } else {
          typeTotals[type] = value;
        }
      }
    });

    List<PieChartSectionData> sections = [];
    typeTotals.forEach((type, total) {
      sections.add(
        PieChartSectionData(
          value: total,
          title: '$type\nR\$ ${total.toStringAsFixed(2)}',
          radius: 100,
          color: _getColorForType(type),
        ),
      );
    });

    return sections;
  }

  Color _getColorForType(String type) {
    if (_tiposReceitas.contains(type)) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }
}
