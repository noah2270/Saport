import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'data_util.dart'; // 데이터 유틸리티 함수 import

const int back_grid_main_color = 0xE6BED7FF;
const int back_grid_top_color = 0xE6DCEAFF;
const int content_box_color = 0xFF4C78BF;
const int inner_box_color = 0xFF76BFFF;
const int activated_color = 0xFF23497B;
const int unactivated_color = 0xFFFFFFFF;
const int day_box_color = 0xFFA6CDFF;

class RoutineManagementContent extends StatefulWidget {
  final Function(List<Map<String, dynamic>> contentData) onEdit;
  final Function(List<Map<String, dynamic>> newContent) onAdd;

  RoutineManagementContent({required this.onEdit, required this.onAdd});

  @override
  _RoutineManagementContentState createState() => _RoutineManagementContentState();
}

class _RoutineManagementContentState extends State<RoutineManagementContent> {
  int selectedIndex = -1; // 선택된 컨테이너 인덱스를 저장하는 변수
  OverlayEntry? _popupMenuOverlay;
  OverlayEntry? _ArrangeMenuOverlay;
  OverlayEntry? _SettingMenuOverlay;
  final GlobalKey _moreOptionsKey = GlobalKey(); // More options 버튼의 키
  List<bool> _routineswitchStates = []; // 슬라이드 버튼의 상태 리스트
  List<bool> _settingswitchStates = []; // 세팅 슬라이드 버튼의 상태 리스트

  List<Map<String, dynamic>> contentData = [];

  @override
  void initState() {
    super.initState();
    _loadRoutineData();
  }

  Future<void> _loadRoutineData() async {
    final data = await DataUtil.loadData();
    setState(() {
      contentData = List<Map<String, dynamic>>.from(data['routine']);
      _routineswitchStates = List<bool>.filled(contentData.length, false); // 루틴 데이터 개수만큼 기본 false 설정
      _settingswitchStates = List<bool>.filled(contentData.length, true); // 루틴 데이터 개수만큼 기본 true 설정
    });
  }

