import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'weather_service.dart';
import 'login_page.dart';
import 'data_fetcher.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase Core import
late DataFetcher dataFetcher;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase 초기화
  await Firebase.initializeApp();
  debugPrint('main: Application started');

  DataFetcher fetcher = DataFetcher();
  // DataFetcher 초기화
  dataFetcher = DataFetcher();
  // 초기 어드민 정보 불러오기
  await fetcher.fetchAdminData();

  // 어드민 정보에 대한 실시간 리스너 설정
  fetcher.startListeningForAdminChanges();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    debugPrint('MyApp: build method called');

    return ChangeNotifierProvider<WeatherService>(
      create: (_) => WeatherService(),
      child: MaterialApp(
        title: 'Saport',
        navigatorKey: navigatorKey,
        home: LoginPage(),
      ),
    );
  }
}
