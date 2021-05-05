library event_nepali_calendar;

import 'package:flutter/material.dart';
import 'package:nepali_utils/nepali_utils.dart';
import './simple_gesture_detector.dart';
import './calendar_tile.dart';
import 'constant.dart';

typedef DayBuilder(BuildContext context, NepaliDateTime day);

class Range {
  final NepaliDateTime from;
  final NepaliDateTime to;
  Range(this.from, this.to);
}

class Calendar extends StatefulWidget {
  final ValueChanged<NepaliDateTime> onDateSelected;
  final ValueChanged<NepaliDateTime> onMonthChanged;
  final ValueChanged onRangeSelected;
  final bool isExpandable;
  final DayBuilder dayBuilder;
  final bool hideArrows;
  final bool hideTodayIcon;
  final Map<String, List> events;
  final Color selectedColor;
  final Color todayColor;
  final Color eventColor;
  final Color eventDoneColor;
  final NepaliDateTime initialDate;
  final bool isExpanded;
  final List<String> weekDays;

  final bool startOnMonday;
  final bool hideBottomBar;
  final TextStyle dayOfWeekStyle;
  final TextStyle bottomBarTextStyle;
  final Color bottomBarArrowColor;
  final Color bottomBarColor;
  final String expandableDateFormat;

  Calendar({
    this.onMonthChanged,
    this.onDateSelected,
    this.onRangeSelected,
    this.hideBottomBar: false,
    this.isExpandable: false,
    this.events,
    this.dayBuilder,
    this.hideTodayIcon: false,
    this.hideArrows: false,
    this.selectedColor,
    this.todayColor,
    this.eventColor,
    this.eventDoneColor,
    this.initialDate,
    this.isExpanded = false,
    this.weekDays = const ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"],

    this.startOnMonday = false,
    this.dayOfWeekStyle,
    this.bottomBarTextStyle,
    this.bottomBarArrowColor,
    this.bottomBarColor,
    this.expandableDateFormat = "EEEE MMMM dd, yyyy",
  });

  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  // final calendarUtils = Utils();
  List<NepaliDateTime> selectedMonthsDays;
  Iterable<NepaliDateTime> selectedWeekDays;
  NepaliDateTime _selectedDate = NepaliDateTime.now();
  String currentMonth;
  bool isExpanded = false;
  String displayMonth = "";
  NepaliDateTime get selectedDate => _selectedDate;



  void initState() {
    super.initState();
    _selectedDate = widget?.initialDate ?? NepaliDateTime.now();
    isExpanded = widget?.isExpanded ?? false;
    selectedMonthsDays = _daysInMonth(_selectedDate);
    selectedWeekDays = Constant.daysInRange(
        _firstDayOfWeek(_selectedDate), _lastDayOfWeek(_selectedDate))
    ;
    setState(() {
      var monthFormat = NepaliDateFormat.yMMMM().format(_selectedDate);
      displayMonth =
      "${monthFormat[0].toUpperCase()}${monthFormat.substring(1)}";
    });
  }

