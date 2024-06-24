import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

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
  DateTimeRange? _selectedDateRange;

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

  void _selectDateRange() async {
    final DateTimeRange? pickedDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDateRange != null && pickedDateRange != _selectedDateRange) {
      setState(() {
        _selectedDateRange = pickedDateRange;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedType = 'Todos';
      _selectedDateRange = null;
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
            child: Row(
              children: [
                Expanded(
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
                SizedBox(width: 16),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: _selectDateRange,
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _clearFilters,
                  child: Text('Limpar Filtros'),
                ),
              ],
            ),
          ),
          if (_selectedDateRange != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Selecionado: ${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.end)}',
                style: TextStyle(fontSize: 16),
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: BarChart(
                BarChartData(
                  barGroups: _buildBarChartGroups(),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                          final formattedDate = DateFormat('dd/MM').format(date);
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(formattedDate),
                          );
                        },
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                          double entradas = 0.0;
                          double despesas = 0.0;
                          widget.transactions.forEach((transaction) {
                            DateTime dateTime = DateFormat('dd/MM/yyyy').parse(transaction['data']);
                            if (dateTime.millisecondsSinceEpoch == value.toInt()) {
                              if (_tiposReceitas.contains(transaction['tipo'])) {
                                entradas += transaction['valor'];
                              } else if (_tiposDespesas.contains(transaction['tipo'])) {
                                despesas += transaction['valor'];
                              }
                            }
                          });
                          final total = entradas - despesas;
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(total.toStringAsFixed(2)),
                          );
                        },
                      ),
                    ),
                  ),
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

    return filterItems.map((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList();
  }

  List<PieChartSectionData> _buildPieChartSections() {
    Map<String, double> typeTotals = {};
    double totalValue = 0.0;

    widget.transactions.forEach((transaction) {
      String type = transaction['tipo'];
      double value = transaction['valor'] ?? 0.0;
      DateTime dateTime = DateFormat('dd/MM/yyyy').parse(transaction['data']);

      bool isInDateRange = _selectedDateRange == null ||
          (dateTime.isAfter(_selectedDateRange!.start.subtract(Duration(days: 1))) && dateTime.isBefore(_selectedDateRange!.end.add(Duration(days: 1))));
      bool isReceita = _tiposReceitas.contains(type);
      bool isDespesa = _tiposDespesas.contains(type);

      if (isInDateRange &&
          ((_selectedType == 'Todos') ||
          (_selectedType == 'Entradas' && isReceita) ||
          (_selectedType == 'Despesas' && isDespesa) ||
          (_selectedType == type))) {
        if (typeTotals.containsKey(type)) {
          typeTotals[type] = typeTotals[type]! + value;
        } else {
          typeTotals[type] = value;
        }
        totalValue += value;
      }
    });

    List<PieChartSectionData> sections = [];
    typeTotals.forEach((type, total) {
      final percentage = (total / totalValue) * 100;
      sections.add(
        PieChartSectionData(
          value: total,
          title: '$type\nR\$ ${total.toStringAsFixed(2)}\n${percentage.toStringAsFixed(1)}%',
          radius: 100,
          color: _getColorForType(type),
        ),
      );
    });

    return sections;
  }

  List<BarChartGroupData> _buildBarChartGroups() {
    Map<int, Map<String, double>> dateTotals = {};

    widget.transactions.forEach((transaction) {
      String type = transaction['tipo'];
      double value = transaction['valor'] ?? 0.0;
      DateTime dateTime = DateFormat('dd/MM/yyyy').parse(transaction['data']);
      int date = dateTime.millisecondsSinceEpoch;

      bool isInDateRange = _selectedDateRange == null ||
          (dateTime.isAfter(_selectedDateRange!.start.subtract(Duration(days: 1))) && dateTime.isBefore(_selectedDateRange!.end.add(Duration(days: 1))));
      bool isReceita = _tiposReceitas.contains(type);
      bool isDespesa = _tiposDespesas.contains(type);

      if (isInDateRange &&
          ((_selectedType == 'Todos') ||
          (_selectedType == 'Entradas' && isReceita) ||
          (_selectedType == 'Despesas' && isDespesa) ||
          (_selectedType == type))) {
        if (!dateTotals.containsKey(date)) {
          dateTotals[date] = {'Entradas': 0.0, 'Despesas': 0.0};
        }

        if (isReceita) {
          dateTotals[date]!['Entradas'] = dateTotals[date]!['Entradas']! + value;
        } else if (isDespesa) {
          dateTotals[date]!['Despesas'] = dateTotals[date]!['Despesas']! + value;
        }
      }
    });

    List<BarChartGroupData> barGroups = [];
    dateTotals.forEach((date, totals) {
      double entradas = totals['Entradas']!;
      double despesas = totals['Despesas']!;
      barGroups.add(
        BarChartGroupData(
          x: date,
          barRods: [
            BarChartRodData(
              toY: entradas,
              color: Colors.green,
              width: 8, // Reduced width for better legibility
            ),
            BarChartRodData(
              toY: despesas,
              color: Colors.red,
              width: 8, // Reduced width for better legibility
            ),
          ],
          barsSpace: 4, // Reduced space between bars
        ),
      );
    });

    return barGroups;
  }

  Color _getColorForType(String type) {
    if (_tiposReceitas.contains(type)) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }
}
