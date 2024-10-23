//add_routine_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_inner_shadow/flutter_inner_shadow.dart';

const int SaportBlue = 0xFF2A558C;
const int back_grid_main_color = 0xFFA7BDDD;
const int text_color = 0xFF214072;
const int check_color = 0xFF539FFF;

class AddPage extends StatefulWidget {
  final List<Map<String, dynamic>> contentItems;
  final Function(List<Map<String, dynamic>>) onSave;

  AddPage({required this.contentItems, required this.onSave});

  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  List<Map<String, dynamic>> _currentItems = [];
  String _startH = '00';
  String _startM = '00';
  String _endH = '18';
  String _endM = '00';
  String _dayStatus = '';
  String _title = '';
  String _area = ''; // 단일 문자열로 선택된 구역을 저장
  String _intervalH = '';
  String _intervalM = '';
  String _timeH = '';
  String _timeM = '';
  String _areaper = '';
  String _robotper = '';
  List<String> _areas = ['A구역', 'B구역', 'C구역', 'D구역']; // 선택할 구역 목록
  List<String> _selectedArea = []; // 다중 선택을 위한 리스트

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildCustomAppBar(),
          Expanded(
            child: Column(
              children: [
                Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    color: Color(back_grid_main_color),
                    borderRadius: BorderRadius.circular(5.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 5.0,
                        spreadRadius: 0.0,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 10),
                      _buildTimePickerRow(),
                      _buildDayDisplay(),
                      _buildDaySelector(),
                      _buildRoutineDetails(),
                    ],
                  ),
                ),
                SizedBox(height: 40),
                _buildActionButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Container(
      height: 20,
      // 높이를 적절히 조정
      width: 400,
      margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
      color: Color(SaportBlue),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Align(
            alignment: Alignment.center,
            child: Text(
              '사용자 지정 루틴',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePickerRow() {
    return Container(
      width: 380,
      height: 56,
      child: Stack(
        children: [
          InnerShadow(
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 3,
                offset: Offset(0, -3),
              ),
              Shadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 3,
                offset: Offset(0, 3),
              ),
            ],
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFF4C78BF),
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
          ),
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTimePicker('시작 시간', _startH, _startM,
                        (String h, String m) {
                      setState(() {
                        _startH = h;
                        _startM = m;
                      });
                    }),
                SizedBox(width: 10),
                _buildTimePicker('종료 시간', _endH, _endM, (String h, String m) {
                  setState(() {
                    _endH = h;
                    _endM = m;
                  });
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePicker(String label, String hour, String minute,
      Function(String, String) onChanged) {
    return Row(
      children: [
        Text(
          '$label : ',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Container(
          width: 88,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white10,
            border: Border.all(color: Color(0xFF2E9CFE), width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildTimeField(hour, (value) {
                onChanged(value, minute);
              }),
              Text(
                ':',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              _buildTimeField(minute, (value) {
                onChanged(hour, value);
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField(String value, Function(String) onChanged) {
    return Container(
      width: 36,
      height: 36,
      child: TextField(
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          hintText: value,
          hintStyle: TextStyle(color: Colors.white, fontSize: 22),
          alignLabelWithHint: true,
          contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 0),
          // 패딩 조정
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        style: TextStyle(color: Colors.white, fontSize: 22),
        keyboardType: TextInputType.number,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSmallTimeField(String value, Function(String) onChanged) {
    return Container(
      width: 40, // 작은 크기 설정
      height: 36, // 작은 크기 설정
      child: Align(
        alignment: Alignment.center,
        child: TextField(
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: value,
            hintStyle: TextStyle(color: Colors.white, fontSize: 14),
            alignLabelWithHint: true,
            contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 0),
            // 패딩 조정
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white), // 밑줄 색상
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white), // 활성화된 상태의 밑줄 색상
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white), // 포커스된 상태의 밑줄 색상
            ),
          ),
          style: TextStyle(color: Colors.white, fontSize: 14),
          keyboardType: TextInputType.number,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDaySelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (index) {
        return _buildDayButton(['일', '월', '화', '수', '목', '금', '토'][index]);
      }),
    );
  }

  Widget _buildDayButton(String day) {
    bool isSelected = _dayStatus.contains(day);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _dayStatus = _dayStatus.replaceAll(day, '');
          } else {
            _dayStatus += day;
          }
        });
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isSelected ? Color(check_color) : Color(0x00FFFF),
          shape: BoxShape.circle,
          border: Border.all(
              color: isSelected ? Color(check_color) : Color(0x00FFFF)),
        ),
        child: Center(
          child: Text(
            day,
            style: TextStyle(
              color: isSelected ? Colors.white : Color(text_color),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDayDisplay() {
    List<String> days = ['일', '월', '화', '수', '목', '금', '토'];
    List<String> selectedDays =
    days.where((day) => _dayStatus.contains(day)).toList();

    String displayText = '';
    if (selectedDays.isEmpty) {
      displayText = '내일';
    } else if (selectedDays.length == 7) {
      displayText = '매일';
    } else if (selectedDays.length == 5 &&
        !selectedDays.contains('일') &&
        !selectedDays.contains('토')) {
      displayText = '매주 평일';
    } else if (selectedDays.length == 2 &&
        selectedDays.contains('일') &&
        selectedDays.contains('토')) {
      displayText = '매주 주말';
    } else {
      displayText = '매주 ${selectedDays.join(', ')}';
    }

    return Container(
      width: 380,
      height: 36,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            displayText,
            textAlign: TextAlign.left,
            style: TextStyle(
                fontSize: 12,
                color: Color(text_color),
                fontWeight: FontWeight.bold),
          ),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Color(0xFF4C78BF), // 배경 색상
              borderRadius: BorderRadius.circular(6), // 둥근 모서리
            ),
            child: Icon(Icons.calendar_today, size: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildAreaSelector() {
    List<String> areas = ['A구역', 'B구역', 'C구역', 'D구역'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: areas.map((area) {
        bool isSelected = _selectedArea.contains(area);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedArea.remove(area);
              } else {
                _selectedArea.add(area);
              }
              _area = _selectedArea.join(', '); // 선택된 구역을 콤마로 구분하여 저장
            });
          },
          child: Container(
            width: 80, // 타원의 너비
            height: 40, // 타원의 높이
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40), // 둥근 모서리를 사용해 타원형으로 만듦
              border: Border.all(
                width: 3,
                color: isSelected ? Color(check_color) : Color(0x00FFFF),
              ),
            ),
            child: Center(
              child: Text(
                area,
                style: TextStyle(
                  color: isSelected ? Colors.white : Color(text_color),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRoutineDetails() {
    return Column(
      children: [
        _buildTextField('루틴 이름', _title, (value) {
          setState(() {
            _title = value;
          });
        }),
        _buildAreaSelector(), // 구역 선택 추가
        Container(
          width: 220,
          //color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIntervalRow(),
              SizedBox(height: 4),
              _buildDurationRow(),
              _buildPersonnelRow(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
      String label, String value, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Stack(
        children: [
          InnerShadow(
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 3,
                offset: Offset(0, -3),
              ),
              Shadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 3,
                offset: Offset(0, 3),
              ),
            ],
            child: Container(
              width: 380,
              height: 30,
              decoration: BoxDecoration(
                color: Color(0xFF41587A), // 배경색
                borderRadius: BorderRadius.circular(5), // 둥근 모서리
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              // 텍스트 필드의 아래쪽 여백 추가
              child: TextField(
                textAlign: TextAlign.center,
                // 텍스트 중앙 정렬
                style: TextStyle(color: Colors.white, fontSize: 12),
                // 텍스트 색상 및 크기
                decoration: InputDecoration(
                  hintText: label,
                  // 힌트 텍스트
                  hintStyle: TextStyle(
                      color: Color(0xFF9BC7F8),
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                  // 힌트 텍스트 스타일
                  contentPadding:
                  EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  // 패딩 조정
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white), // 밑줄 색상
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide:
                    BorderSide(color: Colors.white), // 활성화된 상태의 밑줄 색상
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide:
                    BorderSide(color: Colors.white), // 포커스된 상태의 밑줄 색상
                  ),
                ),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntervalRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('순찰 간격 :',
            style: TextStyle(
                color: Color(text_color), fontWeight: FontWeight.bold)),
        SizedBox(width: 6),
        _buildSmallTimeField(_intervalH, (value) {
          setState(() {
            _intervalH = value;
          });
        }),
        Text('시간',
            style: TextStyle(
                color: Color(text_color), fontWeight: FontWeight.bold)),
        _buildSmallTimeField(_intervalM, (value) {
          setState(() {
            _intervalM = value;
          });
        }),
        Text('분 간격',
            style: TextStyle(
                color: Color(text_color), fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildDurationRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('순찰 시간 :',
            style: TextStyle(
                color: Color(text_color), fontWeight: FontWeight.bold)),
        SizedBox(width: 6),
        _buildSmallTimeField(_timeH, (value) {
          setState(() {
            _timeH = value;
          });
        }),
        Text('시간',
            style: TextStyle(
                color: Color(text_color), fontWeight: FontWeight.bold)),
        _buildSmallTimeField(_timeM, (value) {
          setState(() {
            _timeM = value;
          });
        }),
        Text('분 동안',
            style: TextStyle(
                color: Color(text_color), fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildPersonnelRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '순찰 대수 :',
          style: TextStyle(color: Color(text_color), fontWeight: FontWeight.bold),
        ),
        SizedBox(width: 6),
        Container(
          height: 42,
          width: 70, // 적절한 너비 설정
          child: Align(
            alignment: Alignment.bottomCenter,
            child: DropdownButtonFormField<String>(
              value: _areaper.isNotEmpty ? _areaper : null, // 기본값이 존재하는지 확인
              items: ['구역별', '전체'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Container(
                    alignment: Alignment.bottomCenter, // 텍스트를 박스의 바닥에 정렬
                    child: Text(
                      value,
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _areaper = newValue!;
                });
              },
              decoration: InputDecoration(
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white), // 밑줄 색상
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white), // 활성화된 상태의 밑줄 색상
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white), // 포커스된 상태의 밑줄 색상
                ),
              ),
              iconEnabledColor: Colors.white, // 드롭다운 아이콘 색상 변경
              dropdownColor: Color(SaportBlue), // 드롭다운 배경색 변경
              style: TextStyle(color: Colors.white, fontSize: 14), // 드롭다운 텍스트 스타일
            ),
          ),
        ),
        SizedBox(width: 24),
        _buildSmallTimeField(_robotper, (value) {
          setState(() {
            _robotper = value;
          });
        }),
        Text(
          '기',
          style: TextStyle(color: Color(text_color), fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () {
            widget.onSave(List.from(widget.contentItems));
          },
          child: Text('취소'),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.transparent),
            elevation: MaterialStateProperty.all(0), // 그림자 없애기
            foregroundColor: MaterialStateProperty.all(Colors.white),
            side: MaterialStateProperty.all(BorderSide(color: Colors.white)), // 테두리 색상
          ),
        ),
        ElevatedButton(
          onPressed: _saveRoutine, // 저장 버튼 클릭 시 _saveRoutine 메소드 호출
          child: Text('저장'),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.transparent),
            elevation: MaterialStateProperty.all(0), // 그림자 없애기
            foregroundColor: MaterialStateProperty.all(Colors.white),
            side: MaterialStateProperty.all(BorderSide(color: Colors.white)), // 테두리 색상
          ),
        ),
      ],
    );
  }

  void _saveRoutine() {
    List<int> dayStatusList = List.generate(7, (index) => _dayStatus.contains(['일', '월', '화', '수', '목', '금', '토'][index]) ? 1 : 0);

    Map<String, dynamic> newRoutine = {
      "title": _title,
      "area": _area,
      "description": "$_startH:$_startM ~ $_endH:$_endM, $_intervalH시간 $_intervalM분 간격으로, $_robotper기, 1회 순찰 후 복귀",
      "dayStatus": dayStatusList,
    };

    setState(() {
      _currentItems = List.from(widget.contentItems); // contentItems로 초기화
      _currentItems.add(newRoutine);
    });

    // onSave 콜백 호출
    widget.onSave(List.from(_currentItems));
  }
}
