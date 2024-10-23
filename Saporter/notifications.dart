import 'package:flutter/material.dart';
import 'data_util.dart';

const Color firealarmColor = Color(0xFFFF7700);
const Color gasalarmColor = Color(0xFF67DB2D);
const Color personalarmColor = Color(0xFFFFE900);
const Color textColor = Color(0xFF214072);
const Color boxtitleColor = Color(0xFF9ADDFF);
const Color statusalarmColor = Color(0xFFFFFFFF);
const Color timeColor = Color(0xFF142334);
const Color upperboxColor = Color(0xFF3F65A3);
const Color statusboxColor = Color(0xFF4C78BF);
const Color pathColor = Color(0xFF79B4FF);
const Color textboxColor = Color(0xFFDCEAFF);

class NotificationsContent extends StatefulWidget {
  final Function(List<Map<String, dynamic>>) onEdit;

  NotificationsContent({required this.onEdit});

  @override
  _NotificationsContentState createState() => _NotificationsContentState();
}

class _NotificationsContentState extends State<NotificationsContent> {
  List<Map<String, dynamic>> alarmData = [];

  @override
  void initState() {
    super.initState();
    _loadAlarmData();
  }

  Future<void> _loadAlarmData() async {
    final data = await DataUtil.loadData();
    setState(() {
      alarmData = List<Map<String, dynamic>>.from(data['alarm']);
    });
  }

  Future<void> _saveAlarmData() async {
    final data = await DataUtil.loadData();
    data['alarm'] = alarmData;
    await DataUtil.saveData(data);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(), // 스크롤 비활성화
      itemCount: alarmData.length,
      itemBuilder: (context, index) {
        var notification = alarmData[index];
        return NotificationCard(notification: notification);
      },
    );
  }
}

class NotificationCard extends StatelessWidget {
  final Map<String, dynamic> notification;

  NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    String convertedTime = convertToAmPm(notification['time']);
    bool resolved = notification['resolved'] ?? false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NotificationHeader(port: notification['port']),
        NotificationBody(
          notification: notification,
          convertedTime: convertedTime,
          resolved: resolved,
        ),
      ],
    );
  }
}

class NotificationHeader extends StatelessWidget {
  final String port;

  NotificationHeader({required this.port});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 3.0, top: 10.0, bottom: 0),
      child: Text(
        port,
        style: TextStyle(color: pathColor, fontSize: 14),
      ),
    );
  }
}

class NotificationBody extends StatelessWidget {
  final Map<String, dynamic> notification;
  final String convertedTime;
  final bool resolved;

  NotificationBody({
    required this.notification,
    required this.convertedTime,
    required this.resolved,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            StatusBox(notification: notification),
            SizedBox(width: 5),
            StatusInfo(convertedTime: convertedTime, resolved: resolved),
          ],
        ),
        NotificationDetails(notification: notification, resolved: resolved),
      ],
    );
  }
}

class StatusBox extends StatelessWidget {
  final Map<String, dynamic> notification;

  StatusBox({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      width: 80,
      decoration: BoxDecoration(
        color: statusboxColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 0,
            blurRadius: 6,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${notification['title']} 발생',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 2),
          Icon(
            Icons.notification_important,
            color: getStatusColor(notification['title']),
            size: 12,
          ),
        ],
      ),
    );
  }
}

class StatusInfo extends StatelessWidget {
  final String convertedTime;
  final bool resolved;

  StatusInfo({required this.convertedTime, required this.resolved});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.check_box_outlined,
          color: resolved ? boxtitleColor.withOpacity(0.6) : Colors.white,
          size: 16,
        ),
        SizedBox(height: 2),
        Text(
          convertedTime,
          style: TextStyle(
            fontSize: 8,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class NotificationDetails extends StatelessWidget {
  final Map<String, dynamic> notification;
  final bool resolved;

  NotificationDetails({required this.notification, required this.resolved});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: upperboxColor,
      margin: EdgeInsets.symmetric(horizontal: 2, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: upperboxColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Row(
              children: [
                Expanded(child: DetailHeader(title: '근무자 확인')),
                Expanded(child: DetailHeader(title: '신고 상태')),
                Expanded(child: DetailHeader(title: '해결 여부')),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: textboxColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            height: 50,
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
            child: Row(
              children: [
                DetailText(
                  text:
                  '${notification['admin']} - ${notification['bot']}',
                ),
                SizedBox(width: 7),
                DetailText(
                  text: '${notification['time']} 신고',
                ),
                SizedBox(width: 14),
                DetailText(
                  text: resolved
                      ? '${notification['title']} 상황 종료'
                      : '미해결',
                  color: resolved ? textColor : personalarmColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DetailHeader extends StatelessWidget {
  final String title;

  DetailHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            color: boxtitleColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(width: 2),
        Icon(
          Icons.check_box_outlined,
          color: boxtitleColor.withOpacity(0.6),
          size: 12,
        ),
      ],
    );
  }
}

class DetailText extends StatelessWidget {
  final String text;
  final Color? color;

  DetailText({required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        color: color ?? textColor,
        fontWeight: FontWeight.bold,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}

String convertToAmPm(String time) {
  RegExp regex = RegExp(r'(\d{1,2})시 (\d{2})분');
  Match? match = regex.firstMatch(time);
  if (match != null) {
    int hour = int.parse(match.group(1)!);
    int minute = int.parse(match.group(2)!);
    String period = hour >= 12 ? '오후' : '오전';
    hour = hour % 12;
    hour = hour == 0 ? 12 : hour; // 0시는 12시로 표기
    return '$period $hour시 $minute분';
  }
  return time;
}

Color getStatusColor(String title) {
  switch (title) {
    case '화재':
      return firealarmColor;
    case '가스누출':
      return gasalarmColor;
    case '침입자':
      return personalarmColor;
    default:
      return Colors.grey;
  }
}
