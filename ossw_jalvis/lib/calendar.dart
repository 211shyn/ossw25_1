import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'write_diary.dart';
import 'sum_result.dart';
import 'main.dart';
import 'package:google_fonts/google_fonts.dart';

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

  bool _isDiaryExist(DateTime day) {
    return _diaryDates.any((date) =>
    date.year == day.year &&
        date.month == day.month &&
        date.day == day.day);
  }

  String _formatDate(DateTime day) {
    return "${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });

    final exists = _isDiaryExist(selectedDay);
    final formattedDate = _formatDate(selectedDay);

    if (exists) {
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
      backgroundColor: const Color(0xFFD8E6ED),
      appBar: AppBar(
        title: Text(
          '당신의 일기 서랍장',
          style: GoogleFonts.nanumMyeongjo(
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
        backgroundColor: const Color(0xFFF7F2EC),
        foregroundColor: Colors.black,
        centerTitle: true,
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
      body: Column(
        children: [
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
                      color: exists ? const Color(0xFFF7F2EC) : Colors.transparent,
                      border: exists
                          ? Border.all(color: Colors.grey.withOpacity(0.4))
                          : null,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${day.day}',
                      style: GoogleFonts.nanumMyeongjo(
                        color: exists ? Colors.black87 : Colors.black,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // ✅ 달력 아래 설명 문구
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 24.0, top: 16.0),
              child: Text(
                '이미 일기가 존재하는 날은 "베이지색"으로 보이고,'
                    '아닌 날은 "하늘색"으로 보여요.\n'
                    '하늘색 날짜를 누르면 밀린 일기를,'
                    '베이지색 날짜를 누르면 썼던 일기를 조회할 수 있답니다!',
                style: GoogleFonts.nanumMyeongjo(fontSize: 14),
                textAlign: TextAlign.right,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
