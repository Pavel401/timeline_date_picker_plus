import 'package:dateline/timeline_date_picker_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateSelectorDemo extends StatefulWidget {
  const DateSelectorDemo({super.key});

  @override
  State<DateSelectorDemo> createState() => _DateSelectorDemoState();
}

class _DateSelectorDemoState extends State<DateSelectorDemo> {
  // Date parameters
  final DateTime _initialDate = DateTime.now();
  final DateTime _lastDate = DateTime.now().add(const Duration(days: 365));
  DateTime _selectedDate = DateTime.now();

  bool _showMonthName = true;

  // Styling parameters
  bool _showScheduleDots = true;
  DateSelectedShape _selectedShape = DateSelectedShape.circle;
  Color _selectedDateBackgroundColor = Colors.deepPurple;
  Color _dayNameColor = Colors.black;
  Color _dayNameSundayColor = Colors.red;
  Color _dayNumberColor = Colors.black;
  Color _dayNumberSundayColor = Colors.red;
  Color _dayNumberSelectedColor = Colors.white;
  Color _scheduleDotColor = Colors.blue;
  Color _monthTextColor = Colors.grey;
  Color _activeMonthTextColor = Colors.deepPurple;

  // Text style sizes
  double _dayNameFontSize = 14;
  double _dayNumberFontSize = 16;
  double _monthFontSize = 14;

  // Mock data for schedule counts
  Map<DateTime, int> _scheduleCounts = {};

  @override
  void initState() {
    super.initState();
    // Generate some sample schedule data
    _generateSampleScheduleData();
  }