  Widget get nameAndIconRow {
    var todayIcon;
    var leftArrow;
    var rightArrow;

    if (!widget.hideArrows) {
      leftArrow = IconButton(
        onPressed: isExpanded ? previousMonth : previousWeek,
        icon: Icon(Icons.chevron_left),
      );
      rightArrow = IconButton(
        onPressed: isExpanded ? nextMonth : nextWeek,
        icon: Icon(Icons.chevron_right),
      );
    } else {
      leftArrow = Container();
      rightArrow = Container();
    }

    if (!widget.hideTodayIcon) {
      todayIcon = InkWell(
        child: Text('Today'),
        onTap: resetToToday,
      );
    } else {
      todayIcon = Container();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        leftArrow ?? Container(),
        Column(
          children: <Widget>[
            todayIcon ?? Container(),
            Text(
              displayMonth,
              style: TextStyle(
                fontSize: 20.0,
              ),
            ),
          ],
        ),
        rightArrow ?? Container(),
      ],
    );
  }

  Widget get calendarGridView {
    return Container(
      child: SimpleGestureDetector(
        onSwipeUp: _onSwipeUp,
        onSwipeDown: _onSwipeDown,
        onSwipeLeft: _onSwipeLeft,
        onSwipeRight: _onSwipeRight,
        swipeConfig: SimpleSwipeConfig(
          verticalThreshold: 10.0,
          horizontalThreshold: 40.0,
          swipeDetectionMoment: SwipeDetectionMoment.onUpdate,
        ),
        child: Column(children: <Widget>[
          GridView.count(
            childAspectRatio: 1.5,
            primary: false,
            shrinkWrap: true,
            crossAxisCount: 7,
            padding: EdgeInsets.only(bottom: 0.0),
            children: calendarBuilder(),
          ),
        ]),
      ),
    );
  }

  List<Widget> calendarBuilder() {
    List<Widget> dayWidgets = [];
    List<NepaliDateTime> calendarDays =
    isExpanded ? selectedMonthsDays : selectedWeekDays;
    widget.weekDays.forEach(
          (day) {
        dayWidgets.add(
          CalendarTile(
            selectedColor: widget.selectedColor,
            todayColor: widget.todayColor,
            eventColor: widget.eventColor,
            eventDoneColor: widget.eventDoneColor,
            events: widget.events[day.toString()],
            isDayOfWeek: true,
            dayOfWeek: day,
            dayOfWeekStyle: widget.dayOfWeekStyle ??
                TextStyle(
                  color: widget.selectedColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                ),
          ),
        );
      },
    );

    bool monthStarted = false;
    bool monthEnded = false;

    calendarDays.forEach(
          (day) {
        if (day.hour > 0) {
          day = day;
          day = day.subtract(new Duration(hours: day.hour));
        }

        if (monthStarted && day.day == 01) {
          monthEnded = true;
        }

        if (Constant.isFirstDayOfMonth(day)) {
          monthStarted = true;
        }


        // print("Days : $day");
        if (this.widget.dayBuilder != null) {
          dayWidgets.add(
            CalendarTile(
              selectedColor: widget.selectedColor,
              todayColor: widget.todayColor,
              eventColor: widget.eventColor,
              eventDoneColor: widget.eventDoneColor,
              events: widget.events[day.toString()],
              child: this.widget.dayBuilder(context, day),
              date: day,
              onDateSelected: () => handleSelectedDateAndUserCallback(day),
            ),
          );
          // print("Days1 : ${widget.events[day]}");
        } else {
          dayWidgets.add(
            CalendarTile(
                selectedColor: widget.selectedColor,
                todayColor: widget.todayColor,
                eventColor: widget.eventColor,
                eventDoneColor: widget.eventDoneColor,
                events: widget.events[day.toString()],
                onDateSelected: () => handleSelectedDateAndUserCallback(day),
                date: day,
                dateStyles: configureDateStyle(monthStarted, monthEnded),
                isSelected: Constant.isSameDay(selectedDate, day),
                inMonth: day.month == selectedDate.month),
          );
          // print("Days2 : ${day.toDateTime()}");
          // print("Days3 : ${widget.events}");
          // print("Days4 : ${widget.events[day.toDateTime()]}");
        }
      },
    );

    return dayWidgets;
  }

  TextStyle configureDateStyle(monthStarted, monthEnded) {
    TextStyle dateStyles;
    final TextStyle body1Style = Theme.of(context).textTheme.body1;

    if (isExpanded) {
      final TextStyle body1StyleDisabled = body1Style.copyWith(
          color: Color.fromARGB(
            100,
            body1Style.color.red,
            body1Style.color.green,
            body1Style.color.blue,
          ));

      dateStyles =
      monthStarted && !monthEnded ? body1Style : body1StyleDisabled;
    } else {
      dateStyles = body1Style;
    }
    return dateStyles;
  }

  Widget get expansionButtonRow {
    if (widget.isExpandable) {
      return GestureDetector(
        onTap: toggleExpanded,
        child: Container(
          color: widget.bottomBarColor ?? Color.fromRGBO(200, 200, 200, 0.2),
          height: 40,
          margin: EdgeInsets.only(top: 8.0),
          padding: EdgeInsets.all(0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SizedBox(width: 40.0),
              // Text(
              //   DateFormat(widget.expandableDateFormat, widget.locale).format(_selectedDate),
              //   style: widget.bottomBarTextStyle ?? TextStyle(fontSize: 13),
              // ),
              IconButton(
                onPressed: toggleExpanded,
                iconSize: 25.0,
                padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                icon: isExpanded
                    ? Icon(
                  Icons.arrow_drop_up,
                  color: widget.bottomBarArrowColor ?? Colors.black,
                )
                    : Icon(
                  Icons.arrow_drop_down,
                  color: widget.bottomBarArrowColor ?? Colors.black,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          nameAndIconRow,
          ExpansionCrossFade(
            collapsed: calendarGridView,
            expanded: calendarGridView,
            isExpanded: isExpanded,
          ),
          expansionButtonRow
        ],
      ),
    );
  }

  void resetToToday() {
    _selectedDate = NepaliDateTime.now();
    var firstDayOfCurrentWeek = _firstDayOfWeek(_selectedDate);
    var lastDayOfCurrentWeek = _lastDayOfWeek(_selectedDate);

    setState(() {
      selectedWeekDays =
          Constant.daysInRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek)
              .toList();
      selectedMonthsDays = _daysInMonth(_selectedDate);
      var monthFormat = NepaliDateFormat.yMMMM().format(_selectedDate);
      displayMonth =
      "${monthFormat[0].toUpperCase()}${monthFormat.substring(1)}";
    });

    _launchDateSelectionCallback(_selectedDate);
  }



  void nextMonth() {
    setState(() {
      _selectedDate = Constant.nextMonth(_selectedDate);
      var firstDateOfNewMonth = Constant.firstDayOfMonth(_selectedDate);
      var lastDateOfNewMonth = Constant.lastDayOfMonth(_selectedDate);
      updateSelectedRange(firstDateOfNewMonth, lastDateOfNewMonth);
      selectedMonthsDays = _daysInMonth(_selectedDate);
      var monthFormat =
      NepaliDateFormat.yMMMM().format(_selectedDate);
      displayMonth =
      "${monthFormat[0].toUpperCase()}${monthFormat.substring(1)}";
    });
    _launchDateSelectionCallback(_selectedDate);
  }

  void previousMonth() {
    setState(() {
      _selectedDate = Constant.previousMonth(_selectedDate);
      var firstDateOfNewMonth = Constant.firstDayOfMonth(_selectedDate);
      var lastDateOfNewMonth = Constant.lastDayOfMonth(_selectedDate);
      updateSelectedRange(firstDateOfNewMonth, lastDateOfNewMonth);
      selectedMonthsDays = _daysInMonth(_selectedDate);
      var monthFormat =
      NepaliDateFormat.yMMMM().format(_selectedDate);
      displayMonth =
      "${monthFormat[0].toUpperCase()}${monthFormat.substring(1)}";
    });
    _launchDateSelectionCallback(_selectedDate);
  }

  void nextWeek() {
    setState(() {
      _selectedDate = Constant.nextWeek(_selectedDate);
      var firstDayOfCurrentWeek = _firstDayOfWeek(_selectedDate);
      var lastDayOfCurrentWeek = _lastDayOfWeek(_selectedDate);
      updateSelectedRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek);
      selectedWeekDays =
          Constant.daysInRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek)
              .toList();
      var monthFormat =
      NepaliDateFormat.yMMMM().format(_selectedDate);
      displayMonth =
      "${monthFormat[0].toUpperCase()}${monthFormat.substring(1)}";
    });
    _launchDateSelectionCallback(_selectedDate);
  }

  void previousWeek() {
    setState(() {
      _selectedDate = Constant.previousWeek(_selectedDate);
      var firstDayOfCurrentWeek = _firstDayOfWeek(_selectedDate);
      var lastDayOfCurrentWeek = _lastDayOfWeek(_selectedDate);
      updateSelectedRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek);
      selectedWeekDays =
          Constant.daysInRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek)
              .toList();
      var monthFormat =
      NepaliDateFormat.yMMMM().format(_selectedDate);
      displayMonth =
      "${monthFormat[0].toUpperCase()}${monthFormat.substring(1)}";
    });
    _launchDateSelectionCallback(_selectedDate);
  }

  void updateSelectedRange(NepaliDateTime start, NepaliDateTime end) {
    Range _rangeSelected = Range(start, end);
    if (widget.onRangeSelected != null) {
      widget.onRangeSelected(_rangeSelected);
    }
  }

  void _onSwipeUp() {
    if (isExpanded) toggleExpanded();
  }

  void _onSwipeDown() {
    if (!isExpanded) toggleExpanded();
  }

  void _onSwipeRight() {
    if (isExpanded) {
      previousMonth();
    } else {
      previousWeek();
    }
  }

  void _onSwipeLeft() {
    if (isExpanded) {
      nextMonth();
    } else {
      nextWeek();
    }
  }

  void toggleExpanded() {
    if (widget.isExpandable) {
      setState(() => isExpanded = !isExpanded);
    }
  }

  void handleSelectedDateAndUserCallback(NepaliDateTime day) {
    var firstDayOfCurrentWeek = _firstDayOfWeek(day);
    var lastDayOfCurrentWeek = _lastDayOfWeek(day);
    if (_selectedDate.month > day.month) {
      previousMonth();
    }
    if (_selectedDate.month < day.month) {
      nextMonth();
    }
    setState(() {
      _selectedDate = day;
      selectedWeekDays =
          Constant.daysInRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek)
              .toList();
      selectedMonthsDays = _daysInMonth(day);
    });
    _launchDateSelectionCallback(day);
  }

  void _launchDateSelectionCallback(NepaliDateTime day) {
    if (widget.onDateSelected != null) {
      widget.onDateSelected(day);

    }
    if (widget.onMonthChanged != null) {
      widget.onMonthChanged(day);
    }
  }

  _firstDayOfWeek(NepaliDateTime date) {
    var day = new NepaliDateTime(
        _selectedDate.year, _selectedDate.month, _selectedDate.day, 12);
    return day.subtract(
        new Duration(days: day.weekday - (widget.startOnMonday ? 1 : 0)));
  }

  _lastDayOfWeek(NepaliDateTime date) {
    return _firstDayOfWeek(date).add(new Duration(days: 7));
  }

  List<NepaliDateTime> _daysInMonth(NepaliDateTime month) {
    var first = Constant.firstDayOfMonth(month);
    var daysBefore = first.weekday;
    var firstToDisplay = first.subtract(new Duration(days: daysBefore - 1));
    var last = Constant.lastDayOfMonth(month);

    var daysAfter = 7 - last.weekday;

    // If the last day is sunday (7) the entire week must be rendered
    if (daysAfter == 0) {
      daysAfter = 7;
    }

    var lastToDisplay = last.add(new Duration(days: daysAfter));
    return Constant.daysInRange(firstToDisplay, lastToDisplay).toList();
  }


}

class ExpansionCrossFade extends StatelessWidget {
  final Widget collapsed;
  final Widget expanded;
  final bool isExpanded;

  ExpansionCrossFade({this.collapsed, this.expanded, this.isExpanded});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 1,
      child: AnimatedCrossFade(
        firstChild: collapsed,
        secondChild: expanded,
        firstCurve: const Interval(0.0, 1.0, curve: Curves.fastOutSlowIn),
        secondCurve: const Interval(0.0, 1.0, curve: Curves.fastOutSlowIn),
        sizeCurve: Curves.decelerate,
        crossFadeState:
        isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        duration: const Duration(milliseconds: 300),
      ),
    );
  }


}

