import 'package:dateline/date_selector.dart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Date Selector Example',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _selectedDate = DateTime.now();
  Map<DateTime, int> _scheduleCounts = {};

  @override
  void initState() {
    super.initState();
    // Sample data: 2 dots today, 1 dot tomorrow
    _scheduleCounts = {
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day):
          2,
      DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day + 1,
          ):
          1,
    };
  }

  List<DateTime> get _dates {
    List<DateTime> dates = [];
    DateTime current = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    ); // Strip time component
    DateTime lastDate = DateTime(2025, 12, 31); // Ensure no time component

    // Fixing the loop condition to include the last date
    while (current.isBefore(lastDate.add(const Duration(days: 1)))) {
      dates.add(current);
      current = current.add(const Duration(days: 1));
    }
    return dates;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Date Selector Example')),
      body: Column(
        children: [
          const SizedBox(height: 20),
          DateSelector(
            initialDate: DateTime.now(),
            lastDate: DateTime(2025, 12, 31),
            selectedDate: _selectedDate,
            scheduleCounts: _scheduleCounts,
            onDateSelected: (date) {
              setState(() {
                _selectedDate = date;
              });
            },
          ),
          const SizedBox(height: 20),
          Text(
            'Selected Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}',
          ),
        ],
      ),
    );
  }
}
