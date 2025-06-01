// Flutter의 기본 UI 라이브러리를 불러옴
import 'package:flutter/material.dart';

// 앱 실행 시 가장 먼저 호출되는 함수
void main() {
  runApp(const MyApp()); // MyApp 위젯을 앱 전체에 표시
}

// 앱의 가장 바깥쪽 구조를 담당하는 위젯 (StatelessWidget은 상태가 없음)
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key); // 생성자

  @override
  Widget build(BuildContext context) {
    return MaterialApp( // Material 디자인을 사용하는 앱
      home: DiaryPage(), // 앱이 시작되면 DiaryPage 화면을 보여줌
    );
  }
}

// 일기 작성 화면을 만들기 위한 StatefulWidget (입력값이 계속 바뀌기 때문)
class DiaryPage extends StatefulWidget {
  const DiaryPage({Key? key}) : super(key: key);

  @override
  State<DiaryPage> createState() => _DiaryPageState(); // 상태(State)를 생성
}

// 실제 화면 상태를 관리하는 클래스 (입력값, 버튼 누르기 등)
class _DiaryPageState extends State<DiaryPage> {
  // 사용자가 입력한 텍스트를 저장하고 불러올 수 있는 컨트롤러
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold( // 앱의 기본 화면 구조 (AppBar, Body, BottomBar 등을 포함)
      appBar: AppBar( // 상단 바
        title: const Text('일기 요약 인공지능 : J A L V I S'), // 앱 제목
        centerTitle: true, // 가운데 정렬
      ),
      body: Padding( // 본문 내용에 여백을 줌
        padding: const EdgeInsets.all(16.0), // 모든 방향에 16픽셀 여백
        child: Container( // 일기 입력창을 감싸는 상자
          decoration: BoxDecoration( // 상자 꾸미기
            border: Border.all(color: Colors.grey.shade400), // 연한 회색 테두리
            borderRadius: BorderRadius.circular(12), // 둥근 모서리
          ),
          child: TextField( // 실제로 사용자가 입력하는 부분
            controller: _controller, // 입력값을 관리하는 컨트롤러 연결
            maxLines: null, // 줄 수 제한 없음 → 여러 줄 입력 가능
            keyboardType: TextInputType.multiline, // 키보드를 여러 줄용으로 설정
            decoration: const InputDecoration(
              hintText: '당신의 오늘은 어땠나요? 편하게 들려주시면 제가 요약할게요.', // 힌트 텍스트
              border: InputBorder.none, // 입력창 테두리 없음 (외부 Container에서 이미 테두리 줬음)
              contentPadding: EdgeInsets.all(12), // 입력 내용의 안쪽 여백
            ),
            style: const TextStyle(
              fontSize: 16, // 글자 크기
              height: 1.5, // 줄 간격을 1.5배로 설정 → 줄글처럼 보이게
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar( // 하단에 고정되는 바 (하단 메뉴)
        shape: const CircularNotchedRectangle(), // 중앙 버튼 등을 위한 둥근 형태 설정
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0), // 안쪽 여백
          child: Row( // 하단 버튼들을 가로로 배치
            mainAxisAlignment: MainAxisAlignment.spaceAround, // 버튼 간격을 동일하게 배치
            children: [
              IconButton(
                icon: const Icon(Icons.edit), // 펜 모양 아이콘 (작성)
                onPressed: () {
                  // 작성 버튼 눌렀을 때 동작 (지금은 아무 동작 없음)
                },
              ),
              IconButton(
                icon: const Icon(Icons.save), // 저장 아이콘
                onPressed: () {
                  // 저장 버튼 눌렀을 때 동작 (지금은 입력된 내용을 콘솔에 출력)
                  print('저장된 내용: ${_controller.text}');
                },
              ),
              IconButton(
                icon: const Icon(Icons.list), // 목록 아이콘
                onPressed: () {
                  // 목록 버튼 눌렀을 때 동작 (지금은 아직 없음)
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
