import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    _controller = TextEditingController(text: widget.initialSummary);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _saveEditedSummary() {
    Navigator.pop(context, _controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD8E6ED),
      appBar: AppBar(
        title: Text(
          '일기 수정하기',
          style: GoogleFonts.nanumMyeongjo(fontWeight: FontWeight.w600),
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
            const SizedBox(height: 40),

            // ✅ 중앙 이미지
            Image.asset(
              'assets/puang.png',
              height: 500,
              fit: BoxFit.contain,
            ),

            const SizedBox(height: 28),

            // ✅ 수정 가능한 TextField
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: null,
                decoration: InputDecoration(
                  labelText: '지금까지의 일기장',
                  labelStyle: GoogleFonts.nanumMyeongjo(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  contentPadding: const EdgeInsets.all(16.0),
                ),
                style: GoogleFonts.nanumMyeongjo(fontSize: 16, height: 1.5),
              ),
            ),

            const SizedBox(height: 24),

            // ✅ 저장 버튼
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: Text(
                '저장',
                style: GoogleFonts.nanumMyeongjo(),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              onPressed: _saveEditedSummary,
            ),

            const SizedBox(height: 40), // ✅ sum_result.dart와 동일한 하단 여백
          ],
        ),
      ),
    );
  }
}
