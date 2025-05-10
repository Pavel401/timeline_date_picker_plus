import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:dotted_border/dotted_border.dart';

enum DateSelectedShape { circle, square, dotted_circle, dotted_square }

class DateScroller extends StatefulWidget {
  final DateTime initialDate;
  final DateTime lastDate;
  final DateTime? selectedDate;
  final Function(DateTime) onDateSelected;
  final Map<DateTime, int> scheduleCounts;
  final bool showScheduleDots;
  final DateSelectedShape? selectedShape;

  final bool? showMonthName;

  // Styling properties with sensible defaults
  final Color selectedDateBackgroundColor;
  final Color? dayNameColor;
  final Color? dayNameSundayColor;
  final Color? dayNumberColor;
  final Color? dayNumberSundayColor;
  final Color? dayNumberSelectedColor;
  final Color scheduleDotColor;
  final Color? monthTextColor;
  final Color? activeMonthTextColor;

  // Text styles with proper defaults
  final TextStyle dayNameTextStyle;
  final TextStyle dayNumberTextStyle;
  final TextStyle scheduleCountTextStyle;
  final TextStyle monthTextStyle;

  const DateScroller({
    super.key,
    required this.initialDate,
    required this.lastDate,
    this.selectedDate,
    required this.onDateSelected,

    required this.scheduleCounts,
    this.showScheduleDots = true,
    this.showMonthName = true,
    // Default styling
    this.selectedDateBackgroundColor = Colors.deepPurple,
    this.dayNameColor,
    this.dayNameSundayColor = Colors.red,
    this.dayNumberColor,
    this.dayNumberSundayColor = Colors.red,
    this.dayNumberSelectedColor = Colors.white,
    this.scheduleDotColor = Colors.blue,
    this.monthTextColor,
    this.activeMonthTextColor,
    this.selectedShape = DateSelectedShape.circle,
    this.dayNameTextStyle = const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
    this.dayNumberTextStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      height: 1.2,
    ),
    this.scheduleCountTextStyle = const TextStyle(
      fontSize: 8,
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
    this.monthTextStyle = const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
  });

  @override
  State<DateScroller> createState() => _DateScrollerState();
}

class _DateScrollerState extends State<DateScroller> {
  late DateTime _selectedDate;
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemScrollController _monthScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();
  final ItemPositionsListener _monthPositionsListener =
      ItemPositionsListener.create();
  late List<DateTime> _datesList; // Store dates list to avoid recalculation
  late List<DateTime> _monthsList; // Store unique months

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate ?? widget.initialDate;
    _datesList = _generateDates();
    _monthsList = _generateMonths();

