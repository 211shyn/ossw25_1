import 'package:flutter/material.dart';
import 'sum_result.dart';  // sum_result.dart로 이동하기 위해 import
import 'package:cloud_firestore/cloud_firestore.dart';

class WriteDiaryPage extends StatefulWidget {
  final String date;  // 🔥 추가: 날짜 필드

  const WriteDiaryPage({super.key, required this.date});

  @override
  State<WriteDiaryPage> createState() => _WriteDiaryPageState();
}

class _WriteDiaryPageState extends State<WriteDiaryPage> {
  // 질문 리스트: 사용자가 하나씩 음성으로 대답해야 하는 질문들
  final List<String> _questions = [
    "오늘 하루엔 무슨 일이 있었나요?",
    "당신은 어떤 기분으로 오늘을 보냈나요?",
    "오늘을 마무리하며, 내일을 시작하는 당신은 어떤 모습이고 싶나요?",
  ];

  int _currentQuestionIndex = 0;
  final List<String> _answers = [];
  bool _isListening = false;

  /// STT(음성인식) 시작 함수
  void _startListening() {
    setState(() {
      _isListening = true;
    });

    // TODO: 여기에 Python STT 서버 호출 코드 삽입
    Future.delayed(const Duration(seconds: 2), () async {
      setState(() {
        _answers.add("임시 답변 예시 (여기에 STT 결과가 들어감)");
        _isListening = false;

        if (_currentQuestionIndex < _questions.length - 1) {
          _currentQuestionIndex++;
        } else {
          _navigateToSummary();
        }
      });
      await FirebaseFirestore.instance.collection('diary_temp').add({
        'date': widget.date,  // 🔥 Firestore에 날짜도 저장
        'question': _questions[_currentQuestionIndex],
        'answer': _answers[_currentQuestionIndex],
        'timestamp': Timestamp.now(),
      });
    });
  }

  /// 답변 초기화 함수
  void _resetDiary() {
    setState(() {
      _currentQuestionIndex = 0;
      _answers.clear();
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
                itemCount: _currentQuestionIndex + 1,
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
