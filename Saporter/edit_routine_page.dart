import 'package:flutter/material.dart';

const int SaportBlue = 0xFF2A558C;
const int back_grid_main_color = 0xE6BED7FF;
const int back_grid_top_color = 0xE6DCEAFF;
const int content_box_color = 0xFF4C78BF;
const int inner_box_color = 0xFF76BFFF;
const int activated_color = 0xFF23497B;
const int unactivated_color = 0xFFFFFFFF;
const int day_box_color = 0xFFA6CDFF;

class EditPage extends StatefulWidget {
  final List<Map<String, dynamic>> contentItems;
  final Function(List<Map<String, dynamic>>) onSave;

  EditPage({required this.contentItems, required this.onSave});

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  List<Map<String, dynamic>> _currentItems = [];
  List<bool> _selectedItems = [];

  @override
  void initState() {
    super.initState();
    _currentItems = List<Map<String, dynamic>>.from(widget.contentItems);
    _selectedItems = List<bool>.generate(_currentItems.length, (index) => false);
  }

  void _removeSelectedItems() {
    setState(() {
      for (int i = _selectedItems.length - 1; i >= 0; i--) {
        if (_selectedItems[i]) {
          _currentItems.removeAt(i);
          _selectedItems.removeAt(i);
        }
      }
    });
  }

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
            child: Container(
              decoration: BoxDecoration(
                color: Color(SaportBlue),
              ),
              child: ReorderableListView.builder(
                onReorder: _onReorder,
                itemCount: _currentItems.length,
                itemBuilder: (context, index) {
                  var data = _currentItems[index];
                  return _buildContentContainer(
                    index,
                    data['title'],
                    data['area'],
                    data['description'],
                    List<int>.from(data['dayStatus']),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    setState(() {
      final item = _currentItems.removeAt(oldIndex);
      _currentItems.insert(newIndex, item);
      final selectedItem = _selectedItems.removeAt(oldIndex);
      _selectedItems.insert(newIndex, selectedItem);
    });
  }

  Widget _buildCustomAppBar() {
    return Container(
      height: 20, // 높이를 적절히 조정
      width: 400,
      margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
      color: Color(SaportBlue),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: Icon(
                  Icons.arrow_back, color: Colors.white, size: 16),
              onPressed: () {
                widget.onSave(_currentItems);
              },
              padding: EdgeInsets.all(0.0),
              alignment: Alignment.centerLeft,
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Text(
              '루틴 선택 및 순서 변경',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: Icon(Icons.delete, color: Colors.white, size: 16),
              onPressed: _removeSelectedItems,
              padding: EdgeInsets.all(0.0),
              alignment: Alignment.centerRight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomCheckbox(bool value, Function(bool?) onChanged) {
    return GestureDetector(
      onTap: () {
        onChanged(!value);
      },
      child: Container(
        width: 24,
        height: 24,
        margin: EdgeInsets.only(right: 8.0),
        decoration: BoxDecoration(
          color: value ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(4.0),
          border: Border.all(
            color: Colors.white,
            width: 2.0,
          ),
        ),
        child: value
            ? Icon(
          Icons.check,
          size: 16.0,
          color: Colors.white,
        )
            : null,
      ),
    );
  }

  Widget _buildContentContainer(int index, String title, String area, String description, List<int> dayStatus) {
    return Container(
      key: ValueKey(index),
      height: 90,
      margin: EdgeInsets.only(bottom: 16),
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
                ReorderableDragStartListener(
                  index: index,
                  child: Icon(Icons.drag_handle, color: Color(SaportBlue)),
                ),
                Container(
                  height: 18,
                  width: 140,
                  margin: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Color(inner_box_color),
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Center(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ),
                Spacer(),
                Container(
                  height: 18,
                  margin: EdgeInsets.only(right: 4),
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
                              fontSize: 7,
                              color: dayStatus[i] == 0 ? Color(unactivated_color) : Color(activated_color),
                              fontWeight: FontWeight.normal,
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
                _buildCustomCheckbox(
                  _selectedItems[index],
                      (value) {
                    setState(() {
                      _selectedItems[index] = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: 52,
                  width: 90,
                  margin: EdgeInsets.all(2),
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
                Expanded(
                  child: Container(
                    height: 52,
                    margin: EdgeInsets.all(2),
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
