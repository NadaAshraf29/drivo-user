import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/src/extensions/export.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class HomeArabicDateTimePicker extends StatefulWidget {
  final Function(DateTime) onDateTimeSelected;
  const HomeArabicDateTimePicker({Key? key, required this.onDateTimeSelected})
      : super(key: key);

  @override
  _HomeArabicDateTimePickerState createState() =>
      _HomeArabicDateTimePickerState();
}

class _HomeArabicDateTimePickerState extends State<HomeArabicDateTimePicker> {
  DateTime selectedDate = DateTime.now();
  late int selectedHour;
  late int selectedMinute;
  late bool isAM;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedDate = DateTime(now.year, now.month, now.day);
    selectedHour =
        now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    selectedMinute = now.minute;
    isAM = now.hour < 12;
  }

  final List<String> weekDays = [
    'SUN',
    'MON',
    'TUE',
    'WED',
    'THU',
    'FRI',
    'SAT'
  ];
  final List<String> months = [
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
    'December'
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.73,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          // Drag handle
          Container(
            margin: EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          _buildHeader(),
          _buildCalendar(),
          _buildTimeSelector(),
          _buildActionButton(),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        children: [
          GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Image.asset(
                Images.closeIcon,
                width: MediaQuery.sizeOf(context).width * 0.09,
              )),
          Expanded(
            child: Center(
              child: Text(
                'choose_date_and_time'.tr,
                style: textBold.copyWith(fontSize: 20, color: Colors.black),
              ),
            ),
          ),

          SizedBox(width: 24), // Balance the close icon
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildMonthHeader(),
          SizedBox(height: 20),
          _buildWeekDaysHeader(),
          SizedBox(height: 15),
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildMonthHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text('${months[selectedDate.month - 1]} ${selectedDate.year}',
                style: textSemiBold.copyWith(
                  fontSize: 17,
                )),
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).primaryColor.withOpacity(0.5),
              size: 28,
            ),
          ],
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  selectedDate =
                      DateTime(selectedDate.year, selectedDate.month - 1);
                });
              },
              child: Icon(
                Icons.chevron_left,
                color: Theme.of(context).primaryColor.withOpacity(0.5),
                size: 28,
              ),
            ),
            SizedBox(width: 5),
            GestureDetector(
              onTap: () {
                setState(() {
                  selectedDate =
                      DateTime(selectedDate.year, selectedDate.month + 1);
                });
              },
              child: Icon(
                Icons.chevron_right,
                color: Theme.of(context).primaryColor.withOpacity(0.5),
                size: 28,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeekDaysHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: weekDays
          .map((day) => Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    final lastDayOfMonth =
        DateTime(selectedDate.year, selectedDate.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday % 7;
    final daysInMonth = lastDayOfMonth.day;

    List<Widget> rows = [];
    List<Widget> currentWeek = [];

    // Add empty cells for days before the first day of the month
    for (int i = 0; i < firstWeekday; i++) {
      currentWeek.add(Expanded(child: Container(height: 45)));
    }

    // Add cells for each day of the month
    for (int day = 1; day <= daysInMonth; day++) {
      final isSelected = day == selectedDate.day &&
          selectedDate.month ==
              DateTime(selectedDate.year, selectedDate.month, day).month &&
          selectedDate.year ==
              DateTime(selectedDate.year, selectedDate.month, day).year;
      final now = DateTime.now();
      final isToday = day == now.day &&
          selectedDate.month == now.month &&
          selectedDate.year == now.year;

      currentWeek.add(
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                selectedDate =
                    DateTime(selectedDate.year, selectedDate.month, day);
              });
            },
            child: Container(
              height: 45,
              margin: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : (isToday && !isSelected
                        ? Theme.of(context).primaryColor.withOpacity(0.3)
                        : Colors.transparent),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  day.toString(),
                  style: TextStyle(
                    fontSize: 16,
                    color: isSelected
                        ? Colors.white
                        : (isToday ? Colors.white : Colors.black87),
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : (isToday ? FontWeight.w600 : FontWeight.normal),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // If we have 7 days or it's the last day, complete the row
      if (currentWeek.length == 7 || day == daysInMonth) {
        // Fill remaining cells if needed
        while (currentWeek.length < 7) {
          currentWeek.add(Expanded(child: Container(height: 45)));
        }

        rows.add(
          Padding(
            padding: EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.from(currentWeek),
            ),
          ),
        );
        currentWeek.clear();
      }
    }

    return Column(children: rows);
  }

  Widget _buildTimeSelector() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTimeToggle('AM', isAM, () {
                  setState(() {
                    isAM = true;
                  });
                }),
                Container(
                  width: 1,
                  height: 30,
                  color: Colors.grey[300],
                ),
                _buildTimeToggle('PM', !isAM, () {
                  setState(() {
                    isAM = false;
                  });
                }),
              ],
            ),
          ),

          Spacer(),

          // Time Display
          Container(
            width: MediaQuery.of(context).size.width * 0.17,
            height: MediaQuery.of(context).size.height * 0.05,
            decoration: BoxDecoration(
              color: Color(0xffF5F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: GestureDetector(
                onTap: _showTimePicker,
                child: Text(
                  '${selectedHour.toString().padLeft(2, '0')}:${selectedMinute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),

          Spacer(),

          // Arabic Time Label
          Text(
            'time'.tr,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeToggle(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey[100] : Colors.transparent,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  DateTime _createDateTime() {
    try {
      return DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        isAM ? selectedHour : selectedHour + 12,
        selectedMinute,
      );
    } catch (e) {
      print('Error creating DateTime: $e');
      return DateTime.now();
    }
  }

  void _showTimePicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: 300,
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'choose_time'.tr,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        // Hour selector
                        Expanded(
                          child: Column(
                            children: [
                              Text('hour'.tr,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500)),
                              Expanded(
                                child: ListWheelScrollView.useDelegate(
                                  itemExtent: 50,
                                  onSelectedItemChanged: (index) {
                                    setModalState(() {
                                      selectedHour = index + 1;
                                    });
                                  },
                                  childDelegate: ListWheelChildBuilderDelegate(
                                    childCount: 12,
                                    builder: (context, index) {
                                      final hour = index + 1;
                                      final isSelected = hour == selectedHour;
                                      return Container(
                                        alignment: Alignment.center,
                                        child: Text(
                                          hour.toString().padLeft(2, '0'),
                                          style: TextStyle(
                                            fontSize: isSelected ? 24 : 16,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            color: isSelected
                                                ? Theme.of(context).primaryColor
                                                : Colors.black54,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Minute selector
                        Expanded(
                          child: Column(
                            children: [
                              Text('minute'.tr,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500)),
                              Expanded(
                                child: ListWheelScrollView.useDelegate(
                                  itemExtent: 50,
                                  onSelectedItemChanged: (index) {
                                    setModalState(() {
                                      selectedMinute = index;
                                    });
                                  },
                                  childDelegate: ListWheelChildBuilderDelegate(
                                    childCount: 60,
                                    builder: (context, index) {
                                      final isSelected =
                                          index == selectedMinute;
                                      return Container(
                                        alignment: Alignment.center,
                                        child: Text(
                                          index.toString().padLeft(2, '0'),
                                          style: TextStyle(
                                            fontSize: isSelected ? 24 : 16,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            color: isSelected
                                                ? Theme.of(context).primaryColor
                                                : Colors.black54,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(16),
                    child: ButtonWidget(
                      backgroundColor: Theme.of(context).primaryColor,
                      onPressed: () {
                        final selectedDateTime = _createDateTime();
                        final now = DateTime.now();

                        if (selectedDateTime.isBefore(now)) {
                          Get.snackbar(
                            'Error',
                            'Please select a future time',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          return;
                        }

                        setState(() {});
                        Navigator.pop(context);
                      },
                      buttonText: 'choose'.tr,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActionButton() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      width: double.infinity,
      child: ButtonWidget(
        buttonText: 'choose_date'.tr,
        radius: 10,
        onPressed: () {
          final selectedDateTime = _createDateTime();
          final now = DateTime.now();

          if (selectedDateTime.isBefore(now)) {
            Get.snackbar(
              'Error',
              'Please select a future time',
              snackPosition: SnackPosition.BOTTOM,
            );
            return;
          }

          widget.onDateTimeSelected(selectedDateTime);
          Navigator.pop(context);
        },
      ),
    );
  }
}
