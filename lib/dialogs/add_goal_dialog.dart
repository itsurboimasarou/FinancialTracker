import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/goal_model.dart';
import '../services/firebase_service.dart';

class AddGoalDialog extends StatefulWidget {
  const AddGoalDialog({super.key});

  @override
  State<AddGoalDialog> createState() => _AddGoalDialogState();
}

class _AddGoalDialogState extends State<AddGoalDialog> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final targetAmountController = TextEditingController();
  DateTime? targetDate;
  int calculatedMonthly = 0;
  String warning = '';
  bool isLoading = false;

  Future<void> calculateMonthlySaving() async {
    if (targetAmountController.text.isEmpty || targetDate == null) return;

    final targetAmount = int.tryParse(targetAmountController.text) ?? 0;
    final now = DateTime.now();
    final monthsLeft = (targetDate!.difference(now).inDays / 30).ceil();

    if (monthsLeft <= 0) {
      setState(() {
        warning = '⚠️ Ngày hoàn thành phải sau hôm nay.';
        calculatedMonthly = 0;
      });
      return;
    }

    final transactions = await FirebaseService().getAllTransactions().first;
    final income = transactions
        .where((t) => t.amount > 0 && (t.category == 'Lương' || t.category == 'Tiền chu cấp'))
        .fold<int>(0, (sum, t) => sum + t.amount);

    final nowMonth = now.month;
    final nowYear = now.year;
    final expenses = transactions
        .where((t) {
          final date = DateTime.tryParse(t.date);
          return t.amount < 0 && date != null && date.month == nowMonth && date.year == nowYear;
        })
        .fold<int>(0, (sum, t) => sum + t.amount.abs());

    final monthlySaving = (targetAmount / monthsLeft).ceil();
    final leftover = income - expenses;

    setState(() {
      calculatedMonthly = monthlySaving;
      if (monthlySaving > leftover) {
        warning = '⚠️ Cần tiết kiệm $monthlySaving ₫/tháng nhưng hiện chỉ dư $leftover ₫. Cần giảm chi tiêu.';
      } else {
        warning = '';
      }
    });
  }

  Future<void> onSave() async {
    if (!formKey.currentState!.validate() || targetDate == null || calculatedMonthly <= 0) return;

    final goal = GoalModel(
      name: nameController.text.trim(),
      targetAmount: int.parse(targetAmountController.text),
      monthlyAmount: calculatedMonthly,
      targetDate: DateFormat('yyyy-MM-dd').format(targetDate!),
    );

    setState(() => isLoading = true);
    await FirebaseService().addGoal(goal);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Thêm mục tiêu tài chính"),
      content: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Tên mục tiêu"),
                validator: (v) => v!.isEmpty ? "Không được để trống" : null,
              ),
              TextFormField(
                controller: targetAmountController,
                decoration: const InputDecoration(labelText: "Số tiền mục tiêu"),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? "Không được để trống" : null,
                onChanged: (_) => calculateMonthlySaving(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      targetDate == null
                          ? "Chưa chọn ngày"
                          : "Ngày hoàn thành: ${DateFormat('dd/MM/yyyy').format(targetDate!)}",
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => targetDate = picked);
                        calculateMonthlySaving();
                      }
                    },
                  ),
                ],
              ),
              if (calculatedMonthly > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    "Dự kiến tiết kiệm: ${NumberFormat("#,###").format(calculatedMonthly)} ₫/tháng",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              if (warning.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    warning,
                    style: TextStyle(color: Colors.orange.shade700),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Hủy"),
        ),
        ElevatedButton(
          onPressed: isLoading ? null : onSave,
          child: isLoading ? const CircularProgressIndicator() : const Text("Lưu"),
        ),
      ],
    );
  }
}
