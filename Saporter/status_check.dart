import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/gestures.dart';
import 'data_util.dart';

// 색상 상수 선언
const Color robotBoxColor = Color(0xFF3F65A3);
const Color robotTextBoxColor = Color(0xFFDCEAFF);
const Color redColor = Color(0xFFFF0000);
const Color blueColor = Color(0xFF003EFF);
const Color greenColor = Color(0xFF00FF40);
const Color blackColor = Color(0xFF000000);
const Color robotTextColor = Color(0xFF214072);
const Color settingColor = Color(0xFF223956);
const Color routinePopupClick = Color(0xFF4C78BF);
const Color routinePopupText = Color(0xFFD9D9D9);
const Color routinePopupTitle = Color(0xFF2478C2);

class StatusCheckContent extends StatefulWidget {
  final Function(List<Map<String, dynamic>>) onEdit;

  StatusCheckContent({required this.onEdit});

  @override
  _StatusCheckContentState createState() => _StatusCheckContentState();
}

class _StatusCheckContentState extends State<StatusCheckContent> {
  List<Map<String, dynamic>> statusData = [];

  @override
  void initState() {
    super.initState();
    _loadStatusData();
  }

  Future<void> _loadStatusData() async {
    try {
      final data = await DataUtil.loadData();
      setState(() {
        statusData = List<Map<String, dynamic>>.from(data['status_check']);
      });
    } catch (e) {
      print('Error loading status data: $e');
    }
  }

  Future<void> _saveStatusData() async {
    try {
      final data = await DataUtil.loadData();
      data['status_check'] = statusData;
      await DataUtil.saveData(data);
    } catch (e) {
      print('Error saving status data: $e');
    }
  }

