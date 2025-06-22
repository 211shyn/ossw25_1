import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _pwCheckController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _signUp() async {
    final email = _emailController.text.trim();
    final pw = _pwController.text.trim();
    final pwCheck = _pwCheckController.text.trim();

    if (pw != pwCheck) {
      _showError('비밀번호가 서로 달라요. 다시 확인해주세요!');
      return;
    }

    try {
      final newUser = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: pw,
      );

      if (newUser.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('회원가입이 완료되었습니다!')),
        );
        Navigator.pop(context, 'success');
      }
    } catch (e) {
      _showError('회원가입에 실패했어요. (${e.toString()})');
      print('❌ 회원가입 오류: $e');
    }
  }

  void _showError(String msg) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('문제가 생겼어요ㅠㅠ'),
        content: Text(msg),
        actions: [
          TextButton(
            child: const Text('확인'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD8E6ED),
      appBar: AppBar(
        title: Text(
          'JALVIS : 회원가입',
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ✅ 이미지 크기 고정
              SizedBox(
                height: 500,
                child: Image.asset(
                  'assets/puangNjalvis.png',
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'JALVIS와 함께 일기를 시작해보세요!',
                textAlign: TextAlign.center,
                style: GoogleFonts.nanumMyeongjo(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 24),

              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: '당신의 E-mail을 알려주세요.',
                  labelStyle: GoogleFonts.nanumMyeongjo(),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _pwController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: '일기장 자물쇠의 비밀번호는 무엇인가요?',
                  labelStyle: GoogleFonts.nanumMyeongjo(),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _pwCheckController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: '비밀번호를 한 번 더 입력해주세요!',
                  labelStyle: GoogleFonts.nanumMyeongjo(),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                icon: const Icon(Icons.person_add),
                label: Text(
                  '회원가입 완료!',
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
                onPressed: _signUp,
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
