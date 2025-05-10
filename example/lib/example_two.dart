import 'package:dateline/timeline_date_picker_plus.dart';
import 'package:flutter/material.dart';

class ExampleTwo extends StatefulWidget {
  const ExampleTwo({super.key});

  @override
  State<ExampleTwo> createState() => _ExampleTwoState();
}

class _ExampleTwoState extends State<ExampleTwo> {
  DateTime _selectedDate = DateTime.now();

  List<int> cards = List.generate(100, (index) => index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Example Two')),
      body: Column(
        children: [
          DateScroller(
            initialDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 6)),
            selectedDate: _selectedDate,
            onDateSelected: (date) {
              setState(() {
                _selectedDate = date;
              });
            },
            showScheduleDots: true,
            scheduleCounts: {
              // DateTime(2025, 4, 29): 3,
              // DateTime(2025, 4, 30): 1,
            },
            selectedShape: DateSelectedShape.circle,
            selectedDateBackgroundColor: Colors.deepPurple,
            dayNameColor: Colors.black,
            dayNameSundayColor: Colors.red,
            dayNumberColor: Colors.black,
            dayNumberSundayColor: Colors.red,
            dayNumberSelectedColor: Colors.white,
            scheduleDotColor: Colors.blue,
            monthTextColor: Colors.grey,
            activeMonthTextColor: Colors.deepPurple,
            dayNameTextStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            dayNumberTextStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            monthTextStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: cards.length,
              itemBuilder: (_, index) {
                return Card(
                  child: ListTile(title: Text("Card ${cards[index]}")),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
