import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'change_diary.dart';
import 'calendar.dart';
import 'package:google_fonts/google_fonts.dart';

class SumResultPage extends StatefulWidget {
  final String date;
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
  String _summary = 'JALVIS가 당신의 이야기를 요약 중이에요...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('diaries')
          .doc(widget.date)
          .get();

      if (doc.exists) {
        final data = doc.data();
        final summary = data?['summary'];

        if (summary == null || summary.trim().isEmpty) {
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

  Future<void> _summarizeAnswers() async {
    final text = widget.answers.join(' ');
    final uri = Uri.parse('http://192.168.45.156:8010/summarize');

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
      backgroundColor: const Color(0xFFD8E6ED),
      appBar: AppBar(
        title: Text(
          '요약 결과 (${widget.date})',
          style: GoogleFonts.nanumMyeongjo(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF7F2EC),
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            // ✅ 상단 큰 이미지
            Padding(
              padding: const EdgeInsets.only(top: 60.0),
              child: Image.asset(
                'assets/jalvis.png',
                height: 500,
                fit: BoxFit.contain,
              ),
            ),

            const Spacer(),

            // ✅ 안내 문구 추가
            Text(
              'JALVIS가 당신의 하루를 이렇게 요약했어요. 이대로 저장할까요??',
              style: GoogleFonts.nanumMyeongjo(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // ✅ 요약 결과 박스
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                _summary,
                style: GoogleFonts.nanumMyeongjo(fontSize: 16, height: 1.6),
              ),
            ),

            const SizedBox(height: 28),

            // ✅ 버튼 두 개
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: Text(
                    '이야기 수정하기',
                    style: GoogleFonts.nanumMyeongjo(),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(160, 50),
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
                  label: Text(
                    '이대로 저장하기',
                    style: GoogleFonts.nanumMyeongjo(),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(160, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('diaries')
                        .doc(widget.date)
                        .set({'summary': _summary});

                    final selectedDate = DateTime.tryParse(widget.date);
                    String formattedDate = '';
                    if (selectedDate != null) {
                      formattedDate =
                      '${selectedDate.month}월 ${selectedDate.day}일';
                    }

                    await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('저장 완료'),
                        content: Text(
                            '$formattedDate의 일기를 소중하게 보관할게요!'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('확인'),
                          ),
                        ],
                      ),
                    );

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CalendarPage(
                          existingDiaryDates: [],
                        ),
                      ),
                          (route) => false,
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
