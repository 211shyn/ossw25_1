import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'login.dart';
import 'write_diary.dart';
import 'calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initializeDateFormatting('ko_KR', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JALVIS',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        textTheme: GoogleFonts.nanumMyeongjoTextTheme().copyWith(
          bodyLarge: GoogleFonts.quicksand(
            textStyle: GoogleFonts.nanumMyeongjo().copyWith(fontSize: 16),
          ),
          bodyMedium: GoogleFonts.quicksand(
            textStyle: GoogleFonts.nanumMyeongjo().copyWith(fontSize: 14),
          ),
          titleLarge: GoogleFonts.quicksand(
            textStyle: GoogleFonts.nanumMyeongjo().copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
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

  String getEffectiveDate() {
    final now = DateTime.now();
    final cutoffTime = DateTime(now.year, now.month, now.day, 8);
    if (now.isBefore(cutoffTime)) {
      final yesterday = now.subtract(const Duration(days: 1));
      return "${yesterday.year.toString().padLeft(4, '0')}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}";
    } else {
      return "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFD8E6ED),
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
        backgroundColor: const Color(0xFFF7F2EC), // ✅ 베이지색 배경
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            // ✅ 이미지
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

            const SizedBox(height: 40),

            // ✅ 버튼 2개
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.edit, size: 26),
                    label: Text(
                      '오늘 하루 기록하기',
                      style: GoogleFonts.nanumMyeongjo(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 36), // ✅ 높이 증가
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    onPressed: () {
                      final todayDate = getEffectiveDate();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              WriteDiaryPage(date: todayDate),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.list, size: 26),
                    label: Text(
                      '이전 기록 보기',
                      style: GoogleFonts.nanumMyeongjo(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 36), // ✅ 높이 증가
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    onPressed: () async {
                      final firestore = FirebaseFirestore.instance;
                      final snapshot =
                      await firestore.collection('diaries').get();

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
                ),
              ],
            ),

            const SizedBox(height: 32),

            // ✅ 제작 정보 박스 (오른쪽 정렬)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey, width: 1.5),
                  ),
                  child: Text(
                    '제작 : 팀 스물하나, 스물셋',
                    style: GoogleFonts.nanumMyeongjo(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