  void _updateRobotStatus(Map<String, dynamic> robot) {
    setState(() {
      var index = statusData.indexWhere((r) => r['robotName'] == robot['robotName']);
      if (index != -1) {
        statusData[index] = robot;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTopInfoText(),
        Expanded(
          child: ListView.builder(
            physics: NeverScrollableScrollPhysics(), // 스크롤 비활성화
            padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
            itemCount: statusData.length,
            itemBuilder: (context, index) {
              return _buildRobotCard(statusData[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTopInfoText() {
    return Container(
      height: 20,
      width: 400,
      margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            '※순찰 구역을 확인/ 지정하려면 로봇을 선택하세요.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _buildStatusIndicator(greenColor, ': 순찰중', 9),
              SizedBox(width: 2),
              _buildStatusIndicator(blueColor, ': 충전중', 9),
              SizedBox(width: 2),
              _buildStatusIndicator(blackColor, ': 대기중', 9),
              SizedBox(width: 2),
              _buildStatusIndicator(redColor, ': 상황발생', 9),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(Color color, String label, double fontSize) {
    return Row(
      children: [
        Container(
          width: 5,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(color: Colors.white, fontSize: fontSize),
        ),
        SizedBox(width: 3),
      ],
    );
  }

  Widget _buildRobotCard(Map<String, dynamic> robot) {
    return Container(
      width: 350,
      height: 97,
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: robotBoxColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 5.0,
            spreadRadius: 0.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Card(
        color: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ListTile(
              title: _buildRobotInfo(robot),
              subtitle: _buildRobotStatus(robot),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRobotInfo(Map<String, dynamic> robot) {
    return Container(
      margin: EdgeInsets.only(left: 30),
      child: Row(
        children: [
          Text(
            robot['robotName'] ?? 'Unknown',
            style: TextStyle(color: Colors.white, fontSize: 15),
          ),
          SizedBox(width: 4),
          GestureDetector(
            onTap: () {
              _showEditDialog(context, robot);
            },
            child: Icon(Icons.edit, color: settingColor, size: 15),
          ),
          SizedBox(width: 2),
          if (robot['charging'] == 1 || robot['status'] == '상황발생')
            Icon(
              Icons.notification_important,
              color: robot['status'] == '상황발생' ? redColor : settingColor,
              size: 15,
            ),
          Spacer(),
          GestureDetector(
            onTap: () {
              _showLiveVideoDialog(context);
            },
            child: Column(
              children: [
                Icon(Icons.linked_camera_outlined, color: Colors.white, size: 17),
                Text('실시간 영상', style: TextStyle(color: Colors.white, fontSize: 9)),
              ],
            ),
          ),
          SizedBox(width: 10),
          Column(
            children: [
              _getBatteryIcon(robot['charging'] ?? 0),
              Text('충전 상태', style: TextStyle(color: Colors.white, fontSize: 9)),
            ],
          ),
          SizedBox(width: 10),
          Column(
            children: [
              _getStatusIcon(robot['status'] ?? '대기중'),
              Text('활동 상태', style: TextStyle(color: Colors.white, fontSize: 9)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRobotStatus(Map<String, dynamic> robot) {
    final statusInfo = _getStatusText(
      robot['status'] ?? '대기중',
      robot['patrolZone'] ?? 'Unknown',
      robot['charging'] ?? 0,
    );
    final bool isMultiLine = statusInfo['text'].contains('\n');

    return Container(
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.only(top: 10, left: 6),
      decoration: BoxDecoration(
        color: robotTextBoxColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: isMultiLine
            ? FittedBox(
          fit: BoxFit.contain,
          child: Text(
            statusInfo['text'],
            style: TextStyle(
              color: robotTextColor,
              fontWeight: FontWeight.bold,
              fontSize: 11.5,
              height: 0.9,
            ),
            textAlign: TextAlign.center,
          ),
        )
            : Text(
          statusInfo['text'],
          style: TextStyle(
            color: robotTextColor,
            fontWeight: FontWeight.bold,
            fontSize: 14.0,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Icon _getBatteryIcon(int charging) {
    switch (charging) {
      case 0:
        return Icon(Icons.battery_charging_full, color: Colors.white, size: 17);
      case 1:
        return Icon(Icons.battery_2_bar, color: Colors.white, size: 17);
      case 2:
        return Icon(Icons.battery_5_bar, color: Colors.white, size: 17);
      case 3:
        return Icon(Icons.battery_full, color: Colors.white, size: 17);
      default:
        return Icon(Icons.battery_alert, color: Colors.white, size: 17);
    }
  }

  Icon _getStatusIcon(String status) {
    switch (status) {
      case '순찰중':
        return Icon(Icons.circle, color: greenColor, size: 17);
      case '충전중':
        return Icon(Icons.circle, color: blueColor, size: 17);
      case '대기중':
        return Icon(Icons.circle, color: blackColor, size: 17);
      case '상황발생':
        return Icon(Icons.circle, color: redColor, size: 17);
      default:
        return Icon(Icons.circle, color: blackColor, size: 17);
    }
  }

  Map<String, dynamic> _getStatusText(String status, String zone, int charging) {
    switch (status) {
      case '순찰중':
        if (charging == 1) {
          return {
            'text': '현재 배터리가 부족합니다.\n$zone 구역을 순찰중입니다.',
            'isSmallFont': true
          };
        }
        return {'text': '$zone 구역을 순찰중입니다.', 'isSmallFont': false};
      case '충전중':
        return {'text': '관리실에서 충전중입니다.', 'isSmallFont': false};
      case '대기중':
        return {'text': '관리실에서 대기중입니다.', 'isSmallFont': false};
      case '상황발생':
        return {
          'text': '상황이 발생하였습니다.\n즉시 확인해주세요.',
          'isSmallFont': true
        };
      default:
        return {'text': '상태 불명', 'isSmallFont': false};
    }
  }

  void _showLiveVideoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Center(
                child: VideoPlayerScreen(),
              ),
              Positioned(
                top: 20,
                left: 20,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String selectedZone = 'A';
  int selectedTime = 1;

  void _showZonePicker(StateSetter setState) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '구역 선택',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              DropdownButton<String>(
                value: selectedZone,
                items: <String>['A', 'B', 'C'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedZone = newValue!;
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTimePicker(StateSetter setState) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '시간 선택',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              DropdownButton<int>(
                value: selectedTime,
                items: List.generate(9, (index) => index + 1).map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(value.toString()),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  setState(() {
                    selectedTime = newValue!;
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, Map<String, dynamic> robot) {
    setState(() {
      selectedZone = robot['patrolZone'];
      selectedTime = robot['patrolTime'];
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: routinePopupText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildDialogTitle(),
                  _buildDialogContent(setState, robot),
                  _buildDialogActions(context, robot),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildDialogTitle() {
    return Container(
      decoration: BoxDecoration(
        color: routinePopupTitle,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      padding: EdgeInsets.all(10),
      child: Center(
        child: Text(
          '설정',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildDialogContent(StateSetter setState, Map<String, dynamic> robot) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      color: routinePopupText, // 배경색 설정
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(fontSize: 18, color: Colors.black),
              children: <TextSpan>[
                TextSpan(
                  text: '${robot['robotName']} ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
                TextSpan(text: '이  '),
                TextSpan(
                  text: selectedZone,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => _showZonePicker(setState),
                ),
                TextSpan(text: '구역을\n'),
                TextSpan(
                  text: '$selectedTime',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => _showTimePicker(setState),
                ),
                TextSpan(text: '(시간)동안 \n순찰하도록 하겠습니까?'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogActions(BuildContext context, Map<String, dynamic> robot) {
    return Container(
      decoration: BoxDecoration(
        color: routinePopupClick,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () {
                // 로봇의 구역과 시간을 업데이트
                robot['patrolZone'] = selectedZone;
                robot['patrolTime'] = selectedTime;

                // 메인 상태 업데이트 함수 호출
                _updateRobotStatus(robot);

                Navigator.of(context).pop();
              },
              child: Text(
                '확인',
                style: TextStyle(
                  fontWeight: FontWeight.bold, // 글씨 굵게 설정
                  fontSize: 17,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white, // 글자색
              ),
            ),
          ),
          Expanded(
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                '취소',
                style: TextStyle(
                  fontWeight: FontWeight.bold, // 글씨 굵게 설정
                  fontSize: 17,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white, // 글자색
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/sample_video.mov')
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _controller.value.isInitialized
          ? AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            VideoPlayer(_controller),
            _ControlsOverlay(controller: _controller),
            VideoProgressIndicator(_controller, allowScrubbing: true),
          ],
        ),
      )
          : CircularProgressIndicator(),
    );
  }
}

class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({Key? key, required this.controller}) : super(key: key);

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: Duration(milliseconds: 50),
          reverseDuration: Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? const SizedBox.shrink()
              : Container(
            color: Colors.black26,
            child: const Center(
              child: Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 100.0,
                semanticLabel: 'Play',
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
      ],
    );
  }
}
