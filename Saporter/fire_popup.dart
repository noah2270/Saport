import 'package:flutter/material.dart';

const weather_color = 0xFF3F75FF;

class WeatherPopup extends StatelessWidget {
  final String areaName;
  final int tmFc;
  final int warnVar;
  final int warnStress;

  WeatherPopup({
    required this.areaName,
    required this.tmFc,
    required this.warnVar,
    required this.warnStress,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Color(weather_color), width: 6), // 테두리 색깔과 두께 설정
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.warning, // 경광등 모양의 아이콘
              color: Color(weather_color),
              size: 36,
            ),
            SizedBox(height: 4),
            Text(
              '현재 관리 구역($areaName)에 기상 특보($warnVar)가 발효 되었습니다.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                backgroundColor: Color(weather_color),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('추가 순찰, 방송'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('창 닫기'),
            ),
          ],
        ),
      ),
    );
  }
}

// 이 함수를 사용하여 WeatherPopup을 보여줍니다.
void showWeatherPopup(BuildContext context, String areaName, int tmFc,
    int warnVar, int warnStress) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: '기상특보발효',
    barrierColor: Colors.black.withOpacity(0.1),
    // 배경을 반투명하게 설정
    pageBuilder: (context, animation1, animation2) {
      return Align(
        alignment: Alignment.center,
        child: WeatherPopup(
          areaName: areaName,
          tmFc: tmFc,
          warnVar: warnVar,
          warnStress: warnStress,
        ),
      );
    },
    transitionDuration: Duration(milliseconds: 200),
    transitionBuilder: (context, animation1, animation2, child) {
      return FadeTransition(
        opacity: animation1,
        child: child,
      );
    },
  );
}
