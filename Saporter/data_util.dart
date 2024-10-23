import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class DataUtil {
  static Future<File> _getLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/data.json');
  }

  static Future<Map<String, dynamic>> loadData() async {
    try {
      final file = await _getLocalFile();
      if (await file.exists()) {
        final contents = await file.readAsString();
        Map<String, dynamic> jsonData = json.decode(contents);
        return jsonData;
      } else {
        return _getDefaultData();
      }
    } catch (e) {
      return _getDefaultData();
    }
  }

  static Future<void> saveData(Map<String, dynamic> data) async {
    final file = await _getLocalFile();
    await file.writeAsString(json.encode(data));
  }

  static Future<void> resetData() async {
    await saveData(_getDefaultData());
  }

  static Map<String, dynamic> _getDefaultData() {
    return {
      "users": [
        {
          "memberNum": "2020140035",
          "password": "123456789"
        }
      ],
      "routine": [
        {
          "title": "평일, 주간 근무시간 내, 정기 순찰 루틴",
          "area": "A구역",
          "description": "07:00~18:00, 1시간 00분 간격으로, 1기, 1회 순찰 후 복귀",
          "dayStatus": [0, 1, 1, 1, 1, 1, 0]
        },
        {
          "title": "평일, 주간 근무시간 내, 정기 순찰 루틴",
          "area": "B구역\nC구역\nD구역",
          "description": "07:00~18:00, 3시간 00분 간격으로, 각 1기, 1회 순찰 후 복귀",
          "dayStatus": [0, 1, 1, 1, 1, 1, 0]
        },
        {
          "title": "매일, 야간 근무시간 내, 정기 순찰 루틴",
          "area": "A구역",
          "description": "00:00~24:00, 1시간 00분 간격으로, 1기, 1회 순찰 후 복귀",
          "dayStatus": [1, 1, 1, 1, 1, 1, 1]
        }
      ],
      "status_check": [
        {
          "robotName": "BOT 1",
          "status": "순찰중",
          "charging": 3,
          "patrolZone": "A",
          "patrolTime": 1
        },
      ],
      "alarm": [
        {
          "port": "D구역",
          "title": "화재",
          "admin": "OOO근무자 확인 완료",
          "bot": "Bot 3",
          "time": "3월 4일 15시 37분",
          "resolved": true
        },
        {
          "port": "C구역",
          "title": "가스누출",
          "admin": "OOO근무자 확인 완료",
          "bot": "Bot 4",
          "time": "3월 4일 17시 30분",
          "resolved": true
        },
        {
          "port": "A구역",
          "title": "침입자",
          "admin": "OOO근무자 확인 완료",
          "bot": "Bot 1",
          "time": "3월 4일 00시 30분",
          "resolved": false
        }
      ]
    };
  }
}
