import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class DateSelector extends StatefulWidget {
  final DateTime initialDate;
  final DateTime lastDate;
  final DateTime? selectedDate;
  final Function(DateTime) onDateSelected;
  final Map<DateTime, int> scheduleCounts;

  const DateSelector({
    super.key,
    required this.initialDate,
    required this.lastDate,
    this.selectedDate,
    required this.onDateSelected,
    required this.scheduleCounts,
  });

  @override
  State<DateSelector> createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> {
  late DateTime _selectedDate;
  final ItemScrollController _itemScrollController = ItemScrollController();

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate ?? widget.initialDate;
  }

  List<DateTime> get _dates {
    List<DateTime> dates = [];
    DateTime current = widget.initialDate;
    // Loop until the day after the last date
    while (current.isBefore(widget.lastDate.add(const Duration(days: 1)))) {
      dates.add(current);
      current = current.add(const Duration(days: 1));
    }
    return dates;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ScrollablePositionedList.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _dates.length,
        itemScrollController: _itemScrollController,
        itemBuilder: (context, index) {
          DateTime date = _dates[index];
          bool isSunday = date.weekday == DateTime.sunday;
          bool isSelected =
              _selectedDate.year == date.year &&
              _selectedDate.month == date.month &&
              _selectedDate.day == date.day;

          int noOfSchedules =
              widget.scheduleCounts[DateTime(
                date.year,
                date.month,
                date.day,
              )] ??
              0;

          return _buildDayColumn(
            date,
            isSunday: isSunday,
            isSelected: isSelected,
            noOfSchedules: noOfSchedules,
            onTap: () {
              setState(() {
                _selectedDate = date;
              });
              widget.onDateSelected(date);
            },
          );
        },
      ),
    );
  }

  Widget _buildDayColumn(
    DateTime date, {
    bool isSunday = false,
    bool isSelected = false,
    int noOfSchedules = 0,
    Function()? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Text(
              getDayName(date.weekday),
              style: TextStyle(
                color: isSunday ? Colors.red : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? Colors.deepPurple : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  date.day.toString(),
                  style: TextStyle(
                    color:
                        isSelected
                            ? Colors.white
                            : (isSunday ? Colors.red : Colors.black),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            circleDots(noOfSchedules),
          ],
        ),
      ),
    );
  }

  Widget circleDots(int count) {
    if (count == 0) return const SizedBox(height: 8);

    List<Widget> dots = List.generate(
      count > 3 ? 3 : count,
      (index) => Container(
        width: 6,
        height: 6,
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: const BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
      ),
    );

    if (count > 3) {
      dots.add(
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
          child: Center(
            child: Text(
              '+',
              style: TextStyle(
                fontSize: 8,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }

    return Row(mainAxisAlignment: MainAxisAlignment.center, children: dots);
  }

  String getDayName(int weekday) {
    List<String> days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return days[weekday % 7];
  }
}
