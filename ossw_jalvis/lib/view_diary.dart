import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewDiaryPage extends StatefulWidget {
  final DateTime selectedDate;

  const ViewDiaryPage({super.key, required this.selectedDate});

  @override
  State<ViewDiaryPage> createState() => _ViewDiaryPageState();
}

class _ViewDiaryPageState extends State<ViewDiaryPage> {
  String _diaryContent = '일기를 불러오는 중입니다...';  // 초기 로딩 상태
  bool _isLoading = true;  // 로딩 표시

  @override
  void initState() {
    super.initState();
    _loadDiary();  // 페이지가 열리면 일기 로드 시도
  }

  /// 실제로는 DB(Firebase Firestore)에서 데이터를 불러오는 함수
  /// 현재 연결되지 않은 상태에서도 앱이 동작하도록 예외처리와 임시 데이터 포함
  void _loadDiary() async {
    try {
      // Firestore 연결
      final firestore = FirebaseFirestore.instance;

      // 선택한 날짜를 yyyy-MM-dd 형식으로 변환 (문서 ID로 사용)
      final formattedDate = DateFormat('yyyy-MM-dd').format(widget.selectedDate);

      // Firestore에서 데이터 요청
      final snapshot = await firestore
          .collection('diaries') // diaries라는 컬렉션에 데이터가 있다고 가정
          .doc(formattedDate)
          .get();

      if (snapshot.exists) {
        // 문서가 존재하면 일기 내용 불러오기
        setState(() {
          _diaryContent = snapshot.data()?['content'] ?? '내용이 없습니다.';
          _isLoading = false;
        });
      } else {
        // 문서가 없는 경우
        setState(() {
          _diaryContent = '해당 날짜에 작성된 일기가 없습니다.';
          _isLoading = false;
        });
      }
    } catch (e) {
      // 🔥 Firestore가 연결되지 않았거나 예외가 발생한 경우
      setState(() {
        _diaryContent =
        '임시 데이터: Firestore 연결이 아직 설정되지 않았습니다.\n\n'
            '⚠️ 백엔드 팀이 서버 연동을 완료하면 실제 데이터를 불러올 수 있습니다.\n\n'
            '예시 내용: 오늘 하루도 수고 많으셨어요!';
        _isLoading = false;
      });

      // 개발용 로그 출력
      print('Firestore 연동 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate =
    DateFormat('yyyy년 MM월 dd일').format(widget.selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('일기 보기'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📌 선택한 날짜 표시
            Text(
              formattedDate,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // 📌 일기 내용 박스
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.5),
                    ),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(
                    _diaryContent,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
