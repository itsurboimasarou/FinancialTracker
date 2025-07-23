import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../services/firebase_service.dart';

class AnalyticsContent extends StatefulWidget {
  const AnalyticsContent({super.key});

  @override
  State<AnalyticsContent> createState() => _AnalyticsContentState();
}

class _AnalyticsContentState extends State<AnalyticsContent> {
  String selectedMonth = 'July';
  String selectedType = 'Money Amount';
  String selectedYear = '2025';

  final months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  final types = ['Money Amount', 'Percentage Amount'];
  final years = ['2023', '2024', '2025'];

  final FirebaseService _firebaseService = FirebaseService();
  List<Map<String, dynamic>> _spendings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSpendings();
  }

  Future<void> _fetchSpendings() async {
    setState(() => _isLoading = true);

    final selectedMonthIndex = months.indexOf(selectedMonth) + 1;
    final selectedYearInt = int.parse(selectedYear);

    final transactions = await _firebaseService.getAllTransactions().first;

    final filtered = transactions.where((t) {
      final date = DateTime.tryParse(t.date);
      return t.amount < 0 &&
          date != null &&
          date.month == selectedMonthIndex &&
          date.year == selectedYearInt;
    }).toList();

    final Map<String, double> categorySpending = {};
    for (final t in filtered) {
      categorySpending.update(t.category, (value) => value + t.amount.abs(),
          ifAbsent: () => t.amount.abs().toDouble());
    }

    setState(() {
      _spendings = categorySpending.entries
          .map((e) => {'category': e.key, 'amount': e.value})
          .toList();
      _isLoading = false;
    });
  }

  Color _getColorForCategory(String category) {
    final hash = category.hashCode;
    return Color((hash & 0xFFFFFF) | 0xFF000000).withOpacity(0.8);
  }

  List<PieChartSectionData> _buildPieChartSections() {
    final totalSpending =
        _spendings.fold<double>(0, (sum, item) => sum + item['amount']);
    if (totalSpending == 0) {
      return [
        PieChartSectionData(
          color: Colors.grey,
          value: 1,
          title: 'No spending',
          radius: 60,
          titleStyle: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        )
      ];
    }

    return _spendings.map((item) {
      final percentage = (item['amount'] / totalSpending) * 100;
      return PieChartSectionData(
        color: _getColorForCategory(item['category']),
        value: item['amount'].toDouble(),
        title: selectedType == 'Money Amount'
            ? NumberFormat.compact().format(item['amount'])
            : '${percentage.toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'shopping':
        return Icons.shopping_bag_outlined;
      case 'gift':
        return Icons.card_giftcard_outlined;
      case 'food':
        return Icons.restaurant_outlined;
      case 'transport':
        return Icons.directions_bus_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButton<String>(
                  value: selectedMonth,
                  isExpanded: true,
                  items: months.map((m) => DropdownMenuItem(
                    value: m, child: Text(m),
                  )).toList(),
                  onChanged: (v) => setState(() {
                    selectedMonth = v!;
                    _fetchSpendings();
                  }),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButton<String>(
                  value: selectedType,
                  isExpanded: true,
                  items: types.map((t) => DropdownMenuItem(
                    value: t, child: Text(t),
                  )).toList(),
                  onChanged: (v) => setState(() => selectedType = v!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : PieChart(
                    PieChartData(
                      sections: _buildPieChartSections(),
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                    ),
                  ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text('Year:', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: selectedYear,
                items: years.map((y) => DropdownMenuItem(
                  value: y, child: Text(y),
                )).toList(),
                onChanged: (v) => setState(() {
                  selectedYear = v!;
                  _fetchSpendings();
                }),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('What we spend & how much:', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _spendings.isEmpty
                    ? const Center(child: Text("No spending data for this period."))
                    : ListView.builder(
                        itemCount: _spendings.length,
                        itemBuilder: (context, idx) {
                          final item = _spendings[idx];
                          return Card(
                            elevation: 1,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              leading: Icon(
                                _getIconForCategory(item['category'] as String),
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              title: Text(item['category'] as String),
                              trailing: Text(
                                NumberFormat.currency(locale: 'vi_VN', symbol: '₫')
                                    .format(item['amount']),
                                style: TextStyle(
                                    color: Theme.of(context).colorScheme.tertiary,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
