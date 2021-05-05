
import 'package:nepali_utils/nepali_utils.dart';

class Constant{
  static NepaliDateTime nextMonth(NepaliDateTime m) {
    var year = m.year;
    var month = m.month;

    if (month == 12) {
      year++;
      month = 1;
    } else {
      month++;
    }
    return new NepaliDateTime(year, month);
  }

  static NepaliDateTime previousMonth(NepaliDateTime m) {
    var year = m.year;
    var month = m.month;
    if (month == 1) {
      year--;
      month = 12;
    } else {
      month--;
    }
    return new NepaliDateTime(year, month);
  }

  static NepaliDateTime previousWeek(NepaliDateTime w) {
    return w.subtract(new Duration(days: 7));
  }

  static NepaliDateTime nextWeek(NepaliDateTime w) {
    return w.add(new Duration(days: 7));
  }

  static bool isSameDay(NepaliDateTime a, NepaliDateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }


  static bool isFirstDayOfMonth(NepaliDateTime day) {
    return isSameDay(firstDayOfMonth(day), day);
  }

  static bool isLastDayOfMonth(NepaliDateTime day) {
    return isSameDay(lastDayOfMonth(day), day);
  }

  static NepaliDateTime lastDayOfMonth(NepaliDateTime month) {
    var beginningNextMonth = (month.month < 12)
        ? new NepaliDateTime(month.year, month.month + 1, 1)
        : new NepaliDateTime(month.year + 1, 1, 1);
    return beginningNextMonth.subtract(new Duration(days: 1));
  }

  static NepaliDateTime firstDayOfMonth(NepaliDateTime month) {
    return new NepaliDateTime(month.year, month.month);
  }


  static daysInRange(NepaliDateTime firstToDisplay, NepaliDateTime lastToDisplay) {
    List<NepaliDateTime> days = [];
    for (int i = 0; i <= lastToDisplay.difference(firstToDisplay).inDays; i++) {
      days.add(firstToDisplay.add(Duration(days: i)));
    }
    return days;
  }
}