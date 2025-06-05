import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main.dart'; // 로그인 성공 시 MainPage로 이동

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  /// 로그인 버튼 클릭 시 호출되는 함수
  void _login() async {
    // 🔥 TODO: 여기서 Firebase Auth 연동 (email/password 로그인)
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (credential.user != null) {
        // 로그인 성공 → MainPage로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainPage()),
        );
      }
    } catch (e) {
      // 로그인 실패 시 에러 메시지 출력
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('로그인 실패'),
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
    //Navigator.pushReplacement(
      //context,
      //MaterialPageRoute(builder: (context) => const MainPage()),
    //);

    // 디버깅용 로그 출력
    //print('로그인 버튼 클릭!');
    //print('이메일: ${_emailController.text}');
    //print('비밀번호: ${_passwordController.text}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('로그인'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // 🔥 이메일 입력 필드
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: '이메일',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            // 🔥 비밀번호 입력 필드 (입력값 숨김 처리)
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: '비밀번호',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 30),
            // 🔥 로그인 버튼
            ElevatedButton.icon(
              icon: const Icon(Icons.login),
              label: const Text('로그인'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              onPressed: _login,
            ),
          ],
        ),
      ),
    );
  }
}
