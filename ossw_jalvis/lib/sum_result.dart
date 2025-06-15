import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'change_diary.dart';  // 수정 화면으로 이동
import 'choose_date.dart';  // 날짜 선택 화면으로 이동

class SumResultPage extends StatefulWidget {
  final List<String> answers;

  const SumResultPage({super.key, required this.answers});

  @override
  State<SumResultPage> createState() => _SumResultPageState();
}

class _SumResultPageState extends State<SumResultPage> {
  String _summary = '요약 중...';  // 초기 요약 텍스트
  bool _isLoading = true;         // 로딩 상태 표시

  @override
  void initState() {
    super.initState();
    _summarizeAnswers();  // 페이지가 열리면 요약 호출
  }

  /// 답변을 합쳐서 백엔드 요약 API로 전송하는 함수
  /// 현재는 http 연결이 준비되지 않아 임시 응답(2초 후)으로 대체
  /// 백엔드 팀은 아래 TODO 부분에 Python Flask/FastAPI 서버와 연동해 주세요.
  Future<void> _summarizeAnswers() async {
    final text = widget.answers.join(' ');
    // TODO: 실제 서버 주소로 변경 후 백엔드와 연동
    // ex) final uri = Uri.parse('http://서버주소:포트/summarize');
    final uri = Uri.parse('http://localhost:5000/summarize'); // 예시

    try {
      // 실제 API 호출 코드
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'text': text}),
      );

      if (response.statusCode == 200) {
        // 정상 응답 처리
        final decoded = json.decode(response.body);
        setState(() {
          _summary = decoded['summary'];
          _isLoading = false;
        });
      } else {
        // 오류 응답 처리
        setState(() {
          _summary = '요약 실패 (코드 ${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      // 현재는 백엔드 서버가 연결되지 않은 상태라 예외가 발생할 수 있음
      // 백엔드 팀이 연결되기 전에는 아래 임시 응답을 사용하여 테스트 가능
      setState(() {
        _summary = '임시 요약 예시: 여기에 GPT 요약 결과가 들어갑니다.\n\n'
            '⚠️ 현재 서버 연결이 설정되지 않았습니다. 백엔드 팀이 서버와의 연결을 구현해 주세요.';
        _isLoading = false;
      });

      // 실제 오류를 로그로 출력 (개발용)
      print('요약 API 호출 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('요약 결과'),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // 📌 요약 결과 박스 (밑줄 스타일 Container)
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
                    decoration: TextDecoration.underline, // 밑줄 효과
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
                      // ✨ "저장" 버튼 클릭 시 choose_date.dart로 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChooseDatePage(
                            summary: _summary,
                            existingDiaryDates: [], // 임시 리스트: 나중에 calendar.dart에서 데이터 받아서 채워넣기
                          ),
                        ),
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
