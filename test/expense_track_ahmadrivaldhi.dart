import 'dart:io';
import 'package:intl/intl.dart';

List<Expense> _expenses = [];

enum ExpenseCategory { makanan, entertainment, transportasi, pribadi, lainnya }

class Expense {
  final double _amount;
  ExpenseCategory category;
  String? note;
  DateTime date;

  Expense({
    required double amount,
    required this.category,
    this.note,
    DateTime? date,
  }) : _amount =
           (amount < 0
               ? throw ArgumentError("Jumlah pengeluaran tidak boleh negatif!")
               : amount),
       date = date ?? DateTime.now();

  double get amount => _amount;

  @override
  String toString() {
    return "\$${_amount.toStringAsFixed(2)} - ${category.name.toUpperCase()}${note != null ? ' ($note)' : ''} - ${date.toLocal()}";
  }
}

void addExpense(
  double amount,
  ExpenseCategory category, {
  String? note,
  DateTime? date,
}) {
  date ??= DateTime.now();
  _expenses.add(
    Expense(amount: amount, category: category, note: note, date: date),
  );

  print(
    "DEBUG: Expense added on ${DateFormat('yyyy-MM-dd HH:mm:ss').format(date)}",
  );
}

void showExpenses(String? startDate, String? endDate) {
  DateFormat formatter = DateFormat('yyyy-MM-dd'); // Ensure consistent format
  DateTime oneYearAgo = DateTime.now().subtract(Duration(days: 365));
  DateTime futurePeriod = DateTime.now().add(Duration(days: 7));
  NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp',
  );

  if (_expenses.isEmpty) {
    print("Tidak ada pengeluaran yang dicatat.");
    return;
  }

  DateTime? start;
  DateTime? end;

  try {
    if (startDate != null && startDate.isNotEmpty) {
      start = formatter.parse(startDate);
      if (start.isBefore(oneYearAgo) || start.isAfter(futurePeriod)) {
        print(
          "Error: Start date must be within the last year and not exceed 7 days from today.",
        );
        return;
      }
    }
    if (endDate != null && endDate.isNotEmpty) {
      end = formatter.parse(endDate);
      if (end.isBefore(oneYearAgo) || end.isAfter(futurePeriod)) {
        print(
          "Error: End date must be within the last year and not exceed 7 days from today.",
        );
        return;
      }
    }
  } catch (e) {
    print("Invalid input: Date format should be YYYY-MM-DD.");
    return;
  }

  double totalAmount = 0.0;
  for (var expense in _expenses) {
    if ((start == null ||
            expense.date.isAfter(start.subtract(Duration(days: 1)))) &&
        (end == null || expense.date.isBefore(end.add(Duration(days: 1))))) {
      printExpenseDetails(expense, currencyFormatter, formatter);
      totalAmount += expense.amount;
    }
  }

  print("Total Amount: ${currencyFormatter.format(totalAmount)}");
  if (start != null && end != null) {
    print("Date Range: ${formatter.format(start)} - ${formatter.format(end)}");
  }
}

void printExpenseDetails(
  Expense expense,
  NumberFormat currencyFormatter,
  DateFormat formatter,
) {
  print("Amount: ${currencyFormatter.format(expense._amount)}");
  print("Category: ${expense.category.name.toUpperCase()}");
  print("Note: ${expense.note ?? '-'}");
  print("Expense Date: ${formatter.format(expense.date)}");
  print("");
}

void showExpensesLast30Days() {
  DateFormat formatter = DateFormat('yyyy-MM-dd');
  DateTime now = DateTime.now();
  DateTime thirtyDaysAgo = now.subtract(Duration(days: 30));

  DateTime start = DateTime(
    thirtyDaysAgo.year,
    thirtyDaysAgo.month,
    thirtyDaysAgo.day,
  );
  DateTime end = DateTime(now.year, now.month, now.day);

  showExpenses(
    formatter.format(start),
    formatter.format(end),
  );
}

void mainMenu() {
  print("\n=== Aplikasi Pencatat Pengeluaran ===");
  print("1. Tambah Pengeluaran");
  print("2. Lihat Riwayat Pengeluaran");
  print("3. Lihat Total Pengeluaran dalam 30 Hari Terakhir");
  print("4. Keluar");
  stdout.write("Pilihan Anda: ");
}

double getValidAmount() {
  double? amount;
  do {
    stdout.write("Jumlah pengeluaran: ");
    amount = double.tryParse(stdin.readLineSync() ?? '');
    if (amount == null || amount <= 0) {
      print("Input tidak valid! Masukkan angka yang benar dan lebih dari 0.");
    }
  } while (amount == null || amount <= 0);
  return amount;
}

ExpenseCategory getValidCategory() {
  while (true) {
    print("\nPilih kategori pengeluaran:");
    for (var i = 0; i < ExpenseCategory.values.length; i++) {
      print("${i + 1}. ${ExpenseCategory.values[i].name.toUpperCase()}");
    }
    stdout.write("Masukkan nomor kategori: ");
    String? input = stdin.readLineSync();

    int? index = int.tryParse(input ?? '');
    if (index != null && index > 0 && index <= ExpenseCategory.values.length) {
      return ExpenseCategory.values[index - 1];
    } else {
      print("Kategori tidak valid! Silakan coba lagi.");
    }
  }
}

void main() {
  while (true) {
    mainMenu();
    switch (stdin.readLineSync()) {
      case '1':
        double amount = getValidAmount();
        ExpenseCategory category = getValidCategory();

        stdout.write("Catatan (opsional): ");
        String? note = stdin.readLineSync();

        addExpense(amount, category, note: note);
        break;
      case '2':
        stdout.write("Tampilkan pengeluaran dari tanggal (YYYY-MM-DD): ");
        String? startDate = stdin.readLineSync();
        stdout.write("hingga tanggal (YYYY-MM-DD): ");
        String? endDate = stdin.readLineSync();
        showExpenses(startDate, endDate);
        break;
      case '3':
        showExpensesLast30Days();
        break;
      case '4':
        return;
      default:
        print("Pilihan tidak valid!");
    }
  }
}