  Future<void> _saveRoutineData() async {
    final data = await DataUtil.loadData();
    data['routine'] = contentData;
    await DataUtil.saveData(data);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _buildInfoContainer(),
          Expanded(
            child: ListView.builder(
              physics: NeverScrollableScrollPhysics(), // 스크롤 비활성화
              itemCount: contentData.length,
              itemBuilder: (context, index) {
                var data = contentData[index];
                return Column(
                  children: [
                    _buildContentContainer(
                      index,
                      data['title'],
                      data['area'],
                      data['description'],
                      List<int>.from(data['dayStatus']),
                    ),
                    SizedBox(height: 16), // 컨테이너 사이의 간격
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoContainer() {
    return Container(
      height: 20, // 높이를 적절히 조정
      width: 400,
      margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start, // 전체 Row의 중앙 정렬
        crossAxisAlignment: CrossAxisAlignment.center, // 전체 Row의 중앙 정렬
        children: <Widget>[
          Text(
            '루틴',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.normal,
            ),
          ),
          SizedBox(width: 244), // 텍스트와 아이콘 간격 조정
          Row(
            mainAxisAlignment: MainAxisAlignment.center, // 내부 Row의 중앙 정렬
            crossAxisAlignment: CrossAxisAlignment.center, // 내부 Row의 중앙 정렬
            children: <Widget>[
              _buildIconBox(Icons.search, 'Search'),
              _buildIconBox(Icons.add, 'Add'),
              _buildIconBox(Icons.more_vert, 'More options', key: _moreOptionsKey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconBox(IconData icon, String tooltip, {Key? key}) {
    return GestureDetector(
      key: key,
      onTap: () {
        if (tooltip == 'More options') {
          _showMoreOptions(context); // MoreOption 버튼 클릭 시 팝업 메뉴 표시
        }
        if (tooltip == 'Add') {
          widget.onAdd(contentData);
        }
        print('$tooltip icon pressed');
      },
      child: Container(
        width: 40, // 아이콘 박스 너비
        height: 40, // 아이콘 박스 높이
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Tooltip(
          message: tooltip,
          child: Icon(
            icon,
            color: Colors.white,
            size: 16.0, // 아이콘 크기 조정
          ),
        ),
      ),
    );
  }

  //More Option Popup
  void _showMoreOptions(BuildContext context) {
    final RenderBox button = _moreOptionsKey.currentContext!.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context)!.context.findRenderObject() as RenderBox;
    final Offset buttonPosition = button.localToGlobal(Offset.zero, ancestor: overlay);
    final Size buttonSize = button.size;

    final RelativeRect position = RelativeRect.fromLTRB(
      buttonPosition.dx - buttonSize.width,
      buttonPosition.dy,
      overlay.size.width - buttonPosition.dx - buttonSize.width,
      overlay.size.height - buttonPosition.dy,
    );

    _popupMenuOverlay = _createPopupMenu(context, position);
    Overlay.of(context)!.insert(_popupMenuOverlay!);
  }

  OverlayEntry _createPopupMenu(BuildContext context, RelativeRect position) {
    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(
            onTap: () => _popupMenuOverlay?.remove(),
            child: Container(
              color: Colors.transparent,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            ),
          ),
          Positioned(
            left: position.left,
            top: position.top,
            child: Material(
              color: Colors.transparent,
              child: GestureDetector(
                onTap: () => _popupMenuOverlay?.remove(),
                child: Container(
                  width: 88,
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
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
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      _buildPopupMenuItem(context, '편집', 0),
                      _buildPopupMenuItem(context, '정렬', 1),
                      _buildPopupMenuItem(context, '설정', 2),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopupMenuItem(BuildContext context, String title, int value) {
    return GestureDetector(
      onTap: () {
        _popupMenuOverlay?.remove();
        switch (value) {
          case 0:
            widget.onEdit(contentData);
            break;
          case 1:
            _showArrange(context);
            break;
          case 2:
            _showSetting(context);
            break;
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  //Arrange Option Popup
  void _showArrange(BuildContext context) {
    final RenderBox button = _moreOptionsKey.currentContext!.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context)!.context.findRenderObject() as RenderBox;
    final Offset buttonPosition = button.localToGlobal(Offset.zero, ancestor: overlay);
    final Size buttonSize = button.size;

    final RelativeRect position = RelativeRect.fromLTRB(
      buttonPosition.dx - buttonSize.width - 32,
      buttonPosition.dy,
      overlay.size.width - buttonPosition.dx - buttonSize.width,
      overlay.size.height - buttonPosition.dy,
    );

    _ArrangeMenuOverlay = _createArrangeMenu(context, position);
    Overlay.of(context)!.insert(_ArrangeMenuOverlay!);
  }

  OverlayEntry _createArrangeMenu(BuildContext context, RelativeRect position) {
    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(
            onTap: () => _ArrangeMenuOverlay?.remove(),
            child: Container(
              color: Colors.transparent,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            ),
          ),
          Positioned(
            left: position.left,
            top: position.top,
            child: Material(
              color: Colors.transparent,
              child: GestureDetector(
                onTap: () => _ArrangeMenuOverlay?.remove(),
                child: Container(
                  width: 120,
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
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
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      _buildArrangeItem(context, '루틴 시작\n시간 순서', 0),
                      _buildArrangeItem(context, '경비 구역 순서', 1),
                      _buildArrangeItem(context, '루틴 요일 순서', 2),
                      _buildArrangeItem(context, '사용자 지정', 3),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArrangeItem(BuildContext context, String title, int value) {
    return GestureDetector(
      onTap: () {
        _ArrangeMenuOverlay?.remove();
        switch (value) {
          case 0:
            print('루틴 시작 시간 순서 selected');
            break;
          case 1:
            print('경비 구역 순서 selected');
            break;
          case 2:
            print('루틴 요일 순서 selected');
            break;
          case 3:
            print('사용자 지정 selected');
            break;
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  //Setting Option Popup
  void _showSetting(BuildContext context) {
    final RenderBox button = _moreOptionsKey.currentContext!.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context)!.context.findRenderObject() as RenderBox;
    final Offset buttonPosition = button.localToGlobal(Offset.zero, ancestor: overlay);
    final Size buttonSize = button.size;

    final RelativeRect position = RelativeRect.fromLTRB(
      buttonPosition.dx - buttonSize.width - 112,
      buttonPosition.dy,
      overlay.size.width - buttonPosition.dx - buttonSize.width,
      overlay.size.height - buttonPosition.dy,
    );

    _SettingMenuOverlay = _createSettingMenu(context, position);
    Overlay.of(context)!.insert(_SettingMenuOverlay!);
  }

  OverlayEntry _createSettingMenu(BuildContext context, RelativeRect position) {
    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(
            onTap: () => _SettingMenuOverlay?.remove(),
            child: Container(
              color: Colors.transparent,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            ),
          ),
          Positioned(
            left: position.left,
            top: position.top,
            child: Material(
              color: Colors.transparent,
              child: GestureDetector(
                onTap: () => _SettingMenuOverlay?.remove(),
                child: Container(
                  width: 200,
                  padding: EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
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
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      _buildSettingItem(context, 0, '로봇 출발 전 알림', 0),
                      _buildSettingItem(context, 1, '로봇 복귀 후 알림', 1),
                      _buildSettingItem(context, 2, '곧 실행될 루틴 미리 알림', 2),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(BuildContext context, int index, String title, int value) {
    return GestureDetector(
      onTap: () {
        _SettingMenuOverlay?.remove();
        switch (value) {
          case 0:
            _showSetting(context);
            print('로봇 출발 전 알림 selected');
            break;
          case 1:
            _showSetting(context);
            print('로봇 복귀 후 알림 selected');
            break;
          case 2:
            _showSetting(context);
            print('곧 실핼될 루틴 알림 selected');
            break;
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Align(
          alignment: Alignment.topLeft,
          child: Row(
            children: <Widget>[
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                ),
              ),
              Spacer(),
              Container(
                height: 10,
                child: Transform.scale(
                  scale: 0.5, // 슬라이드 버튼 크기 조정
                  child: CupertinoSwitch(
                    value: _settingswitchStates[index],
                    activeColor: CupertinoColors.activeGreen,
                    onChanged: (bool value) {
                      setState(() {
                        _settingswitchStates[index] = value;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentContainer(int index, String title, String area, String description, List<int> dayStatus) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = selectedIndex == index ? -1 : index; // 현재 선택된 인덱스를 다시 누르면 해제
        });
      },
      child: Container(
        height: 90,
        width: 400,
        margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
        decoration: BoxDecoration(
          color: Color(back_grid_main_color),
          borderRadius: BorderRadius.circular(10.0),
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              height: 28,
              width: 400,
              margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
              decoration: BoxDecoration(
                color: Color(back_grid_top_color),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0),
                ),
                border: Border(
                  bottom: BorderSide(color: Colors.white),
                ),
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    height: 18,
                    width: 164,
                    margin: EdgeInsets.fromLTRB(4, 2, 0, 0),
                    decoration: BoxDecoration(
                      color: Color(inner_box_color),
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Center(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10, // 글꼴 크기
                          color: Colors.white, // 글꼴 색상
                          fontWeight: FontWeight.normal, // 글꼴 두께
                        ),
                      ),
                    ),
                  ),
                  Spacer(), // 남은 공간을 차지하여 새로운 컨테이너와 슬라이드 버튼을 오른쪽으로 정렬
                  Container(
                    height: 12,
                    width: 66,
                    margin: EdgeInsets.fromLTRB(0, 2, 0, 0),
                    decoration: BoxDecoration(
                      color: Color(day_box_color),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Center(
                      child: RichText(
                        text: TextSpan(
                          children: List.generate(7, (i) {
                            return TextSpan(
                              text: ['일', '월', '화', '수', '목', '금', '토'][i] + ' ',
                              style: TextStyle(
                                fontSize: 7, // 글꼴 크기
                                color: dayStatus[i] == 0 ? Color(unactivated_color) : Color(activated_color), // 상태에 따른 색상 지정
                                fontWeight: FontWeight.normal, // 글꼴 두께
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 20,
                    child: Transform.scale(
                      scale: 0.6, // 슬라이드 버튼 크기 조정
                      child: CupertinoSwitch(
                        value: _routineswitchStates[index],
                        activeColor: CupertinoColors.activeGreen,
                        onChanged: (bool value) {
                          setState(() {
                            _routineswitchStates[index] = value;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 62,
              width: 400,
              margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container( // Area Container
                    height: 52,
                    width: 100,
                    margin: EdgeInsets.fromLTRB(2.0, 0, 2.0, 0),
                    padding: EdgeInsets.all(0.0),
                    decoration: BoxDecoration(
                      color: Color(content_box_color),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Center(
                      child: Text(
                        area,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  Container( // Description Container
                    height: 52,
                    width: 278,
                    margin: EdgeInsets.fromLTRB(2.0, 0, 2.0, 0),
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Color(content_box_color),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Center(
                      child: Text(
                        description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
