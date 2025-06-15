import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'login.dart';
import 'write_diary.dart';
import 'calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
        useMaterial3: true,
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

  // 🔥 오전 8시를 기준으로 날짜 계산하는 함수
  String getEffectiveDate() {
    final now = DateTime.now();
    final cutoffTime = DateTime(now.year, now.month, now.day, 8);
    if (now.isBefore(cutoffTime)) {
      // 오전 8시 이전이면 하루 전날로 계산
      final yesterday = now.subtract(const Duration(days: 1));
      return "${yesterday.year.toString().padLeft(4, '0')}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}";
    } else {
      // 오전 8시 이후면 오늘 날짜
      return "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    }
  }

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
                final todayDate = getEffectiveDate();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WriteDiaryPage(date: todayDate),
                  ),
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
              onPressed: () async {
                final firestore = FirebaseFirestore.instance;
                final snapshot = await firestore.collection('diaries').get();

                final existingDates = snapshot.docs.map((doc) {
                  return DateTime.parse(doc.id);
                }).toList();

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CalendarPage(
                      existingDiaryDates: existingDates,
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
