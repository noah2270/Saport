import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // 날짜 형식을 위해 intl 패키지 사용
import 'package:flutter/services.dart' show rootBundle; // rootBundle import
import 'weather_popup.dart'; // WeatherPopup import

class WeatherService extends ChangeNotifier {
  Timer? _timer;
  late DateTime now;
  late String formattedDate;

  WeatherService() {
    debugPrint("WeatherService: Constructor called");
    now = DateTime.now();
    formattedDate = DateFormat('yyyyMMdd').format(now);
    debugPrint("$formattedDate");
    startPeriodicTimer();
  }

  void startPeriodicTimer() {
    debugPrint("WeatherService: startPeriodicTimer called");
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      debugPrint("Periodic Timer triggered"); // 주기적 타이머 작동 확인용
      _checkWeatherAlert();
    });
  }

  void stopPeriodicTimer() {
    debugPrint("WeatherService: stopPeriodicTimer called");
    _timer?.cancel();
  }

  Future<void> _checkWeatherAlert() async {
    debugPrint("Checking weather alert"); // API 호출 확인용

    // 로컬 JSON 파일 읽기
    final temp = await rootBundle.loadString('assets/test_weather.json');
    final response = json.decode(temp);
    debugPrint("JSON data: $response");

    // API 요청 예시 (비활성화)
    /*
    final apiResponse = await http.get(Uri.parse(
        'https://apis.data.go.kr/1360000/WthrWrnInfoService/getPwnCd?serviceKey=LqvjM4t9lDu9iXk4Ngxw9NHgXO%2BruXfVq%2BhIUS2NXOE55mn9%2BDmvd2NBMAvHNx%2FQh5K5QADHnhiwf3p7z%2BWOQA%3D%3D&pageNo=1&numOfRows=10&dataType=JSON&fromTmFc=$formattedDate&toTmFc=$formattedDate&areaCode=S1231100'));

    if (apiResponse.statusCode == 200) {
      var jsonResponse = json.decode(apiResponse.body);
      var header = jsonResponse['response']['header'];
      if (header['resultCode'] == "00") {
        debugPrint("Weather alert check successful"); // API 성공 확인용
        bool alert = _parseWeatherAlert(jsonResponse);
        if (alert) {
          debugPrint("Weather alert found"); // 경보 조건 만족 확인용
          _showWeatherPopup(jsonResponse['response']['body']['items']['item'][0]);
          notifyListeners(); // 상태 변화 알림
        } else {
          debugPrint("No weather alert found"); // 경보 조건 불만족 확인용
        }
      } else {
        debugPrint("Failed to load weather alert: ${header['resultCode']}"); // API 실패 확인용
        throw Exception('Failed to load weather alert');
      }
    } else {
      throw Exception('Failed to load weather alert');
    }
    */

    var header = response['response']['header'];
    if (header['resultCode'] == "00") {
      debugPrint("Weather alert check successful"); // API 성공 확인용
      bool alert = _parseWeatherAlert(response);
      if (alert) {
        debugPrint("Weather alert found"); // 경보 조건 만족 확인용
        _showWeatherPopup(response['response']['body']['items']['item'][0]);
        notifyListeners(); // 상태 변화 알림
      } else {
        debugPrint("No weather alert found"); // 경보 조건 불만족 확인용
      }
    } else {
      debugPrint("Failed to load weather alert: ${header['resultCode']}"); // API 실패 확인용
      throw Exception('Failed to load weather alert');
    }
  }

  bool _parseWeatherAlert(dynamic data) {
    var items = data['response']['body']['items']['item'];
    return items != null && items.isNotEmpty;
  }

  void _showWeatherPopup(Map<String, dynamic> weatherData) {
    final context = navigatorKey.currentState?.overlay?.context;
    if (context != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return WeatherPopup(
            areaName: weatherData['areaName'],
            tmFc: weatherData['tmFc'],
            warnVar: weatherData['warnVar'],
            warnStress: weatherData['warnStress'],
          );
        },
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
    debugPrint("WeatherService disposed"); // dispose 호출 확인용
  }
}

// Global key to access the context
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
