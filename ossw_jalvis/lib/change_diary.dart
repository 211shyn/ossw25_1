import 'package:flutter/material.dart';

class ChangeDiaryPage extends StatefulWidget {
  final String initialSummary;

  const ChangeDiaryPage({super.key, required this.initialSummary});

  @override
  State<ChangeDiaryPage> createState() => _ChangeDiaryPageState();
}

class _ChangeDiaryPageState extends State<ChangeDiaryPage> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    // 초기 요약 텍스트를 TextEditingController에 세팅
    _controller = TextEditingController(text: widget.initialSummary);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 사용자가 수정한 텍스트를 반환하는 함수
  /// 실제 저장은 부모 페이지에서 처리하도록 설계
  void _saveEditedSummary() {
    Navigator.pop(context, _controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('일기 수정하기'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // 📌 수정할 수 있는 TextField
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: null, // 여러 줄 입력 가능
                decoration: InputDecoration(
                  labelText: '수정된 일기 내용',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // 📌 저장 버튼
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('저장'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              onPressed: _saveEditedSummary,
            ),
          ],
        ),
      ),
    );
  }
}
