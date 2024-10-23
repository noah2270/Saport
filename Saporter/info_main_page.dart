import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login_page.dart';
import 'status_check.dart';
import 'notifications.dart';
import 'routine_management.dart';
import 'edit_routine_page.dart';
import 'add_routine_page.dart';
import 'data_util.dart';
import 'weather_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'map_container.dart';
import 'data_fetcher.dart'; // Firestore 리스너를 위한 DataFetcher import

const int SaportBlue = 0xFF2A558C;
const int MenuBlue = 0xFF3F65A3;
const int NonSelectButton = 0xFFC0C0C0;
const int SelectButton = 0xFF4C78BF;
const int IconGray = 0xFFC0C0C0;
const int location = 0xFF2478C2;

class InfoMainPage extends StatefulWidget {
  @override
  _InfoMainPageState createState() => _InfoMainPageState();
}

class _InfoMainPageState extends State<InfoMainPage> {
  int selectedIndex = -1;
  bool isEditing = false;
  bool isAdding = false;
  List<Map<String, dynamic>> contentData = [];
  List<Map<String, dynamic>> statusData = [];
  List<Map<String, dynamic>> alarmData = [];

  late WeatherService weatherService;
  late DataFetcher dataFetcher;

  final List<String> menuItems = [
    '상태 확인 및\n경로 지정',
    '알림',
    '루틴관리',
  ];

  final List<IconData> menuIcons = [
    Icons.format_list_bulleted,
    Icons.notification_important,
    Icons.calendar_month,
  ];

