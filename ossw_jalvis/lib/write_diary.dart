import 'package:flutter/material.dart';
import 'sum_result.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class WriteDiaryPage extends StatefulWidget {
  final String date;

  const WriteDiaryPage({super.key, required this.date});

  @override
  State<WriteDiaryPage> createState() => _WriteDiaryPageState();
}

class _WriteDiaryPageState extends State<WriteDiaryPage> {
  final List<String> _questions = [];
  final List<String> _answers = [];
  bool _isListening = false;
  String _conversation = "";


  late stt.SpeechToText _speech;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initializeConversation();
  }

  /// 초기에 첫 질문을 받아오는 함수
  void _initializeConversation() async {
    final response = await http.post(
      Uri.parse('https://97f6-211-212-3-131.ngrok-free.app/question'), // apk 빌드 전에 ip 수정
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
  }

  /// 음성 인식을 시작하고 질문-답변 흐름을 처리하는 함수
  Future<void> _startListening() async {
    bool available = await _speech.initialize();
    if (!available) {
      print("음성 인식 초기화 실패");
      return;
    }

    setState(() {
      _isListening = true;
    });


    await _speech.listen(onResult: (result) async {
      if (result.finalResult) {
        String userAnswer = result.recognizedWords;
        setState(() {
          _answers.add(userAnswer);
          _conversation += "사용자: $userAnswer\n";
        });


        _speech.stop();
        await _fetchNextQuestion();
      }
    });
  }


  /// 서버에 현재까지 대화를 보내고 다음 질문을 받아오는 함수
  Future<void> _fetchNextQuestion() async {
    final qResponse = await http.post(
      Uri.parse('https://97f6-211-212-3-131.ngrok-free.app/question'), // apk 빌드 전에 ip 수정
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
        await FirebaseFirestore.instance
            .collection('diaries')
            .doc(widget.date)
            .set({
          'summary': '',
          'answers': _answers,
        });

        await Future.delayed(const Duration(seconds: 2));
        _navigateToSummary();

      }
    } else {
      print('질문 생성 실패');
      setState(() {
        _isListening = false;
      });
    }
  }

  void _resetDiary() {
    setState(() {
      _questions.clear();
      _answers.clear();
      _conversation = "";
      _isListening = false;
    });
  }

  void _navigateToSummary() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SumResultPage(
          date: widget.date,
          answers: _answers,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD8E6ED),
      appBar: AppBar(
        title: Text(
          '오늘 하루 기록하기 (${widget.date})',
          style: GoogleFonts.nanumMyeongjo(
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF7F2EC),
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            // ✅ 질문/답변 리스트
            Expanded(
              child: ListView.builder(
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.question_answer),
                    title: Text(
                      _questions[index],
                      style: GoogleFonts.nanumMyeongjo(),
                    ),
                    subtitle: Text(
                      index < _answers.length
                          ? _answers[index]
                          : 'JALVIS가 답변을 기다리고 있어요...',
                      style: GoogleFonts.nanumMyeongjo(),
                    ),
                  );
                },
              ),
            ),

            // ✅ 좌우 이미지 대칭 (버튼 위로 내림)
            Padding(
              padding: const EdgeInsets.only(top: 40.0, bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset('assets/puang.png', height: 360),
                  Image.asset('assets/jalvisSmall.png', height: 360),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ✅ 버튼 영역
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                    label: Text(
                      _isListening ? '답변 중...' : '이야기 시작/끝',
                      style: GoogleFonts.nanumMyeongjo(),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
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
                  label: Text(
                    '다시 들려주기',
                    style: GoogleFonts.nanumMyeongjo(),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
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

            // ✅ 버튼과 화면 하단 사이 여유
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
