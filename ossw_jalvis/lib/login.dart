import 'package:flutter/material.dart';
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
  void _login() {
    // 🔥 TODO: 여기서 Firebase Auth 연동 (email/password 로그인)
    //
    // 예시:
    // try {
    //   final credential = await FirebaseAuth.instance
    //       .signInWithEmailAndPassword(
    //           email: _emailController.text.trim(),
    //           password: _passwordController.text.trim());
    //   if (credential.user != null) {
    //     Navigator.pushReplacement(
    //       context,
    //       MaterialPageRoute(builder: (context) => const MainPage()),
    //     );
    //   }
    // } catch (e) {
    //   // 에러 처리
    //   print('로그인 실패: $e');
    //   showDialog(...);
    // }
    //
    // 👉 지금은 Firebase가 아직 연결되지 않았으므로,
    // 아래 코드로 임시로 MainPage로 이동만 처리함.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainPage()),
    );

    // 디버깅용 로그 출력
    print('로그인 버튼 클릭!');
    print('이메일: ${_emailController.text}');
    print('비밀번호: ${_passwordController.text}');
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
