import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'write_diary.dart';
import 'sum_result.dart';
import 'main.dart';  // 🔥 MainPage로 돌아가기 위해 import

class CalendarPage extends StatefulWidget {
  final List<DateTime> existingDiaryDates;

  const CalendarPage({super.key, required this.existingDiaryDates});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<DateTime> _diaryDates = [];

  @override
  void initState() {
    super.initState();
    _loadDiaryDates();
  }

  Future<void> _loadDiaryDates() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('diaries').get();
      final dates = snapshot.docs.map((doc) {
        final date = DateTime.tryParse(doc.id);
        return date;
      }).whereType<DateTime>().toList();

      setState(() {
        _diaryDates = dates;
      });
    } catch (e) {
      print('❌ Firestore 불러오기 실패: $e');
    }
  }

  /// 이미 일기가 존재하는 날짜인지 확인
  bool _isDiaryExist(DateTime day) {
    return _diaryDates.any((date) =>
    date.year == day.year &&
        date.month == day.month &&
        date.day == day.day);
  }

  /// 🔥 날짜를 yyyy-MM-dd 형태로 변환
  String _formatDate(DateTime day) {
    return "${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";
  }

  /// 날짜 클릭 시 동작
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });

    final exists = _isDiaryExist(selectedDay);
    final formattedDate = _formatDate(selectedDay);

    if (exists) {
      // 🔥 이미 일기가 있는 날짜 → SumResultPage로 이동
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SumResultPage(
            date: formattedDate,
            answers: const [],
          ),
        ),
      );
    } else {
      // 🔥 일기가 없는 날짜 → WriteDiaryPage로 이동
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WriteDiaryPage(date: formattedDate),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('일기 달력'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const MainPage()),
                    (route) => false,
              );
            },
          ),
        ],
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
            markerDecoration: const BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.rectangle,
            ),
          ),
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, focusedDay) {
              final exists = _isDiaryExist(day);
              return Container(
                decoration: BoxDecoration(
                  color: exists
                      ? Colors.grey.withOpacity(0.3) // 🔥 음영 처리
                      : Colors.transparent,
                  border: exists
                      ? Border.all(color: Colors.grey.withOpacity(0.5))
                      : null,
                  borderRadius: BorderRadius.circular(6),
                ),
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