  void _generateSampleScheduleData() {
    final Map<DateTime, int> schedules = {};
    final now = DateTime.now();

    // Add some random schedule counts for the next 30 days
    for (int i = 0; i < 30; i++) {
      final date = DateTime(now.year, now.month, now.day + i);
      // Every third day has 1 schedule, every 5th day has 2, every 10th day has 3
      if (i % 10 == 0) {
        schedules[date] = 3;
      } else if (i % 5 == 0) {
        schedules[date] = 2;
      } else if (i % 3 == 0) {
        schedules[date] = 1;
      }
    }

    setState(() {
      _scheduleCounts = schedules;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Date Selector Customizer'),
        backgroundColor: _selectedDateBackgroundColor.withOpacity(0.7),
      ),
      body: Column(
        children: [
          // Date Selector Widget
          DateScroller(
            initialDate: _initialDate,
            lastDate: _lastDate,
            selectedDate: _selectedDate,
            onDateSelected: (date) {
              setState(() {
                _selectedDate = date;
              });
            },
            showMonthName: _showMonthName,
            scheduleCounts: _scheduleCounts,
            showScheduleDots: _showScheduleDots,
            selectedShape: _selectedShape,
            selectedDateBackgroundColor: _selectedDateBackgroundColor,
            dayNameColor: _dayNameColor,
            dayNameSundayColor: _dayNameSundayColor,
            dayNumberColor: _dayNumberColor,
            dayNumberSundayColor: _dayNumberSundayColor,
            dayNumberSelectedColor: _dayNumberSelectedColor,
            scheduleDotColor: _scheduleDotColor,
            monthTextColor: _monthTextColor,
            activeMonthTextColor: _activeMonthTextColor,
            dayNameTextStyle: TextStyle(
              fontSize: _dayNameFontSize,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
            dayNumberTextStyle: TextStyle(
              fontSize: _dayNumberFontSize,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
            monthTextStyle: TextStyle(
              fontSize: _monthFontSize,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),

          // Date information display
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _selectedDateBackgroundColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Selected: ${DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Events: ${_scheduleCounts[DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day)] ?? 0}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _scheduleDotColor,
                  ),
                ),
              ],
            ),
          ),

          // Configuration panel
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Customize DateSelector',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),

                    // Basic configuration
                    _buildSectionTitle('Basic Configuration'),

                    // Shape selection
                    _buildDropdownSetting<DateSelectedShape>(
                      'Selected Date Shape',
                      _selectedShape,
                      DateSelectedShape.values,
                      (shape) => shape.toString().split('.').last,
                      (value) => setState(() => _selectedShape = value),
                    ),

                    // Show schedule dots
                    SwitchListTile(
                      title: const Text('Show Schedule Dots'),
                      value: _showScheduleDots,
                      onChanged: (value) {
                        setState(() {
                          _showScheduleDots = value;
                        });
                      },
                    ),

                    SwitchListTile(
                      title: const Text('Show Month Names'),
                      value: _showMonthName,
                      onChanged: (value) {
                        setState(() {
                          _showMonthName = value;
                        });
                      },
                    ),
                    // Color configuration
                    _buildSectionTitle('Color Configuration'),

                    // Selected date background color
                    _buildColorSetting(
                      'Selected Date Background',
                      _selectedDateBackgroundColor,
                      (color) =>
                          setState(() => _selectedDateBackgroundColor = color),
                    ),

                    // Schedule dot color
                    _buildColorSetting(
                      'Schedule Dot Color',
                      _scheduleDotColor,
                      (color) => setState(() => _scheduleDotColor = color),
                    ),

                    // Day name colors
                    _buildColorSetting(
                      'Day Name Color',
                      _dayNameColor,
                      (color) => setState(() => _dayNameColor = color),
                    ),

                    _buildColorSetting(
                      'Sunday Name Color',
                      _dayNameSundayColor,
                      (color) => setState(() => _dayNameSundayColor = color),
                    ),

                    // Day number colors
                    _buildColorSetting(
                      'Day Number Color',
                      _dayNumberColor,
                      (color) => setState(() => _dayNumberColor = color),
                    ),

                    _buildColorSetting(
                      'Sunday Number Color',
                      _dayNumberSundayColor,
                      (color) => setState(() => _dayNumberSundayColor = color),
                    ),

                    _buildColorSetting(
                      'Selected Number Color',
                      _dayNumberSelectedColor,
                      (color) =>
                          setState(() => _dayNumberSelectedColor = color),
                    ),

                    // Month colors
                    _buildColorSetting(
                      'Month Text Color',
                      _monthTextColor,
                      (color) => setState(() => _monthTextColor = color),
                    ),

                    _buildColorSetting(
                      'Active Month Color',
                      _activeMonthTextColor,
                      (color) => setState(() => _activeMonthTextColor = color),
                    ),

                    // Font size configuration
                    _buildSectionTitle('Font Sizes'),

                    _buildSliderSetting(
                      'Day Name Font Size',
                      _dayNameFontSize,
                      10,
                      20,
                      (value) => setState(() => _dayNameFontSize = value),
                    ),

                    _buildSliderSetting(
                      'Day Number Font Size',
                      _dayNumberFontSize,
                      12,
                      24,
                      (value) => setState(() => _dayNumberFontSize = value),
                    ),

                    _buildSliderSetting(
                      'Month Font Size',
                      _monthFontSize,
                      10,
                      20,
                      (value) => setState(() => _monthFontSize = value),
                    ),

                    const SizedBox(height: 20),

                    // Reset button
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedDateBackgroundColor,
                          foregroundColor: _dayNumberSelectedColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            // Reset to default values
                            _selectedShape = DateSelectedShape.circle;
                            _showScheduleDots = true;
                            _selectedDateBackgroundColor = Colors.deepPurple;
                            _dayNameColor = Colors.black;
                            _dayNameSundayColor = Colors.red;
                            _dayNumberColor = Colors.black;
                            _dayNumberSundayColor = Colors.red;
                            _dayNumberSelectedColor = Colors.white;
                            _scheduleDotColor = Colors.blue;
                            _monthTextColor = Colors.grey;
                            _activeMonthTextColor = Colors.deepPurple;
                            _dayNameFontSize = 14;
                            _dayNumberFontSize = 16;
                            _monthFontSize = 14;
                          });
                        },
                        child: const Text('Reset to Default'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: _selectedDateBackgroundColor,
        ),
      ),
    );
  }

  Widget _buildColorSetting(
    String label,
    Color currentColor,
    Function(Color) onColorChanged,
  ) {
    final List<Color> colorOptions = [
      Colors.deepPurple,
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.pink,
      Colors.teal,
      Colors.amber,
      Colors.indigo,
      Colors.brown,
      Colors.grey,
      Colors.black,
      Colors.white,
    ];

    return Row(
      children: [
        Expanded(flex: 2, child: Text(label)),
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...colorOptions.map((color) {
                  final bool isSelected = currentColor.value == color.value;
                  return InkWell(
                    onTap: () => onColorChanged(color),
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              isSelected ? Colors.black : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow:
                            isSelected
                                ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                                : null,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliderSetting(
    String label,
    double value,
    double min,
    double max,
    Function(double) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(label), Text('${value.toStringAsFixed(1)}px')],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: ((max - min) * 2).toInt(),
          activeColor: _selectedDateBackgroundColor,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDropdownSetting<T>(
    String label,
    T currentValue,
    List<T> options,
    String Function(T) getLabel,
    Function(T) onChanged,
  ) {
    return Row(
      children: [
        Expanded(flex: 1, child: Text(label)),
        Expanded(
          flex: 2,
          child: DropdownButton<T>(
            value: currentValue,
            isExpanded: true,
            onChanged: (T? value) {
              if (value != null) {
                onChanged(value);
              }
            },
            items:
                options.map<DropdownMenuItem<T>>((T value) {
                  return DropdownMenuItem<T>(
                    value: value,
                    child: Text(getLabel(value)),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }
}
