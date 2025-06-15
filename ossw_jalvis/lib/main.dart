import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'login.dart';
import 'write_diary.dart';
import 'calendar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // LocaleDataException 방지용 초기화
  await initializeDateFormatting('ko_KR', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '일기 요약 인공지능 : JALVIS',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true, // 최신 디자인 적용
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'),
      ],
      home: const LoginPage(),
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '일기 요약 인공지능 : JALVIS',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ✅ 오늘 하루 기록하기 버튼
            ElevatedButton.icon(
              icon: const Icon(Icons.edit, size: 24),
              label: const Text(
                '오늘 하루 기록하기',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WriteDiaryPage()),
                );
              },
            ),
            const SizedBox(height: 20),
            // ✅ 이전 기록 보기 버튼
            ElevatedButton.icon(
              icon: const Icon(Icons.list, size: 24),
              label: const Text(
                '이전 기록 보기',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              onPressed: () {
                // TODO: 기존 일기 데이터 Firestore 연동 후 기존 일기 날짜 리스트 전달
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CalendarPage(
                      existingDiaryDates: [], // TODO: Firestore 연동 후 교체
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
