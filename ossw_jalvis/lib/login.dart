import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (credential.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainPage()),
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('로그인에 실패했어요ㅠㅠ'),
          content: Text('오류: ${e.toString()}'),
          actions: [
            TextButton(
              child: const Text('확인'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
      print('❌ 로그인 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD8E6ED),
      appBar: AppBar(
        title: Text(
          'JALVIS : 당신의 하루를 요약합니다.',
          style: GoogleFonts.nanumMyeongjo(
            fontWeight: FontWeight.w600,
            fontSize: 24,
            letterSpacing: 1.5,
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
            // ✅ 중앙 이미지
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset(
                    'assets/puangNjalvis.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ✅ 안내 문구 추가
            Text(
              '당신의 일기를 소중하게 저장하기 위해,\n JALVIS가 로그인을 부탁합니다!',
              textAlign: TextAlign.center,
              style: GoogleFonts.nanumMyeongjo(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 20),

            // 🔥 이메일 입력 필드
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'E-mail을 JALVIS에게 알려주세요',
                labelStyle: GoogleFonts.nanumMyeongjo(),
                border: const OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // 🔥 비밀번호 입력 필드
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: '비밀번호도요! JALVIS는 비밀을 잘 지킵니다.',
                labelStyle: GoogleFonts.nanumMyeongjo(),
                border: const OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            // 🔥 로그인 버튼
            ElevatedButton.icon(
              icon: const Icon(Icons.login),
              label: Text(
                '일기 들려주러 가기',
                style: GoogleFonts.nanumMyeongjo(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
              onPressed: _login,
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
