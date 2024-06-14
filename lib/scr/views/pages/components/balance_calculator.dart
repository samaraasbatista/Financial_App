import 'package:intl/intl.dart';

double calculateTotalBalance(List<Map<String, dynamic>> transactions) {
  DateTime now = DateTime.now();
  double incomeSum = transactions
      .where((item) {
        DateTime transactionDate = DateFormat('dd/MM/yyyy').parse(item['data']);
        return (item['tipo'] == 'Salário' || item['tipo'] == 'Freelance' || item['tipo'] == 'Presente' || item['tipo'] == 'Outros') &&
               (transactionDate.isBefore(now) || transactionDate.isAtSameMomentAs(now));
      })
      .fold(0.0, (sum, item) => sum + (item['valor'] ?? 0.0));
  double expenseSum = transactions
      .where((item) {
        DateTime transactionDate = DateFormat('dd/MM/yyyy').parse(item['data']);
        return !(item['tipo'] == 'Salário' || item['tipo'] == 'Freelance' || item['tipo'] == 'Presente' || item['tipo'] == 'Outros') &&
               (transactionDate.isBefore(now) || transactionDate.isAtSameMomentAs(now));
      })
      .fold(0.0, (sum, item) => sum + (item['valor'] ?? 0.0));
  return incomeSum - expenseSum;
}
