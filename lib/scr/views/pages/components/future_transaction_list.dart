import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FutureTransactionList extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;
  final double totalBalance;

  FutureTransactionList({
    required this.transactions,
    required this.totalBalance,
  });

  Map<String, List<Map<String, dynamic>>> _groupFutureTransactionsByDate() {
    DateTime now = DateTime.now();
    Map<String, List<Map<String, dynamic>>> groupedTransactions = {};
    double cumulativeBalance = totalBalance;

    transactions
        .where((transaction) {
          DateTime transactionDate = DateFormat('dd/MM/yyyy').parse(transaction['data'] ?? '');
          return transactionDate.isAfter(now);
        })
        .forEach((transaction) {
          String date = transaction['data'] ?? '';
          if (!groupedTransactions.containsKey(date)) {
            groupedTransactions[date] = [];
          }
          groupedTransactions[date]!.add(transaction);

          // Calculate cumulative balance up to this date
          double transactionValue = transaction['valor'] ?? 0.0;
          if (transaction['tipo'] == 'Salário' || transaction['tipo'] == 'Freelance' || transaction['tipo'] == 'Presente' || transaction['tipo'] == 'Outros') {
            cumulativeBalance += transactionValue;
          } else {
            cumulativeBalance -= transactionValue;
          }

          transaction['cumulativeBalance'] = cumulativeBalance;
        });

    return groupedTransactions;
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<Map<String, dynamic>>> groupedTransactions = _groupFutureTransactionsByDate();
    List<String> sortedDates = groupedTransactions.keys.toList()
      ..sort((a, b) => DateFormat('dd/MM/yyyy').parse(b).compareTo(DateFormat('dd/MM/yyyy').parse(a))); // Ordenação do maior para o menor

    return ListView.builder(
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        String date = sortedDates[index];
        List<Map<String, dynamic>> transactions = groupedTransactions[date]!;
        double cumulativeBalance = transactions.first['cumulativeBalance'];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.grey[200],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    date,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Saldo: R\$ ${cumulativeBalance.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            ...transactions.map((transaction) {
              return ListTile(
                title: Text(transaction['nome'] ?? ''),
                subtitle: Text(transaction['tipo'] ?? ''),
                trailing: Text(
                  'R\$ ${transaction['valor']?.toStringAsFixed(2) ?? '0.00'}',
                  style: TextStyle(
                    color: (transaction['tipo'] == 'Salário' || transaction['tipo'] == 'Freelance' || transaction['tipo'] == 'Presente' || transaction['tipo'] == 'Outros')
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }
}
