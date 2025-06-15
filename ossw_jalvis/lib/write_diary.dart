import 'package:flutter/material.dart';
import 'sum_result.dart';  // sum_result.dart로 이동하기 위해 import

class WriteDiaryPage extends StatefulWidget {
  const WriteDiaryPage({super.key});

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

  int _currentQuestionIndex = 0;      // 현재 질문 인덱스
  final List<String> _answers = [];   // 사용자의 답변을 누적 저장
  bool _isListening = false;          // 현재 음성인식 중 여부 표시

  /// STT(음성인식) 시작 함수
  /// 백엔드팀이 이 함수의 TODO 부분에 Python STT 서버와 통신하여
  /// 음성을 텍스트로 변환하는 코드를 추가하면 됨
  void _startListening() {
    setState(() {
      _isListening = true;
    });

    // TODO: 여기에 Python STT 서버 호출 코드 삽입
    // 1. Flutter에서 백엔드로 음성 데이터 전송
    // 2. 백엔드에서 음성 -> 텍스트 변환
    // 3. 변환된 텍스트를 Flutter로 응답(JSON)으로 전달
    //
    // 현재는 테스트용 코드로 2초 뒤에 임시 답변 추가하는 부분
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _answers.add("임시 답변 예시 (여기에 STT 결과가 들어감)");
        _isListening = false;

        // 질문이 남아있으면 다음 질문으로 넘어가기
        if (_currentQuestionIndex < _questions.length - 1) {
          _currentQuestionIndex++;
        } else {
          // 모든 질문에 답변이 끝나면 요약 페이지로 이동
          _navigateToSummary();
        }
      });
    });
  }

  /// 답변 초기화 함수: 다시하기 버튼에 연결
  void _resetDiary() {
    setState(() {
      _currentQuestionIndex = 0;
      _answers.clear();
      _isListening = false;
    });
  }

  /// SumResultPage로 이동
  /// answers 리스트를 sum_result.dart로 전달하여 요약 요청
  void _navigateToSummary() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SumResultPage(answers: _answers),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('오늘 하루 기록하기'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // 질문과 답변 리스트 출력
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
                // 답변 시작/끝 버튼
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
                    // 버튼 클릭 시 _startListening() 호출
                    // 이 함수 내부에서 STT 서버 연동 필요
                    onPressed: _isListening ? null : _startListening,
                  ),
                ),
                const SizedBox(width: 10),
                // 다시하기 버튼
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
