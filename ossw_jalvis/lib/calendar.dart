import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'write_diary.dart';   // 일기 작성 화면
import 'view_diary.dart';   // 일기 보기 화면

class CalendarPage extends StatefulWidget {
  final List<DateTime> existingDiaryDates;  // 이미 일기가 있는 날짜 리스트

  const CalendarPage({super.key, required this.existingDiaryDates});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();   // 현재 포커스된 날짜
  DateTime? _selectedDay;                  // 사용자가 선택한 날짜

  /// 🔥 TODO: Firestore 연동
  /// 현재는 existingDiaryDates를 빈 리스트로 처리 중.
  /// 나중에 Firestore에서 작성된 일기 날짜를 불러와서 이 리스트에 넣어주세요.

  /// 이미 일기가 존재하는 날짜인지 확인
  bool _isDiaryExist(DateTime day) {
    return widget.existingDiaryDates.any((date) =>
    date.year == day.year &&
        date.month == day.month &&
        date.day == day.day);
  }

  /// 날짜 클릭 시 동작
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });

    bool exists = _isDiaryExist(selectedDay);

    if (exists) {
      // 이미 일기가 있는 날짜 → ViewDiaryPage로 이동
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ViewDiaryPage(selectedDate: selectedDay),
        ),
      );
    } else {
      // 일기가 없는 날짜 → WriteDiaryPage로 이동
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const WriteDiaryPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('일기 달력'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: TableCalendar(
          locale: 'ko_KR',
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2100, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: _onDaySelected,
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Colors.blue.shade100,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.blueAccent,
              shape: BoxShape.circle,
            ),
            markerDecoration: BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.rectangle,
            ),
          ),
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, focusedDay) {
              final exists = _isDiaryExist(day);
              return Container(
                decoration: exists
                    ? BoxDecoration(
                  border: Border.all(color: Colors.grey.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(6),
                )
                    : null,
                alignment: Alignment.center,
                child: Text(
                  '${day.day}',
                  style: TextStyle(
                    color: exists ? Colors.black87 : Colors.black,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
