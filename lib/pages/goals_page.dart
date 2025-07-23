import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/goal_model.dart';
import '../services/firebase_service.dart';
import '../dialogs/add_goal_dialog.dart';
import '../dialogs/edit_goal_dialog.dart';

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat("#,###");

    return Scaffold(
      body: StreamBuilder<List<GoalModel>>(
        stream: _firebaseService.getAllGoals(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Chưa có mục tiêu nào."));
          }

          final goals = snapshot.data!;

          return ListView.builder(
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final goal = goals[index];
              final targetDate = DateTime.parse(goal.targetDate);
              final daysLeft = targetDate.difference(DateTime.now()).inDays;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(goal.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Mục tiêu: ${numberFormat.format(goal.targetAmount)} ₫"),
                      Text("Tiết kiệm: ${numberFormat.format(goal.monthlyAmount)} ₫/tháng"),
                      Text("Ngày hết hạn: ${DateFormat('dd/MM/yyyy').format(targetDate)}"),
                      if (daysLeft > 0)
                        Text("Còn lại: $daysLeft ngày", style: const TextStyle(color: Colors.green)),
                      if (daysLeft <= 0)
                        const Text("Đã hết hạn", style: TextStyle(color: Colors.red)),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () async {
                          await showDialog(
                            context: context,
                            builder: (_) => EditGoalDialog(goal: goal, onUpdated: () {}),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text("Xác nhận xóa"),
                              content: const Text("Bạn có chắc chắn muốn xóa mục tiêu này?"),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Hủy")),
                                ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Xóa")),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await _firebaseService.deleteGoal(goal.id!);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showDialog(
            context: context,
            builder: (context) => const AddGoalDialog(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
