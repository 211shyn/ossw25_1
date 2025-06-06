import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';  // Firestore 추가
import 'change_diary.dart';
import 'calendar.dart';  // 🔥 수정: choose_date.dart 대신 calendar.dart로 이동

class SumResultPage extends StatefulWidget {
  final String date;          // 🔥 날짜 파라미터 추가
  final List<String> answers;

  const SumResultPage({
    super.key,
    required this.date,
    required this.answers,
  });

  @override
  State<SumResultPage> createState() => _SumResultPageState();
}

class _SumResultPageState extends State<SumResultPage> {
  String _summary = '요약 중...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  /// Firestore에서 해당 날짜의 일기 요약을 불러오고 없다면 새로 요약
  Future<void> _loadSummary() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('diaries')
          .doc(widget.date)
          .get();

      if (doc.exists) {
        // Firestore에서 요약 데이터를 가져옴
        final data = doc.data();
        final summary = data?['summary'];

        if (summary == null || summary.trim().isEmpty) {
          // 🔥 summary가 없거나 비어 있으면 요약 새로 생성
          await _summarizeAnswers();
        } else {
          setState(() {
            _summary = summary;
            _isLoading = false;
          });
        }
      } else {
        await _summarizeAnswers();
      }
    } catch (e) {
      setState(() {
        _summary = 'Firestore에서 데이터를 불러오는 데 실패했습니다.';
        _isLoading = false;
      });
    }
  }

  /// 답변을 합쳐서 요약
  Future<void> _summarizeAnswers() async {
    final text = widget.answers.join(' ');
    final uri = Uri.parse('http://127.0.0.1:8010/summarize'); // 예시

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'text': text}),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        setState(() {
          _summary = decoded['summary'];
          _isLoading = false;
        });
        // Firestore에 저장
        await FirebaseFirestore.instance
            .collection('diaries')
            .doc(widget.date)
            .set({'summary': decoded['summary']});
      } else {
        setState(() {
          _summary = '요약 실패 (코드 ${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _summary = '임시 요약 예시: 여기에 GPT 요약 결과가 들어갑니다.\n\n'
            '⚠️ 현재 서버 연결이 설정되지 않았습니다.';
        _isLoading = false;
      });
      print('요약 API 호출 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('요약 결과 (${widget.date})'),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // 📌 요약 결과 박스
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text(
                  _summary,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // 📌 수정 버튼과 저장 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('수정'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(120, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    onPressed: () async {
                      final editedSummary = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangeDiaryPage(
                            initialSummary: _summary,
                          ),
                        ),
                      );
                      if (editedSummary != null) {
                        setState(() {
                          _summary = editedSummary;
                        });
                      }
                    },
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('저장'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(120, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    onPressed: () {
                      // 저장 후 CalendarPage로 이동
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CalendarPage(
                              existingDiaryDates: [], // 기존 데이터 받아서 채우기
                            )),
                            (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