  @override
  void initState() {
    super.initState();
    // DataFetcher 초기화
    dataFetcher = DataFetcher();
    _loadData();

    // WeatherService 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      weatherService = Provider.of<WeatherService>(context, listen: false);
      weatherService.startPeriodicTimer();
    });

    // Firestore 리스너 시작
    dataFetcher.startListeningForChanges();  // 리스너 시작

  }

  @override
  void dispose() {
    // WeatherService 중지
    weatherService.stopPeriodicTimer();
    // 리스너 정지
    dataFetcher.stopListeningForChanges();

    super.dispose();
  }

  void _startListeningForFirestoreChanges() {
    DataFetcher fetcher = DataFetcher();
    fetcher.startListeningForChanges(); // Firestore의 실시간 리스너를 시작
  }

  Future<void> _loadData() async {
    await _loadContentData();
    await _loadStatusData();
    await _loadAlarmData();
  }

  Future<void> _loadContentData() async {
    final data = await DataUtil.loadData();
    setState(() {
      contentData = List<Map<String, dynamic>>.from(data['routine']);
    });
  }

  Future<void> _loadStatusData() async {
    final data = await DataUtil.loadData();
    setState(() {
      statusData = List<Map<String, dynamic>>.from(data['status_check']);
    });
  }

  Future<void> _loadAlarmData() async {
    final data = await DataUtil.loadData();
    setState(() {
      alarmData = List<Map<String, dynamic>>.from(data['alarm']);
    });
  }

  Future<void> _saveContentData() async {
    final data = await DataUtil.loadData();
    data['routine'] = contentData;
    await DataUtil.saveData(data);
  }

  Future<void> _saveStatusData() async {
    final data = await DataUtil.loadData();
    data['status_check'] = statusData;
    await DataUtil.saveData(data);
  }

  Future<void> _saveAlarmData() async {
    final data = await DataUtil.loadData();
    data['alarm'] = alarmData;
    await DataUtil.saveData(data);
  }

  @override
  Widget build(BuildContext context) {
    // WeatherService에 접근
    weatherService = Provider.of<WeatherService>(context);
    return Scaffold(
      appBar: kIsWeb ? _buildAppBarWithMenuWeb(context) : _buildAppBarWithMenuMobile(context),
      backgroundColor: Color(SaportBlue),
      body: kIsWeb ? _buildWebLayout() : _buildMobileLayout(),
    );
  }

  AppBar _buildAppBarWithMenuMobile(BuildContext context) {
    return AppBar(
      title: Padding(
        padding: EdgeInsets.only(top: 0.0),
        child: Column(
          children: [
            Text(
              'SAPORT',
              style: TextStyle(
                fontFamily: 'BlackHanSans',
                fontSize: 28.0,
                color: Colors.white,
                fontWeight: FontWeight.normal,
                letterSpacing: 2.0,
                wordSpacing: 4.0,
              ),
            ),
          ],
        ),
      ),
      centerTitle: true,
      backgroundColor: Color(SaportBlue),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: Container(
          height: 60,
          width: double.infinity,
          margin: EdgeInsets.fromLTRB(10, 0, 10, 15),
          decoration: BoxDecoration(
            color: Color(MenuBlue),
            borderRadius: BorderRadius.circular(5.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 5.0,
                spreadRadius: 0.0,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: <Widget>[
              _buildLogoutButton(context, isWeb: false),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: List.generate(menuItems.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedIndex == index
                              ? Color(SelectButton)
                              : Color(NonSelectButton),
                          foregroundColor: Colors.white,
                          padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 3.0,
                          fixedSize: Size(100, 50),
                        ),
                        onPressed: () {
                          setState(() {
                            if (selectedIndex == index) {
                              selectedIndex = -1; // 선택 해제 로직
                            } else {
                              selectedIndex = index;
                            }
                            isEditing = false;
                            isAdding = false;
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(menuIcons[index], size: 20.0),
                            SizedBox(width: 4),
                            Text(
                              menuItems[index],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBarWithMenuWeb(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return AppBar(
      centerTitle: false,
      backgroundColor: Color(SaportBlue),
      toolbarHeight: 90,
      flexibleSpace: Padding(
        padding: EdgeInsets.only(top: 16.0),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: Color(MenuBlue),
            borderRadius: BorderRadius.circular(5.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 5.0,
                spreadRadius: 0.0,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                children: <Widget>[
                  SizedBox(width: screenWidth * 0.08),
                  _buildAppBarTitle(),
                  SizedBox(width: screenWidth * 0.1),
                  _buildLogoutButton(context, isWeb: true),
                  SizedBox(width: screenWidth * 0.1),
                  Expanded(child: _buildMenuBar(context, isWeb: true)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarTitle() {
    return Text(
      'SAPORT',
      style: TextStyle(
        fontFamily: 'BlackHanSans',
        fontSize: 28.0,
        color: Colors.white,
        fontWeight: FontWeight.normal,
        letterSpacing: 2.0,
        wordSpacing: 4.0,
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, {required bool isWeb}) {
    return TextButton(
      onPressed: () {
        // 로그아웃 시 WeatherService 타이머 중지
        weatherService.stopPeriodicTimer();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      },
      child: isWeb ? Text(
        '홍빈 관리자 | log out |',
        textAlign: TextAlign.center,
      )
          : Text(
        '홍빈 관리자\n| log out |',
        textAlign: TextAlign.center,
      ),
      style: isWeb ? ButtonStyle(
        overlayColor: MaterialStateColor.resolveWith((states) => Colors.transparent),
        foregroundColor: MaterialStateProperty.all(Colors.white),
        textStyle: MaterialStateProperty.all(TextStyle(fontSize: 14.0)),
      )
          : ButtonStyle(
          overlayColor: MaterialStateColor.resolveWith(
                  (states) => Colors.transparent),
          foregroundColor: MaterialStateProperty.all(Colors.white),
          textStyle: MaterialStateProperty.all(TextStyle(
            fontSize: 10.0,
          ))
      ),
    );
  }

  Widget _buildMenuBar(BuildContext context, {required bool isWeb}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(menuItems.length, (index) {
        return Padding(
          padding: const EdgeInsets.all(2.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: selectedIndex == index ? Color(SelectButton) : Color(NonSelectButton),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 3.0,
              fixedSize: isWeb ? Size(200, 60) : Size(100, 50),
            ),
            onPressed: () {
              setState(() {
                if (selectedIndex == index) {
                  selectedIndex = -1; // 선택 해제 로직
                } else {
                  selectedIndex = index;
                }
                isEditing = false;
                isAdding = false;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(menuIcons[index], size: isWeb ? 28.0 : 20.0),
                SizedBox(width: isWeb ? 20 : 4),
                Text(
                  menuItems[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isWeb ? 14 : 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildInfoContainerMobile() {
    return LayoutBuilder(
      builder: (context, constraints) {
        double containerWidth = constraints.maxWidth;
        double containerHeight = containerWidth * 1.25; // 높이 비율을 조정
        return Container(
          height: containerHeight,
          width: containerWidth,
          margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(10),
                height: containerHeight * 0.09, // 높이 비율을 조정
                width: containerWidth * 0.4,
                decoration: BoxDecoration(
                  color: Color(location),
                  borderRadius: BorderRadius.circular(5.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 5.0,
                      spreadRadius: 0.0,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: Colors.white,
                      size: containerHeight * 0.06, // 높이 비율을 조정
                    ),
                    SizedBox(width: 10),
                    Text(
                      '현재 위치 확인',
                      style: TextStyle(
                        fontSize: containerHeight * 0.03, // 높이 비율을 조정
                        color: Colors.white,
                        fontWeight: FontWeight.normal,
                        //letterSpacing: 2.0,
                        wordSpacing: 4.0,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(10),
                height: containerHeight * 0.32, // 높이 비율을 조정
                width: containerWidth * 0.75,
                decoration: BoxDecoration(
                  color: Color(MenuBlue),
                  borderRadius: BorderRadius.circular(5.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 5.0,
                      spreadRadius: 0.0,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                      height: containerHeight * 0.9,
                      width: containerWidth * 0.7,
                      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 4),
                      // Container 내부의 padding
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      // 다음 위젯과의 거리를 두기 위한 margin
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              height: 5,
                              margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                              decoration: BoxDecoration(
                                  color: Color(SelectButton),
                                  borderRadius: BorderRadius.circular(5.0)),
                              child: Align(
                                // 텍스트를 왼쪽에 정렬하고 중앙에 배치
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: EdgeInsets.only(left: 10),
                                  // 텍스트와 왼쪽 경계 간의 간격 조정
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                      hintText: '담당구역 |       군산항/ 제 1부두, 제 2부두 구역',
                                      border: InputBorder.none, // 외곽선 제거
                                      suffixIcon: Icon(
                                        Icons.search,
                                        color: Colors.white, // 아이콘 색상
                                        size: 14.0, // 아이콘 크기
                                      ), // 텍스트 필드 뒤에 아이콘 추가
                                      hintStyle: TextStyle(
                                        fontSize: 10.0, // 폰트 크기 설정
                                        color: Colors.white,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10), // 컨테이너 사이의 간격 조절
                          Expanded(
                            child: Container(
                              height: 5,
                              width: 330,
                              child: Align(
                                // 텍스트를 왼쪽에 정렬하고 중앙에 배치
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: EdgeInsets.only(left: 10),
                                  // 텍스트와 왼쪽 경계 간의 간격 조정
                                  child: Text(
                                    '1. 선택 구역         |         A구역',
                                    style: TextStyle(
                                      fontSize: 10.0,
                                      color: Colors.white,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                              decoration: BoxDecoration(
                                  color: Color(SelectButton),
                                  borderRadius: BorderRadius.circular(5.0)),
                            ),
                          ),
                          SizedBox(height: 2), // 컨테이너 사이의 간격 조절
                          Expanded(
                            child: Container(
                              height: 5,
                              width: 330,
                              child: Align(
                                // 텍스트를 왼쪽에 정렬하고 중앙에 배치
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: EdgeInsets.only(left: 10),
                                  // 텍스트와 왼쪽 경계 간의 간격 조정
                                  child: Text(
                                    '2. 순찰 대수         |         1개',
                                    style: TextStyle(
                                      fontSize: 10.0,
                                      color: Colors.white,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                              decoration: BoxDecoration(
                                  color: Color(SelectButton),
                                  borderRadius: BorderRadius.circular(5.0)),
                            ),
                          ),
                          SizedBox(height: 2), // 컨테이너 사이의 간격 조절
                          Expanded(
                            child: Container(
                              height: 5,
                              width: 330,
                              child: Align(
                                // 텍스트를 왼쪽에 정렬하고 중앙에 배치
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: EdgeInsets.only(left: 10),
                                  // 텍스트와 왼쪽 경계 간의 간격 조정
                                  child: Text(
                                    '3. 순찰 로봇 목록  |         BOT1',
                                    style: TextStyle(
                                      fontSize: 10.0,
                                      color: Colors.white,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                              decoration: BoxDecoration(
                                  color: Color(SelectButton),
                                  borderRadius: BorderRadius.circular(5.0)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20), // 높이 비율을 조정
              MapContainer(
                latitude: 37.34006,   // 예시 위도
                longitude: 126.73384, // 예시 경도
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoContainerWeb() {
    return LayoutBuilder(
      builder: (context, constraints) {
        double containerWidth = constraints.maxWidth;
        double containerHeight = containerWidth * 1.25; // 높이 비율을 조정
        return Container(
          height: containerHeight,
          width: containerWidth,
          margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(10),
                height: containerHeight * 0.09, // 높이 비율을 조정
                width: containerWidth * 0.4,
                decoration: BoxDecoration(
                  color: Color(location),
                  borderRadius: BorderRadius.circular(5.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 5.0,
                      spreadRadius: 0.0,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: Colors.white,
                      size: containerHeight * 0.06, // 높이 비율을 조정
                    ),
                    SizedBox(width: 10),
                    Text(
                      '현재 위치 확인',
                      style: TextStyle(
                        fontSize: containerHeight * 0.03, // 높이 비율을 조정
                        color: Colors.white,
                        fontWeight: FontWeight.normal,
                        //letterSpacing: 2.0,
                        wordSpacing: 4.0,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(10),
                height: containerHeight * 0.32, // 높이 비율을 조정
                width: containerWidth * 0.75,
                decoration: BoxDecoration(
                  color: Color(MenuBlue),
                  borderRadius: BorderRadius.circular(5.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 5.0,
                      spreadRadius: 0.0,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                      height: containerHeight * 0.9,
                      width: containerWidth * 0.7,
                      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 4),
                      // Container 내부의 padding
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      // 다음 위젯과의 거리를 두기 위한 margin
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              height: 5,
                              margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                              decoration: BoxDecoration(
                                  color: Color(SelectButton),
                                  borderRadius: BorderRadius.circular(5.0)),
                              child: Align(
                                // 텍스트를 왼쪽에 정렬하고 중앙에 배치
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: EdgeInsets.only(left: 10),
                                  // 텍스트와 왼쪽 경계 간의 간격 조정
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                      hintText: '담당구역 |       군산항/ 제 1부두, 제 2부두 구역',
                                      border: InputBorder.none, // 외곽선 제거
                                      suffixIcon: Icon(
                                        Icons.search,
                                        color: Colors.white, // 아이콘 색상
                                        size: 14.0, // 아이콘 크기
                                      ), // 텍스트 필드 뒤에 아이콘 추가
                                      hintStyle: TextStyle(
                                        fontSize: 10.0, // 폰트 크기 설정
                                        color: Colors.white,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10), // 컨테이너 사이의 간격 조절
                          Expanded(
                            child: Container(
                              height: 5,
                              width: 330,
                              child: Align(
                                // 텍스트를 왼쪽에 정렬하고 중앙에 배치
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: EdgeInsets.only(left: 10),
                                  // 텍스트와 왼쪽 경계 간의 간격 조정
                                  child: Text(
                                    '1. 선택 구역         |         A구역',
                                    style: TextStyle(
                                      fontSize: 10.0,
                                      color: Colors.white,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                              decoration: BoxDecoration(
                                  color: Color(SelectButton),
                                  borderRadius: BorderRadius.circular(5.0)),
                            ),
                          ),
                          SizedBox(height: 2), // 컨테이너 사이의 간격 조절
                          Expanded(
                            child: Container(
                              height: 5,
                              width: 330,
                              child: Align(
                                // 텍스트를 왼쪽에 정렬하고 중앙에 배치
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: EdgeInsets.only(left: 10),
                                  // 텍스트와 왼쪽 경계 간의 간격 조정
                                  child: Text(
                                    '2. 순찰 대수         |         1개',
                                    style: TextStyle(
                                      fontSize: 10.0,
                                      color: Colors.white,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                              decoration: BoxDecoration(
                                  color: Color(SelectButton),
                                  borderRadius: BorderRadius.circular(5.0)),
                            ),
                          ),
                          SizedBox(height: 2), // 컨테이너 사이의 간격 조절
                          Expanded(
                            child: Container(
                              height: 5,
                              width: 330,
                              child: Align(
                                // 텍스트를 왼쪽에 정렬하고 중앙에 배치
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: EdgeInsets.only(left: 10),
                                  // 텍스트와 왼쪽 경계 간의 간격 조정
                                  child: Text(
                                    '3. 순찰 로봇 목록  |         BOT1',
                                    style: TextStyle(
                                      fontSize: 10.0,
                                      color: Colors.white,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                              decoration: BoxDecoration(
                                  color: Color(SelectButton),
                                  borderRadius: BorderRadius.circular(5.0)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20), // 높이 비율을 조정
              MapContainer(
                latitude: 37.7749,   // 예시 위도
                longitude: -122.4194, // 예시 경도
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRoutineContainer() {
    return _buildContainer(
      child: selectedIndex == -1
          ? Center()
          : isEditing
          ? EditPage(
        contentItems: contentData,
        onSave: (newData) {
          setState(() {
            contentData = newData;
            isEditing = false;
          });
          _saveContentData();
        },
      )
          : isAdding
          ? AddPage(
        contentItems: contentData,
        onSave: (newData) {
          setState(() {
            contentData = newData;
            isAdding = false;
          });
          _saveContentData();
        },
      )
          : _getSelectedContent(),
    );
  }

  Widget _buildStatusContainer() {
    return _buildContainer(
      child: isEditing
          ? EditPage(
        contentItems: statusData,
        onSave: (newData) {
          setState(() {
            statusData = newData;
            isEditing = false;
          });
          _saveStatusData();
        },
      )
          : StatusCheckContent(
        onEdit: (data) {
          setState(() {
            statusData = data;
            isEditing = true;
          });
          _saveStatusData();
        },
      ),
    );
  }

  Widget _buildAlarmContainer() {
    return _buildContainer(
      child: isEditing
          ? EditPage(
        contentItems: alarmData,
        onSave: (newData) {
          setState(() {
            alarmData = newData;
            isEditing = false;
          });
          _saveAlarmData();
        },
      )
          : NotificationsContent(
        onEdit: (data) {
          setState(() {
            alarmData = data;
            isEditing = true;
          });
          _saveAlarmData();
        },
      ),
    );
  }

  Widget _buildContainer({required Widget child}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double containerWidth = constraints.maxWidth;
        double containerHeight = containerWidth * 1.3;
        return Container(
          height: containerHeight,
          width: containerWidth,
          margin: EdgeInsets.fromLTRB(10, 5, 10, 0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(2.0),
                  child: child,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildInfoContainerMobile(),
                if (selectedIndex == 0) _buildStatusContainer(),
                if (selectedIndex == 1) _buildAlarmContainer(),
                if (selectedIndex == 2) _buildRoutineContainer(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWebLayout() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical, // 세로 스크롤 가능
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            child: selectedIndex == -1
                ? Container()
                : SingleChildScrollView(
              scrollDirection: Axis.horizontal, // 가로 스크롤 가능
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.4, // 화면의 40% 너비 차지
                    child: _buildInfoContainerWeb(),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.6, // 화면의 60% 너비 차지
                    child: selectedIndex == 0
                        ? _buildStatusContainer()
                        : selectedIndex == 1
                        ? _buildAlarmContainer()
                        : selectedIndex == 2
                        ? _buildRoutineContainer()
                        : Center(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getSelectedContent() {
    switch (selectedIndex) {
      case 0:
        return StatusCheckContent(
          onEdit: (data) {
            setState(() {
              statusData = data;
              isEditing = true;
            });
            _saveStatusData();
          },
        );
      case 1:
        return NotificationsContent(
          onEdit: (data) {
            setState(() {
              alarmData = data;
              isEditing = true;
            });
            _saveAlarmData();
          },
        );
      case 2:
        return RoutineManagementContent(
          onEdit: (data) {
            setState(() {
              contentData = data;
              isEditing = true;
            });
            _saveContentData();
          },
          onAdd: (data) {
            setState(() {
              contentData = data;
              isAdding = true;
            });
            _saveContentData();
          },
        );
      default:
        return Center();
    }
  }
}
