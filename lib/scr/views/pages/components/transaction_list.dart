import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionList extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;
  final String selectedType;
  final DateTimeRange? selectedDateRange;
  final List<String> tiposDespesas;
  final Function(int) onDeleteTransaction;
  final Function(String) onSelectedTypeChanged;
  final Function(DateTimeRange?) onSelectedDateRangeChanged;
  final Function() onClearDateSelection;

  TransactionList({
    required this.transactions,
    required this.selectedType,
    required this.selectedDateRange,
    required this.tiposDespesas,
    required this.onDeleteTransaction,
    required this.onSelectedTypeChanged,
    required this.onSelectedDateRangeChanged,
    required this.onClearDateSelection,
  });

  List<Map<String, dynamic>> _getFilteredTransactions() {
    List<Map<String, dynamic>> filteredTransactions = transactions;

    if (selectedType != 'Todos') {
      filteredTransactions = filteredTransactions.where((transaction) => transaction['tipo'] == selectedType).toList();
    }

    if (selectedDateRange != null) {
      filteredTransactions = filteredTransactions.where((transaction) {
        DateTime transactionDate = DateFormat('dd/MM/yyyy').parse(transaction['data'] ?? '');
        return transactionDate.isAtSameMomentAs(selectedDateRange!.start) ||
               transactionDate.isAtSameMomentAs(selectedDateRange!.end) ||
               (transactionDate.isAfter(selectedDateRange!.start) && transactionDate.isBefore(selectedDateRange!.end));
      }).toList();
    }

    return filteredTransactions;
  }

  double _calculateFilteredBalance(List<Map<String, dynamic>> filteredTransactions) {
    double incomeSum = filteredTransactions
        .where((item) => item['tipo'] == 'Salário' || item['tipo'] == 'Freelance' || item['tipo'] == 'Presente' || item['tipo'] == 'Outros')
        .fold(0.0, (sum, item) => sum + (item['valor'] ?? 0.0));
    double expenseSum = filteredTransactions
        .where((item) => !(item['tipo'] == 'Salário' || item['tipo'] == 'Freelance' || item['tipo'] == 'Presente' || item['tipo'] == 'Outros'))
        .fold(0.0, (sum, item) => sum + (item['valor'] ?? 0.0));
    return incomeSum - expenseSum;
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredTransactions = _getFilteredTransactions();
    double filteredBalance = _calculateFilteredBalance(filteredTransactions);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedType,
                  onChanged: (String? newValue) {
                    onSelectedTypeChanged(newValue!);
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Tipo',
                  ),
                  items: tiposDespesas.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 8.0),
                    IconButton(
                      icon: const Icon(Icons.date_range),
                      onPressed: () {
                        showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        ).then((pickedDateRange) {
                          if (pickedDateRange != null) {
                            onSelectedDateRangeChanged(pickedDateRange);
                          }
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: onClearDateSelection,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16.0),
          color: Colors.black,
          width: double.infinity,
          child: Text(
            'Saldo Filtrado: R\$ ${filteredBalance.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredTransactions.length,
            itemBuilder: (context, index) {
              final transaction = filteredTransactions[index];
              return Dismissible(
                key: UniqueKey(),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  onDeleteTransaction(index);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Transação deletada')),
                  );
                },
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: ListTile(
                  title: Text(transaction['nome'] ?? ''),
                  subtitle: Text(transaction['data'] ?? ''),
                  trailing: Text(
                    'R\$ ${transaction['valor']?.toStringAsFixed(2) ?? '0.00'}',
                    style: TextStyle(
                      color: (transaction['tipo'] == 'Salário' || transaction['tipo'] == 'Freelance' || transaction['tipo'] == 'Presente' || transaction['tipo'] == 'Outros')
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
