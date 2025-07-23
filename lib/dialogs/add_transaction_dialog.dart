import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../services/firebase_service.dart';

class AddTransactionDialog extends StatefulWidget {
  const AddTransactionDialog({super.key});

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _walletController = TextEditingController(text: 'Ví chính'); // Default wallet
  String _selectedCategory = 'Ăn uống';
  DateTime _selectedDate = DateTime.now();
  bool _isExpense = true;
  bool _isLoading = false;

  final List<String> _expenseCategories = [
    'Ăn uống', 'Mua sắm', 'Di chuyển', 'Giải trí', 'Hóa đơn', 'Sức khỏe', 'Khác'
  ];
  final List<String> _incomeCategories = ['Lương', 'Tiền chu cấp', 'Thưởng', 'Khác'];

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final amount = int.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) return;

    final transaction = TransactionModel(
      category: _selectedCategory,
      note: _noteController.text,
      amount: _isExpense ? -amount : amount,
      date: DateFormat('yyyy-MM-dd').format(_selectedDate),
      wallet: _walletController.text,
    );

    setState(() => _isLoading = true);
    await FirebaseService().addTransaction(transaction);
    setState(() => _isLoading = false);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final categories = _isExpense ? _expenseCategories : _incomeCategories;
    if (!categories.contains(_selectedCategory)) {
      _selectedCategory = categories.first;
    }

    return AlertDialog(
      title: Text(_isExpense ? "Thêm chi tiêu" : "Thêm thu nhập"),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Chi tiêu"),
                  Switch(
                    value: !_isExpense,
                    onChanged: (value) {
                      setState(() {
                        _isExpense = !value;
                        _selectedCategory = (_isExpense ? _expenseCategories : _incomeCategories).first;
                      });
                    },
                  ),
                  const Text("Thu nhập"),
                ],
              ),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: "Số tiền"),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập số tiền';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Số tiền không hợp lệ';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(labelText: "Ghi chú"),
              ),
              TextFormField(
                controller: _walletController,
                decoration: const InputDecoration(labelText: "Ví"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập ví';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: "Danh mục"),
                items: categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Ngày: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}",
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null && picked != _selectedDate) {
                        setState(() {
                          _selectedDate = picked;
                        });
                      }
                    },
                  ),
                ],
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
          onPressed: _isLoading ? null : _onSave,
          child: _isLoading
              ? const CircularProgressIndicator()
              : const Text("Lưu"),
        ),
      ],
    );
  }
}
