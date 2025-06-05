import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 선택한 날짜 출력용
import 'main.dart'; // MainPage로 돌아가기 위해 import
import 'package:cloud_firestore/cloud_firestore.dart';

class ChooseDatePage extends StatefulWidget {
  final String summary; // 현재 일기의 요약본
  final List<DateTime> existingDiaryDates; // 이미 작성된 날짜 리스트

  const ChooseDatePage({
    super.key,
    required this.summary,
    required this.existingDiaryDates,
  });

  @override
  State<ChooseDatePage> createState() => _ChooseDatePageState();
}

class _ChooseDatePageState extends State<ChooseDatePage> {
  DateTime? _selectedDate;

  /// 날짜 선택 함수
  Future<void> _pickDate() async {
    try {
      final picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
        locale: const Locale('ko', 'KR'), // 로케일 지정
      );

      if (picked != null) {
        setState(() {
          _selectedDate = picked;
        });

        // 이미 일기가 존재하는 날짜인지 확인
        bool alreadyExists = widget.existingDiaryDates.any((date) =>
        date.year == picked.year &&
            date.month == picked.month &&
            date.day == picked.day);

        if (alreadyExists) {
          // 이미 일기가 있는 경우 알림
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('알림'),
              content: const Text('이미 해당 날짜에 작성된 일기가 존재합니다.\n다른 날짜를 선택해주세요.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('확인'),
                ),
              ],
            ),
          );
        } else {
          // 일기가 없는 경우 MainPage로 돌아가기
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const MainPage(),
            ),
                (route) => false,
          );

          // TODO: 선택한 날짜와 summary를 Firestore 등에 저장
          // 날짜 선택 후 일기 저장 코드 추가
          await FirebaseFirestore.instance
              .collection('diaries')
              .doc(DateFormat('yyyy-MM-dd').format(picked))
              .set({
            'content': widget.summary,
          });
          //print('✅ 선택된 날짜: ${DateFormat('yyyy-MM-dd').format(picked)}');
          //print('✅ 일기 내용: ${widget.summary}');
        }
      }
    } catch (e) {
      // 초기화 문제 등 예외 처리
      debugPrint('날짜 선택 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('날짜 선택'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                '일기를 작성할 날짜를 선택하세요.',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: const Text('날짜 선택'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                onPressed: _pickDate,
              ),
              const SizedBox(height: 20),
              if (_selectedDate != null)
                Text(
                  '선택한 날짜: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.home),
                label: const Text('메인으로 돌아가기'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
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
        ),
      ),
    );
  }
}
