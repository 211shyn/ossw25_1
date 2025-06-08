import 'package:flutter/material.dart';
import 'sum_result.dart';  // sum_result.dart로 이동하기 위해 import
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WriteDiaryPage extends StatefulWidget {
  final String date;  // 🔥 추가: 날짜 필드

  const WriteDiaryPage({super.key, required this.date});

  @override
  State<WriteDiaryPage> createState() => _WriteDiaryPageState();
}

class _WriteDiaryPageState extends State<WriteDiaryPage> {
  // 질문 리스트: 사용자가 하나씩 음성으로 대답해야 하는 질문들
  final List<String> _questions = []; // 질문 리스트(서버에서 받아옴)
  final List<String> _answers = [];
  bool _isListening = false;
  String _conversation = "";

  /// STT(음성인식) 시작 함수
  void _startListening() async {
    setState(() {
      _isListening = true;
    });

    // TODO: 여기에 Python STT 서버 호출 코드 삽입
    try {
      final response = await http.get(Uri.parse('http://localhost:8010/stt'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final sttText = data['text'];

        setState(() {
          _answers.add(sttText);
          _conversation += "사용자: $sttText\n";
        });

        // 다음 질문 받아오기
        final qResponse = await http.post(
          Uri.parse('http://localhost:8010/question'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'conversation': _conversation}),
        );

        if (qResponse.statusCode == 200) {
          final qData = json.decode(qResponse.body);
          final nextQ = qData['next_step'];

          setState(() {
            _questions.add(nextQ);
            _conversation += "비서: $nextQ\n";
            _isListening = false;
          });
          if (nextQ.contains("마무리")) {
            // 파이어스토어 저장
            await FirebaseFirestore.instance.collection('diaries').doc(
                widget.date).set({
              'summary': '',
              'answers': _answers,
            });

            // ✅ 2초 기다린 후 요약 페이지로 이동
            await Future.delayed(const Duration(seconds: 2));
            _navigateToSummary();
          }
        } else {
          throw Exception('질문 생성 실패');
        }
      } else {
        throw Exception('STT 실패');
      }
    } catch (e) {
      print("STT API 호출 실패: $e");
      setState(() {
        _isListening = false;
      });
    }
  }

  /// 답변 초기화 함수
  void _resetDiary() {
    setState(() {
      _questions.clear();
      _answers.clear();
      _conversation = "";
      _isListening = false;
    });
  }

  /// SumResultPage로 이동
  void _navigateToSummary() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SumResultPage(
          date: widget.date,      // 🔥 날짜도 전달
          answers: _answers,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // 초기 질문 하나 받아오기
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final response = await http.post(
        Uri.parse('http://localhost:8010/question'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'conversation': ""}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final question = data['next_step'];

        setState(() {
          _questions.add(question);
          _conversation += "비서: $question\n";
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('오늘 하루 기록하기 (${widget.date})'),  // 🔥 날짜 표시
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.question_answer),
                    title: Text(_questions[index]),
                    subtitle: index < _answers.length
                        ? Text(_answers[index])
                        : const Text('답변 대기 중...'),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                    label: Text(_isListening ? '답변 중...' : '답변 시작/끝'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    onPressed: _isListening ? null : _startListening,
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('다시하기'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(120, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  onPressed: _resetDiary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
