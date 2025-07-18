// ignore_for_file: deprecated_member_use

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Finance Compass',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(
          ThemeData.light().textTheme,
        ).apply(bodyColor: Colors.black87, displayColor: Colors.black87),
      ),
      home: const HomePage(),
    );
  }
}

class Transaction {
  final double amount;
  final String description;
  final bool isIncome;
  final DateTime date;

  Transaction(this.amount, this.description, this.isIncome, this.date);
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Transaction> transactions = [];
  DateTimeRange dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );

  void _addTransaction(Transaction tx) {
    setState(() {
      transactions.add(tx);
    });
  }

  void _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: dateRange,
    );
    if (picked != null) {
      setState(() {
        dateRange = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = transactions
        .where(
          (tx) =>
              tx.date.isAfter(
                dateRange.start.subtract(const Duration(days: 1)),
              ) &&
              tx.date.isBefore(dateRange.end.add(const Duration(days: 1))),
        )
        .toList();

    double income = filtered
        .where((tx) => tx.isIncome)
        .fold(0.0, (sum, tx) => sum + tx.amount);
    double expense = filtered
        .where((tx) => !tx.isIncome)
        .fold(0.0, (sum, tx) => sum + tx.amount);
    double balance = income - expense;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        title: const Text(
          'Finance कम्पास 🧭',
          style: TextStyle(letterSpacing: -0.5),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Showing from ${DateFormat.yMMMd().format(dateRange.start)} to ${DateFormat.yMMMd().format(dateRange.end)}",
              style: const TextStyle(fontSize: 14, letterSpacing: -0.5),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCard("💰 Income", income, Colors.green),
                _buildCard("💸 Expense", expense, Colors.red),
                _buildCard("🧾 Balance", balance, Colors.blue),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              "Transactions",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: filtered.isEmpty
                  ? const Center(child: Text("No transactions in range"))
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (ctx, i) {
                        final tx = filtered[i];
                        return ListTile(
                          leading: Text(tx.isIncome ? "📈" : "📉"),
                          title: Text(
                            tx.description,
                            style: const TextStyle(letterSpacing: -0.5),
                          ),
                          subtitle: Text(
                            DateFormat.yMMMd().add_jm().format(tx.date),
                            style: const TextStyle(
                              fontSize: 11,
                              letterSpacing: -0.5,
                            ),
                          ),
                          trailing: Text(
                            "${tx.isIncome ? "+ " : "- "}NPR ${tx.amount.toStringAsFixed(2)}",
                            style: TextStyle(
                              color: tx.isIncome ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.5,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                onPressed: _selectDateRange,
                child: const Text(
                  "Select Date Range",
                  style: TextStyle(fontSize: 13, letterSpacing: -0.5),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                onPressed: () async {
                  final tx = await Navigator.push<Transaction>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddTransactionPage(),
                    ),
                  );
                  if (tx != null) _addTransaction(tx);
                },
                child: const Text(
                  "Add Transaction",
                  style: TextStyle(fontSize: 13, letterSpacing: -0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, double amount, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "NPR ${amount.toStringAsFixed(2)}",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  bool isIncome = true;
  DateTime dateTime = DateTime.now();

  void _submit() {
    final desc = _descController.text;
    final amt = double.tryParse(_amountController.text);
    if (desc.isEmpty || amt == null) return;
    final tx = Transaction(amt, desc, isIncome, dateTime);
    Navigator.pop(context, tx);
  }

  void _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: dateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(dateTime),
    );
    if (time == null) return;

    setState(() {
      dateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Add Transaction",
          style: TextStyle(letterSpacing: -0.5),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          children: [
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: "Amount (NPR)",
                labelStyle: TextStyle(letterSpacing: -0.5),
              ),
              keyboardType: TextInputType.number,
              style: const TextStyle(letterSpacing: -0.5),
            ),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: "Description",
                labelStyle: TextStyle(letterSpacing: -0.5),
              ),
              style: const TextStyle(letterSpacing: -0.5),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ChoiceChip(
                  label: const Text(
                    "Income",
                    style: TextStyle(fontSize: 13, letterSpacing: -0.5),
                  ),
                  selected: isIncome,
                  onSelected: (_) => setState(() => isIncome = true),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text(
                    "Expense",
                    style: TextStyle(fontSize: 13, letterSpacing: -0.5),
                  ),
                  selected: !isIncome,
                  onSelected: (_) => setState(() => isIncome = false),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Date: ${DateFormat.yMMMd().add_jm().format(dateTime)}",
                    style: const TextStyle(fontSize: 13, letterSpacing: -0.5),
                  ),
                ),
                TextButton(
                  onPressed: _pickDateTime,
                  child: const Text(
                    "Pick Date & Time",
                    style: TextStyle(fontSize: 13, letterSpacing: -0.5),
                  ),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _submit,
              child: const Text(
                "Save",
                style: TextStyle(fontSize: 13, letterSpacing: -0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
