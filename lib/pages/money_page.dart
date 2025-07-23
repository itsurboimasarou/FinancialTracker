import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../dialogs/add_transaction_dialog.dart';
import '../models/transaction_model.dart';
import '../services/firebase_service.dart';
import '../widgets/chart_view.dart';

class MoneyPage extends StatefulWidget {
  const MoneyPage({super.key});

  @override
  State<MoneyPage> createState() => _MoneyPageState();
}

class _MoneyPageState extends State<MoneyPage> {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Income/Expense'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Weekly'),
              Tab(text: 'Monthly'),
              Tab(text: 'Yearly'),
            ],
          ),
        ),
        body: Column(
          children: [
            const SizedBox(
              height: 280,
              child: TabBarView(
                children: [
                  WeeklyTab(),
                  MonthlyTab(),
                  YearlyTab(),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text("Recent Transactions",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<TransactionModel>>(
                stream: _firebaseService.getAllTransactions(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No transactions yet."));
                  }

                  final transactions = snapshot.data!;
                  transactions.sort((a, b) =>
                      DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));

                  return ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      final isIncome = transaction.amount > 0;
                      final format =
                          NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        child: ListTile(
                          leading: Icon(
                            isIncome
                                ? Icons.arrow_downward
                                : Icons.arrow_upward,
                            color: isIncome ? Colors.green : Colors.red,
                          ),
                          title: Text(transaction.category),
                          subtitle: Text(transaction.note),
                          trailing: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                format.format(transaction.amount.abs()),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isIncome ? Colors.green : Colors.red,
                                ),
                              ),
                              Text(DateFormat('dd/MM/yyyy')
                                  .format(DateTime.parse(transaction.date))),
                            ],
                          ),
                          onLongPress: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text("Confirm Deletion"),
                                content: const Text(
                                    "Are you sure you want to delete this transaction?"),
                                actions: [
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: const Text("Cancel")),
                                  ElevatedButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, true),
                                      child: const Text("Delete")),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await _firebaseService
                                  .deleteTransaction(transaction.id!);
                            }
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const AddTransactionDialog(),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class WeeklyTab extends StatelessWidget {
  const WeeklyTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        children: [
          ChartView(mode: ChartMode.week, type: ChartType.income),
          ChartView(mode: ChartMode.week, type: ChartType.expense),
          ChartView(mode: ChartMode.week, type: ChartType.diff),
        ],
      ),
    );
  }
}

class MonthlyTab extends StatelessWidget {
  const MonthlyTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        children: [
          ChartView(mode: ChartMode.month, type: ChartType.income),
          ChartView(mode: ChartMode.month, type: ChartType.expense),
          ChartView(mode: ChartMode.month, type: ChartType.diff),
        ],
      ),
    );
  }
}

class YearlyTab extends StatelessWidget {
  const YearlyTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        children: [
          ChartView(mode: ChartMode.year, type: ChartType.income),
          ChartView(mode: ChartMode.year, type: ChartType.expense),
          ChartView(mode: ChartMode.year, type: ChartType.diff),
        ],
      ),
    );
  }
}