    // Need to wait for the widget to be built before scrolling
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDate();
    });

    // Add listener to update months when dates scroll
    _itemPositionsListener.itemPositions.addListener(_updateMonthOnScroll);
  }

  @override
  void dispose() {
    // Remove listeners to prevent memory leaks
    _itemPositionsListener.itemPositions.removeListener(_updateMonthOnScroll);
    super.dispose();
  }

  // Update month scrolling based on visible dates
  void _updateMonthOnScroll() {
    if (_itemPositionsListener.itemPositions.value.isEmpty) return;

    // Get the index of the item in the middle of the viewport
    final middleIndex =
        _itemPositionsListener.itemPositions.value
            .where(
              (position) =>
                  position.itemTrailingEdge > 0 && position.itemLeadingEdge < 1,
            )
            .map((position) => position.index)
            .toList()
            .fold<int>(0, (prev, curr) => prev + curr) ~/
        _itemPositionsListener.itemPositions.value
            .where(
              (position) =>
                  position.itemTrailingEdge > 0 && position.itemLeadingEdge < 1,
            )
            .length;

    if (middleIndex >= 0 && middleIndex < _datesList.length) {
      DateTime currentVisibleDate = _datesList[middleIndex];

      // Find the corresponding month index
      int monthIndex = _monthsList.indexWhere(
        (month) =>
            month.year == currentVisibleDate.year &&
            month.month == currentVisibleDate.month,
      );

      // Only scroll if month is different from currently visible
      if (monthIndex >= 0 && _monthScrollController.isAttached) {
        _monthScrollController.scrollTo(
          index: monthIndex,
          duration: const Duration(milliseconds: 300),
          alignment: 0.5, // Center the month
        );
      }
    }
  }

  // Generate dates once and store them
  List<DateTime> _generateDates() {
    List<DateTime> dates = [];
    DateTime current = widget.initialDate;
    // Loop until the day after the last date
    while (current.isBefore(widget.lastDate.add(const Duration(days: 1)))) {
      dates.add(current);
      current = current.add(const Duration(days: 1));
    }
    return dates;
  }

  // Generate unique months for the timeline
  List<DateTime> _generateMonths() {
    Set<String> uniqueMonths = {};
    List<DateTime> months = [];

    for (DateTime date in _datesList) {
      // Create a unique key for each month-year combination
      String monthKey = '${date.year}-${date.month}';
      if (!uniqueMonths.contains(monthKey)) {
        uniqueMonths.add(monthKey);
        // Create a DateTime for the first day of this month
        months.add(DateTime(date.year, date.month, 1));
      }
    }

    return months;
  }

  // Scroll to the currently selected date
  void _scrollToSelectedDate() {
    if (_itemScrollController.isAttached) {
      int selectedIndex = _datesList.indexWhere(
        (date) =>
            date.year == _selectedDate.year &&
            date.month == _selectedDate.month &&
            date.day == _selectedDate.day,
      );

      if (selectedIndex >= 0) {
        _itemScrollController.scrollTo(
          index: selectedIndex,
          duration: const Duration(milliseconds: 300),
          alignment: 0.5, // Center the selected date
        );

        // Also scroll the month timeline to show the current month
        _scrollToSelectedMonth();
      }
    }
  }

  // Scroll to the month containing the selected date
  void _scrollToSelectedMonth() {
    if (_monthScrollController.isAttached) {
      int monthIndex = _monthsList.indexWhere(
        (month) =>
            month.year == _selectedDate.year &&
            month.month == _selectedDate.month,
      );

      if (monthIndex >= 0) {
        _monthScrollController.scrollTo(
          index: monthIndex,
          duration: const Duration(milliseconds: 300),
          alignment: 0.5, // Center the current month
        );
      }
    }
  }

  // Scroll to first date of selected month
  void _scrollToMonth(DateTime month) {
    // Find the first date in the selected month
    int dateIndex = _datesList.indexWhere(
      (date) => date.year == month.year && date.month == month.month,
    );

    if (dateIndex >= 0 && _itemScrollController.isAttached) {
      // Update selected date
      setState(() {
        _selectedDate = _datesList[dateIndex];
      });

      // Scroll to the date
      _itemScrollController.scrollTo(
        index: dateIndex,
        duration: const Duration(milliseconds: 300),
        alignment: 0.5, // Center the date
      );

      // Call the onDateSelected callback
      widget.onDateSelected(_selectedDate);
    }
  }

  // Helper method to get the appropriate text style for day name
  TextStyle _getDayNameTextStyle(bool isSunday, bool isSelected) {
    Color textColor =
        isSunday
            ? widget.dayNameSundayColor ?? Colors.red
            : widget.dayNameColor ?? Colors.black;

    return widget.dayNameTextStyle.copyWith(color: textColor);
  }

  // Helper method to get the appropriate text style for day number
  TextStyle _getDayNumberTextStyle(bool isSunday, bool isSelected) {
    Color textColor;

    if (isSelected) {
      textColor = widget.dayNumberSelectedColor ?? Colors.white;
    } else if (isSunday) {
      textColor = widget.dayNumberSundayColor ?? Colors.red;
    } else {
      textColor = widget.dayNumberColor ?? Colors.black;
    }

    return widget.dayNumberTextStyle.copyWith(color: textColor);
  }

  // Helper method to get the text style for month text
  TextStyle _getMonthTextStyle(bool isCurrentMonth) {
    Color textColor =
        isCurrentMonth
            ? widget.activeMonthTextColor ?? Colors.purple
            : widget.monthTextColor ?? Colors.grey;

    return widget.monthTextStyle.copyWith(color: textColor);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // Use min to take only necessary space
      children: [
        // Month Timeline
        widget.showMonthName == true
            ? SizedBox(
              height: 50,
              child: ScrollablePositionedList.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _monthsList.length,
                itemScrollController: _monthScrollController,
                itemPositionsListener: _monthPositionsListener,
                itemBuilder: (context, index) {
                  DateTime month = _monthsList[index];
                  bool isCurrentMonth =
                      month.year == _selectedDate.year &&
                      month.month == _selectedDate.month;

                  String monthDisplay;
                  if (index == 0 || month.month == 1) {
                    monthDisplay =
                        '${_getMonthName(month.month).toUpperCase()} ${month.year}';
                  } else {
                    monthDisplay = _getMonthName(month.month).toUpperCase();
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: InkWell(
                      onTap: () => _scrollToMonth(month),
                      child: Center(
                        child: Text(
                          monthDisplay,
                          style: _getMonthTextStyle(isCurrentMonth),
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
            : const SizedBox(),

        // Day Selector
        SizedBox(
          height: 100, // Set a fixed height for the day selector
          child: ScrollablePositionedList.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _datesList.length,
            itemScrollController: _itemScrollController,
            itemPositionsListener: _itemPositionsListener,
            itemBuilder: (context, index) {
              DateTime date = _datesList[index];
              bool isSunday = date.weekday == DateTime.sunday;
              bool isSelected =
                  _selectedDate.year == date.year &&
                  _selectedDate.month == date.month &&
                  _selectedDate.day == date.day;

              int noOfSchedules = 0;
              if (widget.showScheduleDots) {
                noOfSchedules =
                    widget.scheduleCounts[DateTime(
                      date.year,
                      date.month,
                      date.day,
                    )] ??
                    0;
              }

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
                  _scrollToSelectedMonth();
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDayColumn(
    DateTime date, {
    bool isSunday = false,
    bool isSelected = false,
    int noOfSchedules = 0,
    Function()? onTap,
  }) {
    String dayName = getDayName(date.weekday);
    String dayNumber = date.day.toString();
    String monthName = _getMonthName(date.month);

    // Get the selected shape from the widget (use circle by default)
    DateSelectedShape selectedShape =
        widget.selectedShape ?? DateSelectedShape.circle;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Semantics(
          label:
              'Select $dayName, $monthName ${date.day}, ${date.year}. ${widget.showScheduleDots ? 'Has $noOfSchedules schedules.' : ''}',
          selected: isSelected,
          button: true,
          child: Column(
            children: [
              Text(dayName, style: _getDayNameTextStyle(isSunday, isSelected)),
              const SizedBox(height: 8),
              // Change the shape of the selected date based on selectedShape
              SizedBox(
                width: 40,
                height: 40,
                child: _buildDateContainer(
                  dayNumber,
                  isSunday,
                  isSelected,
                  selectedShape,
                ),
              ),
              const SizedBox(height: 8),
              // Only show the dots if showScheduleDots is true
              widget.showScheduleDots
                  ? circleDots(noOfSchedules, isSunday)
                  : const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateContainer(
    String dayNumber,
    bool isSunday,
    bool isSelected,
    DateSelectedShape selectedShape,
  ) {
    TextStyle textStyle = _getDayNumberTextStyle(isSunday, isSelected);

    switch (selectedShape) {
      case DateSelectedShape.dotted_circle:
        return DottedBorder(
          color: isSelected ? Colors.white : widget.selectedDateBackgroundColor,
          strokeWidth: 1.5,
          dashPattern: const [4, 4],
          borderType: BorderType.Circle,
          child: Center(child: Text(dayNumber, style: textStyle)),
        );
      case DateSelectedShape.dotted_square:
        return DottedBorder(
          color: isSelected ? Colors.white : widget.selectedDateBackgroundColor,
          strokeWidth: 1.5,
          dashPattern: const [4, 4],
          borderType: BorderType.RRect,
          radius: const Radius.circular(4),
          child: Center(child: Text(dayNumber, style: textStyle)),
        );
      case DateSelectedShape.circle:
        return Container(
          decoration: BoxDecoration(
            color:
                isSelected
                    ? widget.selectedDateBackgroundColor
                    : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Center(child: Text(dayNumber, style: textStyle)),
        );
      case DateSelectedShape.square:
        return Container(
          decoration: BoxDecoration(
            color:
                isSelected
                    ? widget.selectedDateBackgroundColor
                    : Colors.transparent,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(child: Text(dayNumber, style: textStyle)),
        );
    }
  }

  Widget circleDots(int count, bool isSunday) {
    if (count == 0) return const SizedBox(height: 8);

    Color dotColor = widget.scheduleDotColor;

    List<Widget> dots = List.generate(
      count > 3 ? 3 : count,
      (index) => Container(
        width: 6,
        height: 6,
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
      ),
    );

    if (count > 3) {
      dots.add(
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          child: Center(child: Text('+', style: widget.scheduleCountTextStyle)),
        ),
      );
    }

    return Row(mainAxisAlignment: MainAxisAlignment.center, children: dots);
  }

  // Fixed day name mapping
  String getDayName(int weekday) {
    // DateTime weekday: Monday is 1, Sunday is 7
    List<String> days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return days[(weekday - 1) % 7]; // Adjust index to match weekday values
  }

  // Month name for accessibility and display
  String _getMonthName(int month) {
    List<String> months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1]; // Month is 1-based
  }
}
