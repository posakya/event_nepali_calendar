
import 'package:flutter/material.dart';
import 'package:event_nepali_calendar/event_nepali_calendar.dart';
import 'package:nepali_utils/nepali_utils.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Clean Calendar Demo',
      home: CalendarScreen(),
    );
  }
}

class CalendarScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CalendarScreenState();
  }
}

class _CalendarScreenState extends State<CalendarScreen> {

  void _handleNewDate(date) {
    setState(() {
      _selectedDay = date;
      _selectedEvents = _events1[_selectedDay.toString()] ?? [];
      print("EventsDateNepali : $_selectedDay");
      print("EventsDate : ${NepaliDateTime.parse('2078-01-05 00:00:00.000')}");
      print("Events : ${_events1[NepaliDateTime.parse('2078-01-05 00:00:00.000')]}");
      print("EventsLength : ${_events1.length}");
    });

  }

  List _selectedEvents;
  NepaliDateTime _selectedDay;

  final Map<String, List> _events1 = {
    "2078-01-09 00:00:00.000": [
      {'name': 'Event A', 'isDone': true},
    ],
    "2078-01-19 00:00:00.000": [
      {'name': 'Event A', 'isDone': true},
      {'name': 'Event B', 'isDone': true},
    ],
    "2078-01-29 00:00:00.000": [
      {'name': 'Event A', 'isDone': true},
      {'name': 'Event B', 'isDone': true},
    ],
    "2078-01-25 00:00:00.000": [
      {'name': 'Event A', 'isDone': true},
      {'name': 'Event B', 'isDone': true},
      {'name': 'Event C', 'isDone': false},
    ],
    "2078-02-09 00:00:00.000": [
      {'name': 'Event A', 'isDone': true},
      {'name': 'Event B', 'isDone': true},
      {'name': 'Event C', 'isDone': false},
    ],
  };

  @override
  void initState() {
    super.initState();
    _selectedEvents = _events1[_selectedDay] ?? [];
  }

  @override
  Widget build(BuildContext context) {
//final NepaliDateTime first = NepaliDateTime(2075, 5);
//     final NepaliDateTime last = NepaliDateTime(2079, 3);
    return Scaffold(

      appBar: AppBar(
        title: Text("Nepali Calendar"),
      ),
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Container(
              child: Calendar(
                startOnMonday: true,
                weekDays: ["Sun","Mon", "Tue", "Wed", "Thu", "Fri", "Sat"],
                events: _events1,
                onRangeSelected: (range) =>
                    print("Range is ${range.from}, ${range.to}"),
                onDateSelected: (date) => _handleNewDate(date),
                isExpandable: false,
                isExpanded: true,
                initialDate: NepaliDateTime.now(),
                eventDoneColor: Colors.green,
                selectedColor: Colors.pink,
                todayColor: Colors.yellow,
                eventColor: Colors.grey,
                dayOfWeekStyle: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w800,
                    fontSize: 11),
              ),
            ),
            _buildEventList()
          ],
        ),
      ),
    );
  }

  Widget _buildEventList() {
    return Expanded(
      child: ListView.builder(
        itemBuilder: (BuildContext context, int index) => Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(width: 1.5, color: Colors.black12),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 4.0),
          child: ListTile(
            title: Text(_selectedEvents[index]['name'].toString()),
            onTap: () {},
          ),
        ),
        itemCount: _selectedEvents.length,
      ),
    );
  }
}
