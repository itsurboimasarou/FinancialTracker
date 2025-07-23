import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chart_section.dart';

enum ChartMode { week, month, year }
enum ChartType { income, expense, diff }

class ChartView extends StatelessWidget {
  final ChartMode mode;
  final ChartType type;
  const ChartView({Key? key, required this.mode, required this.type}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('transactions').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs.map((doc) => doc.data()).toList();
        final result = _groupAndSum(docs, mode, type);

        return ChartSection(
          title: result['title'],
          amount: result['amount'],
          subtitle: result['subtitle'],
          subtitleColor: result['subtitleColor'],
          data: result['data'],
          labels: result['labels'],
          barColor: result['barColor'],
        );
      },
    );
  }

  Map<String, dynamic> _groupAndSum(List<Map<String, dynamic>> docs, ChartMode mode, ChartType type) {
    List<String> labels = [];
    List<double> data = [];
    int nowYear = DateTime.now().year;
    int nowMonth = DateTime.now().month;

    if (mode == ChartMode.week) {
      labels = List.generate(7, (i) {
        final d = DateTime.now().subtract(Duration(days: 6 - i));
        return '${d.day}/${d.month}';
      });
      for (int i = 0; i < 7; ++i) data.add(0);

      for (var t in docs) {
        DateTime d = (t['date'] is Timestamp)
            ? (t['date'] as Timestamp).toDate()
            : DateTime.tryParse('${t['date']}') ?? DateTime.now();
        int idx = DateTime.now().difference(d).inDays;
        if (idx >= 0 && idx < 7) {
          double value = (t['amount'] as num).toDouble();
          if (type == ChartType.income && t['type'] == 'income') data[6 - idx] += value;
          if (type == ChartType.expense && t['type'] == 'expense') data[6 - idx] += value;
          if (type == ChartType.diff) {
            if (t['type'] == 'income') data[6 - idx] += value;
            if (t['type'] == 'expense') data[6 - idx] -= value;
          }
        }
      }
    } else if (mode == ChartMode.month) {
      labels = List.generate(6, (i) {
        final m = (nowMonth - 5 + i);
        final month = (m > 0) ? m : (m + 12);
        return 'T$month';
      });
      for (int i = 0; i < 6; ++i) data.add(0);

      for (var t in docs) {
        DateTime d = (t['date'] is Timestamp)
            ? (t['date'] as Timestamp).toDate()
            : DateTime.tryParse('${t['date']}') ?? DateTime.now();
        int month = d.month;
        int year = d.year;
        for (int i = 0; i < 6; ++i) {
          int m = (nowMonth - 5 + i);
          int mm = (m > 0) ? m : (m + 12);
          int yy = (m > 0) ? nowYear : nowYear - 1;
          if (month == mm && year == yy) {
            double value = (t['amount'] as num).toDouble();
            if (type == ChartType.income && t['type'] == 'income') data[i] += value;
            if (type == ChartType.expense && t['type'] == 'expense') data[i] += value;
            if (type == ChartType.diff) {
              if (t['type'] == 'income') data[i] += value;
              if (t['type'] == 'expense') data[i] -= value;
            }
          }
        }
      }
    } else if (mode == ChartMode.year) {
      labels = List.generate(5, (i) => '${nowYear - 4 + i}');
      for (int i = 0; i < 5; ++i) data.add(0);

      for (var t in docs) {
        DateTime d = (t['date'] is Timestamp)
            ? (t['date'] as Timestamp).toDate()
            : DateTime.tryParse('${t['date']}') ?? DateTime.now();
        int year = d.year;
        for (int i = 0; i < 5; ++i) {
          if (year == nowYear - 4 + i) {
            double value = (t['amount'] as num).toDouble();
            if (type == ChartType.income && t['type'] == 'income') data[i] += value;
            if (type == ChartType.expense && t['type'] == 'expense') data[i] += value;
            if (type == ChartType.diff) {
              if (t['type'] == 'income') data[i] += value;
              if (t['type'] == 'expense') data[i] -= value;
            }
          }
        }
      }
    }

    double total = data.isNotEmpty ? data.last : 0;
    String title = '';
    String subtitle = '';
    Color subtitleColor = Colors.green;
    Color barColor = Colors.blue;
    if (type == ChartType.income) {
      title = mode == ChartMode.week ? 'Tổng thu tuần' : (mode == ChartMode.month ? 'Tổng thu tháng' : 'Tổng thu năm');
      subtitle = 'Tăng ${total.toStringAsFixed(0)}đ so với kỳ trước';
      subtitleColor = Colors.blue;
      barColor = Colors.blue;
    } else if (type == ChartType.expense) {
      title = mode == ChartMode.week ? 'Tổng chi tuần' : (mode == ChartMode.month ? 'Tổng chi tháng' : 'Tổng chi năm');
      subtitle = 'Tăng ${total.toStringAsFixed(0)}đ so với kỳ trước';
      subtitleColor = Colors.orange;
      barColor = Colors.orange;
    } else if (type == ChartType.diff) {
      title = mode == ChartMode.week ? 'Chênh lệch tuần' : (mode == ChartMode.month ? 'Chênh lệch tháng' : 'Chênh lệch năm');
      subtitle = (total >= 0 ? 'Dư ' : 'Âm ') + '${total.toStringAsFixed(0)}đ';
      subtitleColor = total >= 0 ? Colors.green : Colors.red;
      barColor = total >= 0 ? Colors.green : Colors.red;
    }

    return {
      'labels': labels,
      'data': data,
      'amount': total.toStringAsFixed(0) + 'đ',
      'title': title,
      'subtitle': subtitle,
      'subtitleColor': subtitleColor,
      'barColor': barColor,
    };
  }
}
